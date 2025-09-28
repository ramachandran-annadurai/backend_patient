import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from main import app
from app.database import get_db, Base
from app.models import User, HydrationLog
from app.core.security import get_password_hash

# Test database setup
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)

@pytest.fixture
def test_user():
    """Create a test user"""
    db = TestingSessionLocal()
    
    # Create test user
    user = User(
        email="test@example.com",
        hashed_password=get_password_hash("testpassword"),
        first_name="Test",
        last_name="User",
        pregnancy_week=20,
        weight=65.0,
        height=165.0
    )
    
    db.add(user)
    db.commit()
    db.refresh(user)
    
    yield user
    
    # Cleanup
    db.delete(user)
    db.commit()
    db.close()

@pytest.fixture
def auth_headers(test_user):
    """Get authentication headers for test user"""
    # Login to get token
    response = client.post(
        "/api/v1/auth/login",
        data={"username": "test@example.com", "password": "testpassword"}
    )
    
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}

def test_register_user():
    """Test user registration"""
    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": "newuser@example.com",
            "password": "password123",
            "first_name": "New",
            "last_name": "User",
            "pregnancy_week": 15
        }
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == "newuser@example.com"
    assert data["first_name"] == "New"

def test_login_user():
    """Test user login"""
    # First register a user
    client.post(
        "/api/v1/auth/register",
        json={
            "email": "loginuser@example.com",
            "password": "password123",
            "first_name": "Login",
            "last_name": "User"
        }
    )
    
    # Then login
    response = client.post(
        "/api/v1/auth/login",
        data={"username": "loginuser@example.com", "password": "password123"}
    )
    
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"

def test_log_hydration_intake(auth_headers):
    """Test logging hydration intake"""
    response = client.post(
        "/api/v1/hydration/log",
        json={
            "amount_ml": 250,
            "drink_type": "water",
            "notes": "Test intake"
        },
        headers=auth_headers
    )
    
    assert response.status_code == 200
    data = response.json()
    assert data["amount_ml"] == 250
    assert data["drink_type"] == "water"

def test_get_today_summary(auth_headers):
    """Test getting today's hydration summary"""
    response = client.get("/api/v1/hydration/today", headers=auth_headers)
    
    assert response.status_code == 200
    data = response.json()
    assert "total_intake_ml" in data
    assert "goal_ml" in data
    assert "percentage_complete" in data

def test_get_hydration_logs(auth_headers):
    """Test getting hydration logs"""
    response = client.get("/api/v1/hydration/logs?days=7", headers=auth_headers)
    
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)

def test_get_current_goal(auth_headers):
    """Test getting current hydration goal"""
    response = client.get("/api/v1/hydration/goal", headers=auth_headers)
    
    assert response.status_code == 200
    data = response.json()
    assert "daily_goal_ml" in data
    assert "weather_adjustment" in data

def test_get_risk_score(auth_headers):
    """Test getting dehydration risk score"""
    response = client.get("/api/v1/alerts/risk-score", headers=auth_headers)
    
    assert response.status_code == 200
    data = response.json()
    assert "risk_score" in data
    assert "risk_level" in data
    assert "recommendations" in data

def test_get_motivational_content(auth_headers):
    """Test getting motivational content"""
    response = client.get("/api/v1/content/motivational", headers=auth_headers)
    
    assert response.status_code == 200
    data = response.json()
    assert "messages" in data
    assert isinstance(data["messages"], list)

def test_get_educational_tips(auth_headers):
    """Test getting educational tips"""
    response = client.get("/api/v1/content/educational", headers=auth_headers)
    
    assert response.status_code == 200
    data = response.json()
    assert "tips" in data
    assert isinstance(data["tips"], list)

def test_unauthorized_access():
    """Test that endpoints require authentication"""
    response = client.get("/api/v1/hydration/today")
    assert response.status_code == 401

def test_invalid_credentials():
    """Test login with invalid credentials"""
    response = client.post(
        "/api/v1/auth/login",
        data={"username": "invalid@example.com", "password": "wrongpassword"}
    )
    
    assert response.status_code == 401

