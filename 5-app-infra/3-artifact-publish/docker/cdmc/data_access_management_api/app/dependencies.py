from typing import Annotated

from google.auth import jwt

from fastapi.security import OAuth2PasswordBearer
from fastapi import HTTPException, Depends, Request


oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")


async def get_current_user(token: Annotated[str, Depends(oauth2_scheme)]):
    user = jwt.decode(token, verify=False)["email"]
    if user is not None:
        return user
    else:
        raise HTTPException(status_code=401, detail="No valid token provided")
