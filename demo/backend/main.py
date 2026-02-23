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
