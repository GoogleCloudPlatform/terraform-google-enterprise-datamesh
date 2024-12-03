import uuid
from typing import List, Final

from fastapi import HTTPException
from sqlmodel import Session, select

from .db_engine import engine
from .models import Role, Permission


PERMISSION_WAITING_APPROVAL: Final[str] = "WAITING_APPROVAL"
PERMISSION_APPROVED: Final[str] = "APPROVED"
PERMISSION_DENIED: Final[str] = "DENIED"


def create_permission_request(email: str, roles: list):
    roles_entity: List[Role] = []
    for r in roles:
        roles_entity.append(Role(id=str(uuid.uuid4()), role=r))

    entity = Permission(
        id=str(uuid.uuid4()),
        email=email,
        status=PERMISSION_WAITING_APPROVAL,
    )
    entity.roles = roles_entity
    with Session(engine) as session:
        session.add(entity)
        session.commit()
        session.refresh(entity)
        return entity


def list_permission_requests():
    permissions = []
    with Session(engine) as session:
        statement = select(Permission)
        results = session.exec(statement).all()
        for result in results:
            permissions.append(__permission_to_dict(result))
        return permissions


def get_permission_request_by_id(request_id: str):
    with Session(engine) as session:
        statement = select(Permission).where(Permission.id == request_id)
        result = session.exec(statement).first()
        if not result:
            raise HTTPException(status_code=400, detail="Request ID not found.")
        return __permission_to_dict(result)
    return None


def get_waiting_approval_permission(request_id):
    permission = get_permission_request_by_id(request_id)
    if permission["status"] == PERMISSION_WAITING_APPROVAL:
        return permission
    return None


def approve_permission_request(request_id: str):
    return update_permission_request_status(
        request_id=request_id, status=PERMISSION_APPROVED
    )


def deny_permission_request(request_id: str):
    return update_permission_request_status(
        request_id=request_id, status=PERMISSION_DENIED
    )


def update_permission_request_status(request_id: str, status: str):
    with Session(engine) as session:
        request_db = session.get(Permission, request_id)
        if not request_db:
            raise HTTPException(status_code=400, detail="Request ID not found.")
        approved_request = request_db
        approved_request.status = status
        approved_request_data = approved_request.model_dump(exclude_unset=True)
        request_db.sqlmodel_update(approved_request_data)
        session.add(request_db)
        session.commit()
        session.refresh(request_db)
        return request_db


def __permission_to_dict(value: Permission):
    return {
        "id": value.id,
        "created_at": value.created_at,
        "email": value.email,
        "roles": [role.role for role in value.roles],
        "status": value.status,
    }
