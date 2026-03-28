from pydantic import BaseModel, ConfigDict
from typing import List, Optional, Any

class TaskCreate(BaseModel):
    title: str
    blocked_by: Optional[int] = None
    iconData: Optional[int] = None
    bgColor: Optional[str] = None
    iconColor: Optional[str] = None
    btnColor: Optional[str] = None
    left: int = 0
    done: int = 0
    desc: List[dict[str, Any]] = []

    # Allows Pydantic to read SQLAlchemy models
    model_config = ConfigDict(from_attributes=True)


class TaskUpdate(BaseModel):
    # All fields must be Optional for a PATCH request
    title: Optional[str] = None
    blocked_by: Optional[int] = None
    iconData: Optional[int] = None
    bgColor: Optional[str] = None
    iconColor: Optional[str] = None
    btnColor: Optional[str] = None
    left: Optional[int] = None
    done: Optional[int] = None
    desc: Optional[List[dict[str, Any]]] = None
    
    # Assignment Required Fields for Updates
    description: Optional[str] = None
    due_date: Optional[str] = None
    status: Optional[str] = None # "To-Do", "In Progress", or "Done" 

    model_config = ConfigDict(from_attributes=True)

 