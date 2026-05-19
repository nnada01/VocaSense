from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from firebase_admin_init import db
from utils.auth import verify_token
from datetime import datetime, timezone

router = APIRouter()


class PhoneCheckRequest(BaseModel):
    phone: str


class ReportSpamRequest(BaseModel):
    phone: str
    reason: str | None = None
    risk_score: float | None = None
    source: str | None = "manual"

class CallLogRequest(BaseModel):
    phone: str
    status: str
    risk_score: float | None = None
    source: str | None = "manual"


@router.post("/check-number")
async def check_number(data: PhoneCheckRequest):
    try:
        phone = data.phone.strip()
        doc = db.collection("spam_numbers").document(phone).get()

        if doc.exists:
            spam_data = doc.to_dict()
            return {
                "is_spam": True,
                "data": {
                    "phone": phone,
                    "status": spam_data.get("status", "suspected_spam"),
                    "report_count": spam_data.get("report_count", 1),
                    "reason": spam_data.get("reason"),
                    "risk_score": spam_data.get("risk_score"),
                }
            }

        return {"is_spam": False}
    except Exception as e:
        print("CHECK NUMBER ERROR:", e)
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/report-spam")
async def report_spam(data: ReportSpamRequest, user_id=Depends(verify_token)):
    try:
        phone = data.phone.strip()
        ref = db.collection("spam_numbers").document(phone)
        doc = ref.get()

        now = datetime.now(timezone.utc)

        if doc.exists:
            current = doc.to_dict()
            report_count = current.get("report_count", 0) + 1

            status = "confirmed_spam" if report_count >= 3 else "suspected_spam"

            ref.update({
                "phone": phone,
                "report_count": report_count,
                "status": status,
                "reason": data.reason or current.get("reason"),
                "risk_score": data.risk_score if data.risk_score is not None else current.get("risk_score"),
                "last_reported": now,
                "updated_at": now,
            })
        else:
            ref.set({
                "phone": phone,
                "report_count": 1,
                "status": "suspected_spam",
                "reason": data.reason,
                "risk_score": data.risk_score,
                "source": data.source,
                "created_at": now,
                "updated_at": now,
                "last_reported": now,
            })

        db.collection("call_reports").add({
            "phone": phone,
            "reported_by": user_id,
            "reason": data.reason,
            "risk_score": data.risk_score,
            "source": data.source,
            "created_at": now,
        })

        updated_doc = ref.get().to_dict()

        return {
            "status": "reported",
            "spam_number": {
                "phone": phone,
                "report_count": updated_doc.get("report_count", 1),
                "status": updated_doc.get("status", "suspected_spam"),
            }
        }
    except Exception as e:
        print("REPORT SPAM ERROR:", e)
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/sync")
async def sync_spam_numbers():
    try:
        docs = db.collection("spam_numbers").stream()

        return [
            {
                "phone": doc.id,
                "status": doc.to_dict().get("status", "suspected_spam"),
                "report_count": doc.to_dict().get("report_count", 1),
            }
            for doc in docs
        ]
    except Exception as e:
        print("SYNC SPAM ERROR:", e)
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/log")
async def log_call(data: CallLogRequest, user_id=Depends(verify_token)):
    try:
        now = datetime.now(timezone.utc)

        call_data = {
            "phone": data.phone.strip(),
            "status": data.status,
            "risk_score": data.risk_score,
            "source": data.source,
            "created_at": now,
        }

        db.collection("users") \
            .document(user_id) \
            .collection("call_history") \
            .add(call_data)

        return {"status": "logged", "call": call_data}

    except Exception as e:
        print("LOG CALL ERROR:", e)
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/history")
async def get_call_history(user_id=Depends(verify_token)):
    try:
        docs = db.collection("users") \
            .document(user_id) \
            .collection("call_history") \
            .order_by("created_at", direction="DESCENDING") \
            .limit(20) \
            .stream()

        history = []

        for doc in docs:
            item = doc.to_dict()
            item["id"] = doc.id

            if "created_at" in item:
                item["created_at"] = item["created_at"].isoformat()

            history.append(item)

        return history

    except Exception as e:
        print("GET HISTORY ERROR:", e)
        raise HTTPException(status_code=500, detail=str(e))