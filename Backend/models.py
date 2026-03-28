from sqlalchemy.orm import Mapped, mapped_column 
from sqlalchemy import ForeignKey, String, Integer, Boolean
from sqlalchemy.dialects.postgresql import JSONB  # 🔹 Postgres Specific
from typing import Optional, List, Any
from database import Base

class Task(Base):
    __tablename__ = "tasks"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    title: Mapped[str] = mapped_column(String(100), nullable=False)
    blocked_by: Mapped[Optional[int]] = mapped_column(Integer, ForeignKey("tasks.id"), nullable=True)
    # Colors and Icons
    bgColor: Mapped[Optional[str]] = mapped_column(String(10))
    iconColor: Mapped[Optional[str]] = mapped_column(String(10))
    btnColor: Mapped[Optional[str]] = mapped_column(String(10))
    iconData: Mapped[Optional[int]] = mapped_column(Integer)
    
    # Progress
    left: Mapped[int] = mapped_column(Integer, default=0)
    done: Mapped[int] = mapped_column(Integer, default=0)
    isLast: Mapped[bool] = mapped_column(Boolean, default=False)

    # 🔹 Using JSONB for high performance in Postgres
    desc: Mapped[Optional[List[dict[str, Any]]]] = mapped_column(JSONB)