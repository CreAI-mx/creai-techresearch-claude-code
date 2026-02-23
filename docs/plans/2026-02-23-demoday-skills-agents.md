# DemoDay: Skills & Agent Claude Code — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Construir el repo de presentación DemoDay que demuestra el workflow de Claude Code: un orquestador crea DOS worktrees en paralelo (`feature/backend` y `feature/frontend`), despacha un subagente por cada rama simultáneamente, y al finalizar el usuario corre `/code-review` en vivo para que la audiencia vea cómo el agente corrige el código.

**Architecture:**
- `feature/backend` → subagente construye FastAPI Todo API completa (4 endpoints + 5 tests)
- `feature/frontend` → subagente construye React UI que consume el backend
- Ambos subagentes corren en paralelo via Task tool
- `/code-review` es un paso manual separado — el usuario lo invoca en vivo al final
- El code-review opera sobre `feature/backend` para mostrar correcciones reales

**Tech Stack:** Python 3.11+, FastAPI, Uvicorn, Pydantic, Ruff, Pytest, Node 18+, React 18, Vite, Git Worktrees

---

## Task 1: Repo Foundation

**Files:**
- Create: `.gitignore`
- Create: `CLAUDE.md`
- Create: `docs/WORKFLOW.md`

**Step 1: Create `.gitignore`**

```
# Worktrees (CRITICAL: must be ignored)
.worktrees/

# Python
__pycache__/
*.pyc
*.pyo
.env
venv/
.venv/
*.egg-info/
dist/
.pytest_cache/
.ruff_cache/

# Node
node_modules/
.next/
dist/

# OS
.DS_Store
```

Run: `cat .gitignore` — verify `.worktrees/` is the first line.

**Step 2: Verify `.worktrees/` will be ignored**

```bash
git check-ignore -v .worktrees
```

Expected: `.gitignore:2:.worktrees/	.worktrees`

If NOT ignored, stop here — do not proceed without this confirmed.

**Step 3: Create `CLAUDE.md`**

```markdown
# CLAUDE.md — DemoDay: Skills & Agent Claude Code

## Project Overview
Demo repository for DemoDay. Shows Claude Code's multi-agent workflow:
orchestrator → 2 subagents in parallel (backend + frontend in separate branches)
→ manual /code-review to enforce quality.

## Code Standards (enforced by /code-review)

### Python (Backend)
- Formatter: `ruff format`
- Linter: `ruff check`
- All functions must have type hints
- All public functions must have docstrings
- Max line length: 88 characters
- No unused imports

### Testing (Backend)
- Framework: `pytest`
- All endpoints must have at least one test
- Use `httpx.AsyncClient` for FastAPI tests
- Tests live in `tests/` directory
- All happy paths must be covered

### JavaScript/React (Frontend)
- No unused imports
- Components must have prop validation (PropTypes or TypeScript)
- Fetch calls must handle loading and error states
- No hardcoded API URLs — use environment variables or constants

### Git
- Branch naming: `feature/<name>`, `fix/<name>`
- Commits: conventional commits (`feat:`, `fix:`, `chore:`, `test:`)
- No direct commits to `main`
- Worktrees directory: `.worktrees/`

### Architecture (Backend)
- Single `main.py` for demo simplicity
- In-memory storage (no DB — keep it simple)
- Pydantic models for request/response validation
- Explicit HTTP status codes

### Architecture (Frontend)
- Single `App.jsx` for demo simplicity
- API base URL as a constant at the top of the file
- No external state management libraries

## Skills Available
- `/code-review` — lint + format + pytest (backend). Run manually after /demo-build.
- `/demo-build` — orchestrator: creates both worktrees + launches both subagents in parallel.
```

**Step 4: Create `docs/WORKFLOW.md`**

```markdown
# Claude Code Workflow — DemoDay

## El Demo en 10 minutos

```
┌─────────────────────────────────────────────────────────┐
│               /demo-build  (Orquestador)                 │
│                                                          │
│  1. Crea worktrees:                                      │
│     ├─ .worktrees/feature/backend                        │
│     └─ .worktrees/feature/frontend                       │
│                          ↓                               │
│  2. Despacha en PARALELO (Task tool):                    │
│                                                          │
│  [Subagente: Backend]    [Subagente: Frontend]           │
│  • FastAPI 4 endpoints   • React + Vite                  │
│  • Pydantic models       • Lista de tareas               │
│  • 5 tests pytest        • Crear / completar / borrar    │
│  • commit                • commit                        │
│                          ↓                               │
│  3. Reporta: ambas ramas listas                          │
└─────────────────────────────────────────────────────────┘
                          ↓
         Usuario invoca manualmente:  /code-review
                          ↓
┌─────────────────────────────────────────────────────────┐
│              /code-review  (Agente de calidad)           │
│                                                          │
│  • ruff format .        (formatea código)                │
│  • ruff check --fix .   (corrige linting)                │
│  • pytest tests/ -v     (verifica tests)                 │
│  • Reporta y commitea fixes                              │
└─────────────────────────────────────────────────────────┘
                          ↓
         uvicorn main:app + npm run dev
         → App corriendo en localhost
```

## Skills instalados en este repo

| Skill | Comando | Cuándo se usa |
|-------|---------|---------------|
| Orchestrator | `/demo-build` | Acto 2 — lanza todo en paralelo |
| Code Review  | `/code-review` | Acto 3 — validación en vivo |

## Skills globales usados en el día a día

| Skill | Propósito |
|-------|-----------|
| `/brainstorming` | Explorar y diseñar antes de codear |
| `/writing-plans` | Plan detallado TDD |
| `/executing-plans` | Ejecutar plan con checkpoints |
| `/systematic-debugging` | Root cause → fix → verify |
| `/using-git-worktrees` | Workspace aislado por feature |
| `/finishing-a-development-branch` | Merge + cleanup |
```

**Step 5: Commit**

```bash
git add .gitignore CLAUDE.md docs/
git commit -m "chore: setup repo foundation, standards and workflow docs"
```

Expected: commit succeeds, `git status` clean.

---

## Task 2: Copy & Adapt Code Review Skill

**Files:**
- Create: `.claude/skills/code-review/SKILL.md`

**Step 1: Create the skills directory**

```bash
mkdir -p .claude/skills/code-review
```

**Step 2: Create `.claude/skills/code-review/SKILL.md`**

Skill adaptado del proyecto de siniestralidad — sin SonarQube, usa Ruff + Pytest:

```markdown
---
name: code-review
aliases: [cr]
description: Runs ruff format, ruff check --fix, and pytest on the backend. Fixes all issues found. Run this manually after /demo-build.
---

# Code Review

Automates backend code quality checks:
1. Checks Ruff is installed
2. Runs `ruff format` to format code
3. Runs `ruff check --fix` to lint and auto-fix
4. Fixes any remaining linter errors manually
5. Runs `pytest` and fixes failing tests
6. Commits all fixes

## Usage

```bash
/code-review
# or
/cr
```

## Instructions

**Working directory for this project:** `.worktrees/feature/backend/demo/backend`

When this skill is invoked:

### 1. Version Check

```bash
ruff --version
```

If not installed: `pip install ruff`

### 2. Format (Iteration Loop)

```bash
cd .worktrees/feature/backend/demo/backend
ruff format .
```

### 3. Lint & Fix (Iteration Loop)

```bash
ruff check --fix .
```

If errors remain after `--fix`:
- Read each file with errors using the Read tool
- Fix manually using the Edit tool — NEVER use sed/awk
- Run `ruff check .` again
- Repeat until zero errors

### 4. Run Tests (Iteration Loop)

```bash
pytest tests/ -v
```

If tests fail:
- Read the failing test and the source file
- Apply minimal fix with Edit tool
- Run `pytest tests/ -v` again
- Max 5 iterations — if unresolved, report to user

### 5. Final Verification

```bash
ruff format . && ruff check . && pytest tests/ -v
```

All three must pass with zero errors.

### 6. Commit fixes

```bash
git add .
git commit -m "chore: code review — ruff formatting, linting fixes"
```

## Output Format

```
✅ Code Review Complete

Formatting: X files reformatted
Linting:    X issues fixed across Y files
Tests:      X passed, 0 failed

Code is ready for PR.
```

## Important Notes

- ALWAYS use Edit tool to fix code — NEVER bash sed/awk
- Read files before editing
- Keep fixes minimal and focused on reported issues
- All code and comments MUST be in English
- Max 5 iterations per phase — if stuck, ask the user
```

**Step 3: Verify**

```bash
head -5 .claude/skills/code-review/SKILL.md
```

Expected: frontmatter with `name: code-review`

**Step 4: Commit**

```bash
git add .claude/
git commit -m "feat: add code-review skill (ruff + pytest)"
```

---

## Task 3: Backend Skeleton (FastAPI)

**Files:**
- Create: `demo/backend/main.py`
- Create: `demo/backend/requirements.txt`
- Create: `demo/backend/tests/__init__.py`
- Create: `demo/backend/tests/test_main.py`

**Step 1: Create `demo/backend/requirements.txt`**

```
fastapi==0.115.0
uvicorn[standard]==0.32.0
pydantic==2.9.0
pytest==8.3.0
httpx==0.27.0
pytest-asyncio==0.24.0
ruff==0.7.0
```

**Step 2: Install dependencies**

```bash
pip install -r demo/backend/requirements.txt
```

Expected: all packages install without errors.

**Step 3: Create `demo/backend/main.py` — skeleton with stubs**

```python
"""
Todo API — DemoDay skeleton.
Subagent will implement all logic.
"""

from fastapi import FastAPI

app = FastAPI(title="Todo API", version="0.1.0")


# TODO: in-memory storage


@app.get("/tasks")
async def list_tasks():
    """Return all tasks."""
    ...


@app.post("/tasks", status_code=201)
async def create_task():
    """Create a new task."""
    ...


@app.put("/tasks/{task_id}")
async def update_task(task_id: int):
    """Toggle task completion."""
    ...


@app.delete("/tasks/{task_id}", status_code=204)
async def delete_task(task_id: int):
    """Delete a task by ID."""
    ...
```

**Step 4: Create `demo/backend/tests/__init__.py`**

Empty file.

**Step 5: Create `demo/backend/tests/test_main.py` — skeleton**

```python
"""
Tests for Todo API.
Subagent will implement all tests.
"""

import pytest
from httpx import AsyncClient, ASGITransport
from main import app


@pytest.fixture
async def client():
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as ac:
        yield ac


# TODO: subagent implements tests
```

**Step 6: Verify skeleton starts**

```bash
cd demo/backend && uvicorn main:app --reload &
sleep 2 && curl -s http://127.0.0.1:8000/docs | head -5
pkill -f "uvicorn main:app"
```

Expected: HTML response from FastAPI docs.

**Step 7: Commit**

```bash
git add demo/backend/
git commit -m "feat: add FastAPI backend skeleton"
```

---

## Task 4: Frontend Skeleton (React + Vite)

**Files:**
- Create: `demo/frontend/package.json`
- Create: `demo/frontend/vite.config.js`
- Create: `demo/frontend/index.html`
- Create: `demo/frontend/src/main.jsx`
- Create: `demo/frontend/src/App.jsx`

**Step 1: Create `demo/frontend/package.json`**

```json
{
  "name": "todo-frontend",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.3.1",
    "vite": "^5.4.1"
  }
}
```

**Step 2: Create `demo/frontend/vite.config.js`**

```js
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/tasks': 'http://localhost:8000'
    }
  }
})
```

**Step 3: Create `demo/frontend/index.html`**

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Todo App — DemoDay</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
```

**Step 4: Create `demo/frontend/src/main.jsx`**

```jsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
```

**Step 5: Create `demo/frontend/src/App.jsx` — skeleton with stubs**

```jsx
// Todo App — DemoDay skeleton.
// Subagent will implement all logic.

const API_BASE = '/tasks'

// TODO: subagent implements the full UI
export default function App() {
  return (
    <div>
      <h1>Todo App</h1>
      <p>Subagent is building this...</p>
    </div>
  )
}
```

**Step 6: Install dependencies**

```bash
cd demo/frontend && npm install
```

Expected: `node_modules/` created, no errors.

**Step 7: Verify skeleton runs**

```bash
cd demo/frontend && npm run dev &
sleep 3 && curl -s http://localhost:5173 | head -5
pkill -f "vite"
```

Expected: HTML response with `<title>Todo App`.

**Step 8: Commit**

```bash
git add demo/frontend/
git commit -m "feat: add React frontend skeleton"
```

---

## Task 5: Create Orchestrator Skill (`/demo-build`)

**Files:**
- Create: `.claude/skills/demo-build/SKILL.md`

El skill estrella del demo. Cuando se invoca:
1. Crea DOS worktrees: `feature/backend` y `feature/frontend`
2. Despacha DOS subagentes **en paralelo** (ambos con Task tool en el mismo mensaje)
3. Espera que ambos terminen y reporta
4. **NO incluye code-review** — eso lo corre el usuario manualmente después

**Step 1: Create `.claude/skills/demo-build/SKILL.md`**

```markdown
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
git check-ignore -q .worktrees && echo "OK — proceeding" || echo "ERROR: .worktrees/ not in .gitignore. Fix before continuing."

# Create backend worktree
git worktree add .worktrees/feature/backend -b feature/backend

# Create frontend worktree
git worktree add .worktrees/feature/frontend -b feature/frontend
```

Install backend dependencies:
```bash
pip install -r .worktrees/feature/backend/demo/backend/requirements.txt
```

Install frontend dependencies:
```bash
cd .worktrees/feature/frontend/demo/frontend && npm install
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

Implement the complete Todo API in main.py and tests/test_main.py:

main.py — add:
- In-memory storage: `db: dict[int, dict] = {}` and `_next_id: int = 1`
- Pydantic models: `TaskCreate(title: str)`, `TaskResponse(id: int, title: str, completed: bool)`
- GET /tasks → returns list[TaskResponse]
- POST /tasks → receives TaskCreate, stores task with completed=False, returns TaskResponse (status 201)
- PUT /tasks/{task_id} → toggles task.completed, returns TaskResponse. HTTPException 404 if not found.
- DELETE /tasks/{task_id} → removes task, returns Response(status_code=204). HTTPException 404 if not found.

tests/test_main.py — implement these 5 tests:
- test_list_tasks_empty: GET /tasks returns []
- test_create_task: POST creates task, returns id=1, completed=False
- test_update_task_toggles_completion: create then PUT /tasks/1, completed becomes True
- test_delete_task: create then DELETE /tasks/1 returns 204
- test_task_not_found: PUT /tasks/999 returns 404

Add this to tests/test_main.py at top level (needed for pytest-asyncio):
`pytestmark = pytest.mark.asyncio`

Run:
```bash
cd .worktrees/feature/backend/demo/backend
pytest tests/ -v
```

All 5 tests must pass. Fix any failures.

Commit:
```bash
cd .worktrees/feature/backend
git add .
git commit -m "feat: implement FastAPI Todo API with in-memory storage and tests"
```

Report: files changed + test results summary.
```

**Frontend subagent prompt:**
```
You are a frontend developer implementing a React Todo UI.

Working directory: .worktrees/feature/frontend/demo/frontend/src

Implement the complete Todo app in App.jsx:

- Fetch task list from GET /tasks on mount (use useEffect)
- Show each task as a list item with: title, a checkbox for completed status, a delete button
- Form at the top with a text input and "Add" button → POST /tasks with {title: inputValue}
- Clicking checkbox → PUT /tasks/{id} to toggle completion, update UI
- Clicking delete → DELETE /tasks/{id}, remove from list
- Show loading state while fetching
- API_BASE constant is already defined as '/tasks' — use it for all requests

Style: inline styles only, keep it minimal but readable. No CSS files, no external libraries.

Run to verify no syntax errors:
```bash
cd .worktrees/feature/frontend/demo/frontend
npm run build
```

Build must succeed with 0 errors.

Commit:
```bash
cd .worktrees/feature/frontend
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
  Terminal 1: cd .worktrees/feature/backend/demo/backend && uvicorn main:app --reload
  Terminal 2: cd .worktrees/feature/frontend/demo/frontend && npm run dev
  Browser:    http://localhost:5173
```

---

## Notes for Demo

- Steps 1 and 2 are the entire live demo — narrate what you see
- The parallel dispatch is the "wow" moment — two agents working simultaneously
- /code-review is intentionally left for the user to run manually so the audience sees it happen live
- Expected total time for both subagents: 5-8 minutes
- If one subagent fails, the other continues independently — that's the point of worktrees
```

**Step 2: Verify**

```bash
head -5 .claude/skills/demo-build/SKILL.md
```

Expected: frontmatter with `name: demo-build`

**Step 3: Commit**

```bash
git add .claude/skills/demo-build/
git commit -m "feat: add demo-build parallel orchestrator skill"
```

---

## Task 6: Demo Script

**Files:**
- Create: `docs/demo-script.md`

**Step 1: Create `docs/demo-script.md`**

```markdown
# DemoDay Script — Skills & Agent Claude Code
## 10 minutos | Sin slides | El código habla

---

## Acto 1 — Intro (1.5 min)

### Comandos en terminal:
```bash
ls -la                           # repo casi vacío
cat CLAUDE.md                    # estándares que el agente va a seguir
cat docs/WORKFLOW.md             # diagrama del flujo
ls .claude/skills/               # skills disponibles
```

### Lo que dices:
> "El equipo usa Cursor — funciona, es pair programming asistido.
> Yo uso Claude Code. La diferencia no es el modelo,
> es el paradigma: un agente autónomo que trabaja mientras tú lo observas.
> Este repo tiene un skeleton vacío. Voy a escribir un solo comando
> y dos agentes van a construir el backend y el frontend en paralelo,
> en ramas separadas, sin que yo escriba una línea de código."

### Muestra el skeleton:
```bash
cat demo/backend/main.py         # solo stubs vacíos
cat demo/frontend/src/App.jsx    # solo estructura vacía
cat .claude/skills/demo-build/SKILL.md | head -20
```

> "Este skill convierte a Claude Code en un orquestador.
> Al invocarlo, despacha dos subagentes simultáneamente —
> uno por rama — usando el Task tool."

---

## Acto 2 — Demo en vivo (6.5 min)

### El único comando que escribes:
```
/demo-build
```

### Lo que narras mientras los agentes trabajan:

**Cuando crea los worktrees:**
> "Está creando dos directorios de trabajo aislados.
> Git worktrees: mismo repositorio, dos branches diferentes,
> sin interferirse. Es como tener dos desarrolladores
> trabajando en el mismo repo al mismo tiempo."

**Cuando despacha los subagentes en paralelo:**
> "Aquí está el momento clave — está lanzando los dos agentes
> en el mismo mensaje. El backend agent va a implementar
> FastAPI con endpoints y tests. El frontend agent va a
> construir el React UI. Simultáneamente. Yo no escribo nada."

**Mientras trabajan (pausa natural):**
> "Esto es lo que diferencia un agente de un autocomplete.
> El agente tiene contexto completo: lee el CLAUDE.md,
> entiende los estándares, planifica los archivos,
> escribe los tests primero, implementa, verifica, commitea.
> Todo de forma autónoma."

**Cuando terminan:**
```bash
git log --oneline --all          # muestra commits en ambas ramas
```
> "Dos ramas, dos commits, cero intervención manual."

---

## Acto 3 — Code Review en vivo (2 min)

### Lo que dices antes de invocar:
> "Ahora viene la parte que aplico en producción —
> el agente de code review. Va a tomar el backend,
> correr el formatter, el linter, los tests,
> y si encuentra algo que no cumple los estándares
> del CLAUDE.md... lo corrige solo."

### El comando:
```
/code-review
```

### Lo que narras:
> "Está corriendo ruff format, ruff check, pytest.
> Si hay algo fuera de estándar lo va a corregir
> con el Edit tool — nunca sed, nunca awk,
> siempre entendiendo el código antes de tocarlo."

### Cuando termina, muestra el resultado:
```bash
cd .worktrees/feature/backend/demo/backend
uvicorn main:app --reload &
# Segunda terminal:
cd .worktrees/feature/frontend/demo/frontend
npm run dev
# Browser: http://localhost:5173
```

---

## Acto 4 — Cierre (30 seg)

> "Dos agentes en paralelo, code review automatizado,
> estándares definidos en CLAUDE.md, branches aisladas.
> El workflow completo que uso a diario: brainstorming →
> plan → execute → code-review.
> Los skills son reusables. El CLAUDE.md viaja con el repo.
> La pregunta no es si usar IA — es qué nivel de
> autonomía le das."

---

## Fallback si algo falla

**Si /demo-build se traba:**
- Muestra `docs/WORKFLOW.md` — el diagrama explica el concepto
- Muestra `.claude/skills/demo-build/SKILL.md` — el skill es el código

**Si un subagente falla:**
- El otro sigue — ese es el punto de los worktrees independientes
- Di: "Esto es un worktree aislado — el fallo en una rama no afecta la otra"

**Si /code-review no encuentra nada que corregir:**
- Es el mejor escenario — significa que el agente de backend ya escribió código limpio
- Di: "Ya salió limpio — el subagente de backend siguió los estándares del CLAUDE.md"
```

**Step 2: Commit**

```bash
git add docs/demo-script.md
git commit -m "docs: add 10-minute DemoDay presentation script"
```

---

## Task 7: Update README

**Files:**
- Modify: `README.md`

**Step 1: Replace README content**

```markdown
# Skills & Agent Claude Code
### DemoDay — Creai Tech

> De pair programming a trabajo multi-agente autónomo en paralelo.

---

## El Demo

Un orquestador despacha dos subagentes simultáneamente:
uno construye el backend FastAPI, otro construye el frontend React,
cada uno en su propia rama. Al finalizar, el usuario invoca
`/code-review` en vivo para validar calidad sobre el backend.

```bash
/demo-build      # lanza ambos agentes en paralelo
/code-review     # valida calidad del backend en vivo
```

## Estructura

```
.claude/
  skills/
    demo-build/      # Orquestador — 2 subagentes en paralelo
    code-review/     # Code review: ruff + pytest

demo/
  backend/           # FastAPI skeleton → subagente lo completa
    main.py
    requirements.txt
    tests/
  frontend/          # React skeleton → subagente lo completa
    src/App.jsx
    package.json

docs/
  WORKFLOW.md        # Diagrama del flujo completo
  demo-script.md     # Guión de 10 minutos
  plans/             # Plan de implementación de este repo
```

## Workflow del Demo

```
/demo-build
    ↓
[Worktree: feature/backend]    [Worktree: feature/frontend]
         ↓                               ↓
[Subagente: Backend]           [Subagente: Frontend]
  FastAPI + tests                 React UI + CRUD
         ↓                               ↓
         └──────────── ✅ ──────────────┘
                       ↓
              /code-review (manual)
                       ↓
          ruff + pytest → fixes → commit
                       ↓
        uvicorn + npm run dev → app running
```

## Skills Globales del Workflow Diario

| Skill | Propósito |
|-------|-----------|
| `/brainstorming` | Diseñar antes de codear |
| `/writing-plans` | Plan TDD detallado |
| `/executing-plans` | Ejecutar con checkpoints |
| `/systematic-debugging` | Root cause → fix → verify |
| `/using-git-worktrees` | Aislamiento por feature |
| `/finishing-a-development-branch` | Merge + cleanup |
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: update README as presentation entry point"
```

---

## Verification Checklist

Correr esto el día anterior a la presentación:

```bash
# 1. .worktrees está ignorado
git check-ignore -q .worktrees && echo "OK" || echo "FAIL"

# 2. Backend deps instaladas
pip install -r demo/backend/requirements.txt && echo "OK"

# 3. Backend skeleton arranca
cd demo/backend && uvicorn main:app &
sleep 2 && curl -s http://127.0.0.1:8000/openapi.json | grep "Todo API" && echo "OK"
pkill -f "uvicorn main:app"

# 4. Frontend deps instaladas
cd demo/frontend && npm install && echo "OK"

# 5. Frontend skeleton compila
npm run build && echo "OK"

# 6. Skills existen
ls .claude/skills/demo-build/SKILL.md && echo "OK"
ls .claude/skills/code-review/SKILL.md && echo "OK"

# 7. Git log limpio
git log --oneline
```

Todos deben terminar con "OK".

---

## Execution Order

```
Task 1 → Task 2 → Task 3 → Task 4 → Task 5 → Task 6 → Task 7
foundation → code-review skill → backend skeleton → frontend skeleton → orchestrator → script → readme
```

Tasks 3 y 4 pueden ejecutarse en paralelo.
Tasks 5 depende de Tasks 3 y 4 (el orchestrator referencia ambos skeletons).
