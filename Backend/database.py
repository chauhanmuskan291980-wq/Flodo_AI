from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from sqlalchemy.orm import DeclarativeBase

# Format: postgresql+asyncpg://<user>:<password>@<host>:<port>/<dbname>
DATABASE_URL = "postgresql+asyncpg://postgres:muskan%21%21%21%4000%24@localhost:5432/taskdb"

engine = create_async_engine(DATABASE_URL, echo=True)

SessionLocal = async_sessionmaker(
    bind=engine, 
    class_=AsyncSession, 
    expire_on_commit=False
)

class Base(DeclarativeBase):
    pass

async def get_db():
    async with SessionLocal() as session:
        yield session