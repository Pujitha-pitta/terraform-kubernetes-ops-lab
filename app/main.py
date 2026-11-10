"""Small service for practicing Docker, Kubernetes, and CloudWatch operations."""

from __future__ import annotations

import json
import logging
import os
import time

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"), format="%(message)s")
logger = logging.getLogger("ops-demo")

APP_NAME = os.getenv("APP_NAME", "ops-observability-demo")
APP_VERSION = os.getenv("APP_VERSION", "0.1.0")

app = FastAPI(title="Ops Observability Demo", version=APP_VERSION)


@app.middleware("http")
async def request_log(request: Request, call_next):
    started = time.perf_counter()
    response = await call_next(request)
    elapsed_ms = round((time.perf_counter() - started) * 1000, 2)
    logger.info(json.dumps({
        "service": APP_NAME,
        "method": request.method,
        "path": request.url.path,
        "status_code": response.status_code,
        "duration_ms": elapsed_ms,
    }))
    return response


@app.get("/")
def home():
    return {
        "service": APP_NAME,
        "version": APP_VERSION,
        "message": "Hello from the cloud operations learning lab.",
        "next": "Try /healthz, /readyz, and /info",
    }


@app.get("/healthz")
def health():
    """Liveness endpoint: the process is responding."""
    return {"status": "healthy"}


@app.get("/readyz")
def readiness():
    """Readiness endpoint: toggle APP_READY=false to practice an unready pod."""
    ready = os.getenv("APP_READY", "true").lower() == "true"
    if not ready:
        return JSONResponse(status_code=503, content={"status": "not ready"})
    return {"status": "ready"}


@app.get("/info")
def info():
    return {
        "service": APP_NAME,
        "version": APP_VERSION,
        "environment": os.getenv("APP_ENV", "local"),
        "hostname": os.getenv("HOSTNAME", "local-process"),
    }


@app.get("/error")
def deliberate_error():
    """A safe demo endpoint for learning how HTTP errors appear in logs."""
    logger.error(json.dumps({"service": APP_NAME, "event": "demo_error", "status_code": 500}))
    return JSONResponse(status_code=500, content={"detail": "Intentional demo error for log practice"})
