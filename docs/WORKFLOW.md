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
