from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from firebase_admin_init import db
from utils.auth import verify_token
from utils.sms import send_sms
from datetime import datetime, timezone

router = APIRouter()


class GuardianAlertRequest(BaseModel):
    phone: str
    status: str
    risk_score: float | None = None
    message: str | None = None


@router.post("/guardian")
async def create_guardian_alert(data: GuardianAlertRequest, user_id=Depends(verify_token)):
    try:
        now = datetime.now(timezone.utc)

        guardians_ref = db.collection("users").document(user_id).collection("guardians")
        guardians = list(guardians_ref.stream())

        if not guardians:
            return {"status": "no_guardians", "message": "No guardians to alert"}

        for guardian in guardians:
            guardian_data = guardian.to_dict()

            sms_text = data.message or f"VocaSense detected a risky call from {data.phone}"

            sms_sid = send_sms(
                to_phone=guardian_data.get("phone"),
                message=sms_text,
            )

            alert_data = {
                "guardian_id": guardian.id,
                "guardian_name": guardian_data.get("name"),
                "guardian_phone": guardian_data.get("phone"),
                "call_phone": data.phone,
                "status": data.status,
                "risk_score": data.risk_score,
                "message": sms_text,
                "sms_sid": sms_sid,
                "sms_sent": sms_sid is not None,
                "read": False,
                "created_at": now,
            }

            db.collection("users") \
                .document(user_id) \
                .collection("guardian_alerts") \
                .add(alert_data)

        return {"status": "alerts_created", "count": len(guardians)}

    except Exception as e:
        print("GUARDIAN ALERT ERROR:", e)
        raise HTTPException(status_code=500, detail=str(e))