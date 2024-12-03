from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException


from ..dependencies import get_current_user
from ..db import db_operations as pr_db
from ..utils import identity, roles
from . import models


router = APIRouter(
    prefix="/v1/permission-requests",
    tags=["permission-requests"],
    dependencies=[Depends(get_current_user)],
    responses={404: {"description": "Not found"}},
)


@router.get("/{request_id}")
def get_requests_by_id(request_id):
    return pr_db.get_permission_request_by_id(request_id)


@router.get("/")
def get_requests():
    return pr_db.list_permission_requests()


@router.post("/users", status_code=201)
async def create_user_request(
    data_access_req: models.UserPermission,
    requester: Annotated[str, Depends(get_current_user)],
):
    permission = pr_db.create_permission_request(
        email=requester,
        roles=data_access_req.roles,
    )

    return {"data": permission}


@router.put("/{request_id}/approve")
async def approve(request_id: str, approver_email=Depends(get_current_user)):
    permission = pr_db.get_waiting_approval_permission(request_id)
    if permission is None:
        raise HTTPException(status_code=400, detail="Request Id not found.")

    groups = [roles.GROUPS_BY_ROLE[role] for role in permission["roles"]]
    for group in set(groups):
        print(f"Checking in the approver is in the group: {group}")
        if not identity.is_group_manager(group_email=group, user_email=approver_email):
            raise HTTPException(
                status_code=400,
                detail=f"User is not allowed to approve this requests. The approver should be a Group Manager: ${group}",
            )
        identity.add_user_to_group(user_email=permission["email"], group_email=group)

    return pr_db.approve_permission_request(request_id)


@router.put("/{request_id}/deny")
async def deny(request_id: str, approver_email=Depends(get_current_user)):
    permission = pr_db.get_waiting_approval_permission(request_id)
    if permission is None:
        raise HTTPException(status_code=400, detail="Request Id not found.")

    groups = [roles.GROUPS_BY_ROLE[role] for role in permission["roles"]]
    for group in set(groups):
        print(f"Checking in the approver is in the group: {group}")
        if not identity.is_group_manager(group_email=group, user_email=approver_email):
            raise HTTPException(
                status_code=400,
                detail=f"User is not allowed to deny this requests. The approver should be a Group Manager: ${group}",
            )
    return pr_db.deny_permission_request(request_id)
