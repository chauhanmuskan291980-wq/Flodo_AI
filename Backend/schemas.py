from pydantic import BaseModel, ConfigDict
from typing import List, Optional, Any

class TaskCreate(BaseModel):
    title: str
    iconData: Optional[int] = None
    bgColor: Optional[str] = None
    iconColor: Optional[str] = None
    btnColor: Optional[str] = None
    left: int = 0
    done: int = 0
    desc: List[dict[str, Any]] = []

    # Allows Pydantic to read SQLAlchemy models
    model_config = ConfigDict(from_attributes=True)