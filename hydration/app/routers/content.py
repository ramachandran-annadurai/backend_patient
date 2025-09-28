from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timedelta

from app.database import get_db
from app.models import User, EducationalContent
from app.schemas import EducationalContent as EducationalContentSchema
from app.core.security import get_current_active_user
from app.services.notification_service import notification_service

router = APIRouter()

@router.get("/motivational")
async def get_motivational_messages(
    current_user: User = Depends(get_current_active_user)
):
    """Get motivational messages for the user"""
    messages = notification_service.get_motivational_messages()
    
    # Filter based on pregnancy week if available
    if current_user.pregnancy_week:
        if current_user.pregnancy_week > 30:
            # Third trimester specific messages
            messages = [msg for msg in messages if "baby" in msg.lower() or "third" in msg.lower()]
        elif current_user.pregnancy_week > 20:
            # Second trimester specific messages
            messages = [msg for msg in messages if "baby" in msg.lower() or "second" in msg.lower()]
    
    return {
        "messages": messages[:3],  # Return top 3 messages
        "pregnancy_week": current_user.pregnancy_week
    }

@router.get("/educational")
async def get_educational_tips(
    current_user: User = Depends(get_current_active_user)
):
    """Get educational hydration tips"""
    tips = notification_service.get_educational_tips()
    
    # Filter based on pregnancy week if available
    if current_user.pregnancy_week:
        if current_user.pregnancy_week > 30:
            # Third trimester specific tips
            tips = [tip for tip in tips if "swelling" in tip.lower() or "third" in tip.lower()]
        elif current_user.pregnancy_week > 20:
            # Second trimester specific tips
            tips = [tip for tip in tips if "growth" in tip.lower() or "second" in tip.lower()]
        else:
            # First trimester specific tips
            tips = [tip for tip in tips if "morning sickness" in tip.lower() or "first" in tip.lower()]
    
    return {
        "tips": tips[:3],  # Return top 3 tips
        "pregnancy_week": current_user.pregnancy_week
    }

@router.get("/content", response_model=List[EducationalContentSchema])
async def get_educational_content(
    content_type: Optional[str] = None,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get educational content based on user's pregnancy week"""
    query = db.query(EducationalContent).filter(EducationalContent.is_active == True)
    
    # Filter by content type if specified
    if content_type:
        query = query.filter(EducationalContent.content_type == content_type)
    
    # Filter by pregnancy week
    if current_user.pregnancy_week:
        query = query.filter(
            (EducationalContent.pregnancy_week_min.is_(None)) |
            (EducationalContent.pregnancy_week_min <= current_user.pregnancy_week)
        ).filter(
            (EducationalContent.pregnancy_week_max.is_(None)) |
            (EducationalContent.pregnancy_week_max >= current_user.pregnancy_week)
        )
    
    content = query.order_by(EducationalContent.created_at.desc()).limit(10).all()
    return content

@router.post("/send-motivation")
async def send_motivational_message(
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_active_user)
):
    """Send a motivational message to the user"""
    messages = notification_service.get_motivational_messages()
    
    # Select a random message
    import random
    message = random.choice(messages)
    
    # Send in background
    background_tasks.add_task(
        notification_service.send_motivational_message,
        current_user.id,
        message
    )
    
    return {"message": "Motivational message sent", "content": message}

@router.post("/send-education")
async def send_educational_content(
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_active_user)
):
    """Send educational content to the user"""
    tips = notification_service.get_educational_tips()
    
    # Select a random tip
    import random
    tip = random.choice(tips)
    
    # Send in background
    background_tasks.add_task(
        notification_service.send_educational_content,
        current_user.id,
        "Hydration Tip",
        tip
    )
    
    return {"message": "Educational content sent", "content": tip}

@router.get("/daily-content")
async def get_daily_content(
    current_user: User = Depends(get_current_active_user)
):
    """Get personalized daily content (motivational + educational)"""
    # Get motivational message
    messages = notification_service.get_motivational_messages()
    import random
    motivational = random.choice(messages)
    
    # Get educational tip
    tips = notification_service.get_educational_tips()
    educational = random.choice(tips)
    
    # Get pregnancy-specific content
    pregnancy_content = None
    if current_user.pregnancy_week:
        if current_user.pregnancy_week > 30:
            pregnancy_content = "Third trimester: Your baby is almost here! Stay hydrated to support the final growth spurt and prepare for labor."
        elif current_user.pregnancy_week > 20:
            pregnancy_content = "Second trimester: Your baby is growing rapidly. Extra hydration helps support this important development phase."
        else:
            pregnancy_content = "First trimester: Even mild dehydration can worsen morning sickness. Small, frequent sips of water can help."
    
    return {
        "motivational": motivational,
        "educational": educational,
        "pregnancy_specific": pregnancy_content,
        "pregnancy_week": current_user.pregnancy_week,
        "date": datetime.utcnow().isoformat()
    }

@router.get("/content/{content_id}", response_model=EducationalContentSchema)
async def get_content_by_id(
    content_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get specific educational content by ID"""
    content = db.query(EducationalContent).filter(
        EducationalContent.id == content_id,
        EducationalContent.is_active == True
    ).first()
    
    if not content:
        raise HTTPException(
            status_code=404,
            detail="Content not found"
        )
    
    return content

