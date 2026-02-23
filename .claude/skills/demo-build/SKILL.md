---
name: demo-build
aliases: [db]
description: Orchestrator — creates feature/backend and feature/frontend worktrees, dispatches both builder subagents IN PARALLEL. Does NOT run code-review (user runs /code-review manually after).
---

# Demo Build Orchestrator

Demonstrates Claude Code's parallel multi-agent workflow:
- Creates 2 isolated git worktrees simultaneously
- Dispatches backend and frontend builder subagents IN PARALLEL
- Both branches developed at the same time without interference

After this skill completes, the user runs `/code-review` manually to show live code quality enforcement.

## Usage

```bash
/demo-build
# or
/db
```

## Instructions

When this skill is invoked, execute ALL steps below IN ORDER.

---

### Step 1: Create Both Worktrees

```bash
# Verify .worktrees/ is ignored — STOP if not
git check-ignore -q .worktrees/ && echo "OK — proceeding" || echo "ERROR: .worktrees/ not in .gitignore. Fix before continuing."

# Create backend worktree
git worktree add .worktrees/feature/backend -b feature/backend

# Create frontend worktree
git worktree add .worktrees/feature/frontend -b feature/frontend
```

Install backend dependencies:
```bash
cd .worktrees/feature/backend/demo/backend
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt -q
```

Install frontend dependencies:
```bash
cd .worktrees/feature/frontend/demo/frontend && npm install --silent
```

Report:
```
✅ Worktrees ready:
  - .worktrees/feature/backend  (branch: feature/backend)
  - .worktrees/feature/frontend (branch: feature/frontend)
```

---

### Step 2: Dispatch BOTH Subagents in Parallel

**CRITICAL:** Use the Task tool to dispatch BOTH subagents in a SINGLE message so they run simultaneously. Do not wait for one to finish before starting the other.

**Backend subagent prompt:**
```
You are a backend developer implementing a FastAPI Todo API.

Working directory: .worktrees/feature/backend/demo/backend

IMPORTANT: Use the venv at .venv/bin/python and .venv/bin/pytest for all commands.

Implement the complete Todo API by filling in main.py and tests/test_main.py:

main.py — replace the file completely with:
- In-memory storage: `db: dict[int, dict] = {}` and `_next_id: int = 1` (module-level globals)
- Pydantic models: `TaskCreate(title: str)`, `TaskResponse(id: int, title: str, completed: bool)`
- `from fastapi import FastAPI, HTTPException` and `from fastapi.responses import Response`
- GET /tasks → returns list[TaskResponse]
- POST /tasks → receives TaskCreate, stores task with completed=False, returns TaskResponse (status 201)
- PUT /tasks/{task_id} → toggles task.completed, returns TaskResponse. Raises HTTPException(404) if not found.
- DELETE /tasks/{task_id} → removes task, returns Response(status_code=204). Raises HTTPException(404) if not found.

tests/test_main.py — replace the file completely with:
- `pytestmark = pytest.mark.asyncio` at module level
- All imports: pytest, AsyncClient, ASGITransport, app
- Fixture `client` already provided — keep it
- test_list_tasks_empty: GET /tasks returns []
- test_create_task: POST /tasks {"title": "Buy milk"} returns id=1, completed=False
- test_update_task_toggles_completion: create task, PUT /tasks/1, assert completed is True
- test_delete_task: create task, DELETE /tasks/1 returns 204
- test_task_not_found: PUT /tasks/999 returns 404

Add a pytest.ini file in the working directory with:
```ini
[pytest]
asyncio_mode = auto
```

Run tests:
```bash
.venv/bin/pytest tests/ -v
```

All 5 tests must pass. Fix any failures before finishing.

Commit from .worktrees/feature/backend/:
```bash
git add .
git commit -m "feat: implement FastAPI Todo API with in-memory storage and tests"
```

Report: list of files changed + test results.
```

**Frontend subagent prompt:**
```
You are a frontend developer implementing a React Todo UI.

Working directory: .worktrees/feature/frontend/demo/frontend

Replace demo/frontend/src/App.jsx with a complete Todo app implementation:

Requirements:
- `const API_BASE = '/tasks'` is already defined — use it for ALL fetch calls
- useEffect on mount: GET /tasks, set tasks state
- Show a loading message while fetching
- Show each task as a list item with:
  - The task title (strikethrough style if completed)
  - A checkbox (checked if completed) → onClick calls PUT /tasks/{id}, toggles completion in state
  - A "Delete" button → onClick calls DELETE /tasks/{id}, removes from state
- Form at top: text input + "Add" button → POST /tasks with {title: inputValue}, adds to state, clears input
- Handle empty list: show "No tasks yet."
- Style: inline styles only. Clean, minimal. No CSS files, no external libraries.

The file should import only from react (useState, useEffect). No other imports.

Run to verify no syntax errors:
```bash
npm run build
```

Build must succeed with 0 errors.

Commit from .worktrees/feature/frontend/:
```bash
git add .
git commit -m "feat: implement React Todo UI with full CRUD"
```

Report: what was implemented + build result.
```

---

### Step 3: Wait and Report

Wait for BOTH subagents to complete.

Final report:
```
🎉 Demo Build Complete!

feature/backend  ✅  FastAPI implemented — 5 tests passing
feature/frontend ✅  React UI implemented — build successful

Next step → run /code-review to see live quality enforcement on feature/backend

To start the app:
  ./run.sh
  Browser: http://localhost:5173
```

---

## Notes for Demo

- Steps 1 and 2 are the entire live demo — narrate what you see
- The parallel dispatch is the "wow" moment — two agents working simultaneously
- /code-review is intentionally left for the user to run manually so the audience sees it happen live
- Expected total time for both subagents: 5-8 minutes
- If one subagent fails, the other continues independently — that's the point of worktrees
