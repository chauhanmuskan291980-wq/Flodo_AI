from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from database import get_db, engine, Base
from sqlalchemy import select
from models import Task
from schemas import TaskCreate
import models
import schemas
from fastapi.middleware.cors import CORSMiddleware
app = FastAPI();

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allows all sites (like your Flutter Web app)
    allow_credentials=True,
    allow_methods=["*"], # Allows POST, GET, etc.
    allow_headers=["*"], # Allows all headers
)

# Automatically creates tables in Postgres on startup
@app.on_event("startup")
async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

@app.post("/api/tasks")
async def add_new_task(task_in: TaskCreate, db: AsyncSession = Depends(get_db)):
    try:
        # Convert Pydantic to Dictionary
        new_task = Task(**task_in.model_dump()) 
        
        db.add(new_task)
        await db.commit()
        await db.refresh(new_task)
        return new_task
    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/api/tasks")
async def get_tasks(db: AsyncSession = Depends(get_db)):
    from sqlalchemy import select
    result = await db.execute(select(Task))
    return result.scalars().all()


@app.delete("/api/tasks/{task_id}")
async def delete_task(task_id: int, db: AsyncSession = Depends(get_db)):
    # 1. Check if task exists using Async select
    result = await db.execute(select(models.Task).filter(models.Task.id == task_id))
    db_task = result.scalars().first()
    
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    # 2. Delete the object
    await db.delete(db_task)
    await db.commit()
    return {"message": "Task deleted successfully"}


@app.patch("/api/tasks/{task_id}")
async def update_task_desc(task_id: int, task_update: schemas.TaskUpdate, db: AsyncSession = Depends(get_db)):
    # 1. Find the task
    result = await db.execute(select(models.Task).filter(models.Task.id == task_id))
    db_task = result.scalars().first()
    
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    # 2. Get the data sent from Flutter (ignoring nulls)
    update_data = task_update.model_dump(exclude_unset=True)
    
    # 3. Update only the fields provided
    for key, value in update_data.items():
        setattr(db_task, key, value)
        
    await db.commit()
    await db.refresh(db_task)
    return db_task