from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from firebase_admin_init import db
from utils.auth import verify_token
import uuid

router = APIRouter()


class GuardianCreate(BaseModel):
    name: str
    phone: str


@router.get("/")
async def get_guardians(user_id=Depends(verify_token)):
    try:
        docs = db.collection("users").document(user_id).collection("guardians").stream()

        return [
            {**doc.to_dict(), "id": doc.id}
            for doc in docs
        ]
    except Exception as e:
        print("GET GUARDIANS ERROR:", e)
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/")
async def add_guardian(data: GuardianCreate, user_id=Depends(verify_token)):
    try:
        guardian_id = str(uuid.uuid4())

        guardian_data = {
            "name": data.name.strip(),
            "phone": data.phone.strip(),
        }

        db.collection("users") \
            .document(user_id) \
            .collection("guardians") \
            .document(guardian_id) \
            .set(guardian_data)

        return {
            "status": "added",
            "guardian": {
                "id": guardian_id,
                **guardian_data
            }
        }
    except Exception as e:
        print("ADD GUARDIAN ERROR:", e)
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{guardian_id}")
async def delete_guardian(guardian_id: str, user_id=Depends(verify_token)):
    try:
        db.collection("users") \
            .document(user_id) \
            .collection("guardians") \
            .document(guardian_id) \
            .delete()

        return {"status": "deleted"}
    except Exception as e:
        print("DELETE GUARDIAN ERROR:", e)
        raise HTTPException(status_code=500, detail=str(e))