from fastapi import FastAPI
from routes import guardians, settings, calls, alerts

app = FastAPI()

app.include_router(guardians.router, prefix="/guardians")
app.include_router(settings.router, prefix="/settings")
app.include_router(calls.router, prefix="/calls")
app.include_router(alerts.router, prefix="/alerts")

@app.get("/")
def root():
    return {"message": "VocaSense Backend Running"}