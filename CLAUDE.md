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
