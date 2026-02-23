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
