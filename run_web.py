"""Start the CameraApp web showcase on http://127.0.0.1:8265 (local only).

    pip install -r requirements-web.txt
    python run_web.py [--port 8265]
"""
import argparse

import uvicorn

if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--port", type=int, default=8265)
    a = ap.parse_args()
    print(f"CameraApp web app: http://127.0.0.1:{a.port}")
    uvicorn.run("web.app:app", host="127.0.0.1", port=a.port)
