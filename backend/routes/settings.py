from fastapi import APIRouter, Depends
from firebase_admin_init import db
from utils.auth import verify_token

router = APIRouter()

@router.get("/")
async def get_settings(user_id=Depends(verify_token)):
    doc = db.collection("users").document(user_id).collection("settings").document("prefs").get()

    return doc.to_dict() if doc.exists else {}


@router.put("/")
async def save_settings(data: dict, user_id=Depends(verify_token)):
    db.collection("users")\
      .document(user_id)\
      .collection("settings")\
      .document("prefs")\
      .set(data)

    return {"status": "saved"}