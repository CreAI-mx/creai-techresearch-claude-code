#!/usr/bin/env bash
# run.sh — Starts backend (FastAPI) and frontend (React)
#
# Auto-detects which version to run:
#   - If worktrees exist (/demo-build already ran) → runs the full built app
#   - Otherwise → runs the skeleton from demo/ (empty stubs, for showing before the demo)
#
# Usage: ./run.sh

set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

WORKTREE_BACKEND="$REPO_ROOT/.worktrees/feature/backend/demo/backend"
WORKTREE_FRONTEND="$REPO_ROOT/.worktrees/feature/frontend/demo/frontend"

SKELETON_BACKEND="$REPO_ROOT/demo/backend"
SKELETON_FRONTEND="$REPO_ROOT/demo/frontend"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

cleanup() {
  echo ""
  echo -e "${YELLOW}Stopping servers...${NC}"
  kill "$BACKEND_PID" 2>/dev/null || true
  kill "$FRONTEND_PID" 2>/dev/null || true
  exit 0
}

trap cleanup SIGINT SIGTERM

# Auto-detect: worktrees (built) vs skeleton
if [ -d "$WORKTREE_BACKEND" ] && [ -d "$WORKTREE_FRONTEND" ]; then
  BACKEND_DIR="$WORKTREE_BACKEND"
  FRONTEND_DIR="$WORKTREE_FRONTEND"
  MODE="${GREEN}[FULL APP]${NC} — running from worktrees (post /demo-build)"
else
  BACKEND_DIR="$SKELETON_BACKEND"
  FRONTEND_DIR="$SKELETON_FRONTEND"
  MODE="${CYAN}[SKELETON]${NC} — running stubs from demo/ (run /demo-build to build the full app)"
fi

# Ensure backend venv exists
if [ ! -f "$BACKEND_DIR/.venv/bin/uvicorn" ]; then
  echo -e "${YELLOW}Setting up backend venv...${NC}"
  python3 -m venv "$BACKEND_DIR/.venv"
  "$BACKEND_DIR/.venv/bin/pip" install -r "$BACKEND_DIR/requirements.txt" -q
fi

# Ensure frontend node_modules exist
if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
  echo -e "${YELLOW}Installing frontend dependencies...${NC}"
  (cd "$FRONTEND_DIR" && npm install --silent)
fi

echo ""
echo -e "Mode:     $(echo -e $MODE)"
echo -e "Backend  → ${GREEN}http://localhost:8000${NC}  (FastAPI)"
echo -e "Frontend → ${GREEN}http://localhost:5173${NC}  (React)"
echo -e "API Docs → ${GREEN}http://localhost:8000/docs${NC}"
echo ""
echo "Press Ctrl+C to stop both servers."
echo ""

# Start backend
(cd "$BACKEND_DIR" && .venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000 --reload 2>&1 | sed 's/^/[backend] /') &
BACKEND_PID=$!

# Start frontend
(cd "$FRONTEND_DIR" && npm run dev 2>&1 | sed 's/^/[frontend] /') &
FRONTEND_PID=$!

wait "$BACKEND_PID" "$FRONTEND_PID"
