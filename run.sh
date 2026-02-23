#!/usr/bin/env bash
# run.sh — Starts backend (FastAPI) and frontend (React) from worktrees
# Usage: ./run.sh

set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$REPO_ROOT/.worktrees/feature/backend/demo/backend"
FRONTEND_DIR="$REPO_ROOT/.worktrees/feature/frontend/demo/frontend"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

cleanup() {
  echo ""
  echo -e "${YELLOW}Stopping servers...${NC}"
  kill "$BACKEND_PID" 2>/dev/null && echo -e "${GREEN}Backend stopped${NC}" || true
  kill "$FRONTEND_PID" 2>/dev/null && echo -e "${GREEN}Frontend stopped${NC}" || true
  exit 0
}

trap cleanup SIGINT SIGTERM

# Check worktrees exist
if [ ! -d "$BACKEND_DIR" ]; then
  echo -e "${RED}Error: Backend worktree not found at $BACKEND_DIR${NC}"
  echo "Run /demo-build first to create the worktrees."
  exit 1
fi

if [ ! -d "$FRONTEND_DIR" ]; then
  echo -e "${RED}Error: Frontend worktree not found at $FRONTEND_DIR${NC}"
  echo "Run /demo-build first to create the worktrees."
  exit 1
fi

# Check venv exists
if [ ! -f "$BACKEND_DIR/.venv/bin/uvicorn" ]; then
  echo -e "${YELLOW}Backend venv not found — installing dependencies...${NC}"
  python3 -m venv "$BACKEND_DIR/.venv"
  "$BACKEND_DIR/.venv/bin/pip" install -r "$BACKEND_DIR/requirements.txt" -q
fi

# Check node_modules exists
if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
  echo -e "${YELLOW}Frontend node_modules not found — installing dependencies...${NC}"
  (cd "$FRONTEND_DIR" && npm install --silent)
fi

echo ""
echo -e "${GREEN}Starting Todo App...${NC}"
echo -e "  Backend  → ${GREEN}http://localhost:8000${NC}  (FastAPI)"
echo -e "  Frontend → ${GREEN}http://localhost:5173${NC}  (React)"
echo -e "  API Docs → ${GREEN}http://localhost:8000/docs${NC}"
echo ""
echo "Press Ctrl+C to stop both servers."
echo ""

# Start backend
(cd "$BACKEND_DIR" && .venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000 --reload 2>&1 | sed 's/^/[backend] /') &
BACKEND_PID=$!

# Start frontend
(cd "$FRONTEND_DIR" && npm run dev 2>&1 | sed 's/^/[frontend] /') &
FRONTEND_PID=$!

# Wait for both
wait "$BACKEND_PID" "$FRONTEND_PID"
