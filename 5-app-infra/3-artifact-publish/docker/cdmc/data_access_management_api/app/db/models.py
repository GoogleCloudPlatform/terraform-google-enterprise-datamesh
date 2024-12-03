from typing import List, Final
from datetime import datetime

from sqlmodel import Field, Session, SQLModel, Relationship


class Permission(SQLModel, table=True):
    id: str | None = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=lambda: datetime.now())
    email: str = Field(index=True)
    roles: List["Role"] = Relationship(back_populates="permission")
    status: str = Field(index=True)


class Role(SQLModel, table=True):
    id: str = Field(default=None, primary_key=True)
    role: str = Field(index=True)

    permission_id: str = Field(default=None, foreign_key="permission.id")
    permission: Permission = Relationship(back_populates="roles")
