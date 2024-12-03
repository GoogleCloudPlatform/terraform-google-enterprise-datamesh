from fastapi import Depends, FastAPI

from .routers import permission_requests
from .db import db_engine


app = FastAPI()


app.include_router(permission_requests.router)

db_engine.create_db_and_tables()


@app.get("/")
async def health_check():
    return {"message": "Hello Data Access Management Application!"}
