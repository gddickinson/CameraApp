"""Project constants for the web interface (title, description from the README/GitHub, port, files to leave out)."""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TITLE = "CameraApp"
REPO = "CameraApp"
PORT = 8265
DESCRIPTION = "An iOS camera and AR application built with Swift, AVFoundation, and ARKit."
# Web-interface files (not part of the iOS app) left out of the code explorer: top-level names or relative paths.
EXCLUDE = {"web", "scripts", "tests", "docs", "site", "run_web.py", "requirements-web.txt", "INTERFACE.md",
           "SESSION_LOG.md", "CLAUDE.md"}
