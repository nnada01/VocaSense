from fastapi import Header, HTTPException
import firebase_admin
from firebase_admin import auth

async def verify_token(authorization: str = Header(None)):
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing token")

    token = authorization.split(" ")[1]

    try:
        decoded = auth.verify_id_token(token)
        return decoded["uid"]
    except:
        raise HTTPException(status_code=401, detail="Invalid token")