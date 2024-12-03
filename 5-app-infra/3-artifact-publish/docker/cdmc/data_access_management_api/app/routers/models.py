from pydantic import BaseModel, field_validator

from ..utils import roles


class UserPermission(BaseModel):
    roles: list

    @field_validator("roles")
    @classmethod
    def check_roles(cls, v: list):
        if not all(role in roles.ALLOWED_ROLES for role in v):
            raise ValueError(f"Invalid role. Allowed roles: {roles.ALLOWED_ROLES}")
        return v
