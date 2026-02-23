# Skills & Agent Claude Code
### DemoDay — Creai Tech

> De pair programming a trabajo multi-agente autónomo en paralelo.

---

## El Demo

Un orquestador despacha dos subagentes simultáneamente:
uno construye el backend FastAPI, otro construye el frontend React,
cada uno en su propia rama aislada. Al finalizar, el usuario invoca
`/code-review` en vivo para validar calidad sobre el backend.

```bash
/demo-build      # lanza ambos agentes en paralelo
/code-review     # valida calidad del backend en vivo
./run.sh         # arranca backend + frontend
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

run.sh             # Arranca backend + frontend desde los worktrees
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
                   ./run.sh
                       ↓
        localhost:8000 (API) + localhost:5173 (UI)
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
