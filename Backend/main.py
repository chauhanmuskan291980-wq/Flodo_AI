from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from database import get_db, engine, Base
from models import Task
from schemas import TaskCreate

app = FastAPI()

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