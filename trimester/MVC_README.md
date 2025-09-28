# Pregnancy API - MVC Architecture

This project has been refactored to follow the Model-View-Controller (MVC) pattern for better code organization, maintainability, and scalability.

## Directory Structure

```
trimester/
├── app/                          # Main application package
│   ├── __init__.py
│   ├── main.py                   # FastAPI application factory
│   ├── dependencies.py           # Dependency injection container
│   ├── models/                   # Data models (MVC Models)
│   │   ├── __init__.py
│   │   └── pregnancy_models.py   # Pydantic models for data validation
│   ├── views/                    # Controllers (MVC Views/Controllers)
│   │   ├── __init__.py
│   │   ├── pregnancy_controller.py  # Main pregnancy data endpoints
│   │   ├── openai_controller.py     # OpenAI-powered endpoints
│   │   └── image_controller.py      # Image generation endpoints
│   ├── services/                 # Business logic (MVC Services)
│   │   ├── __init__.py
│   │   ├── pregnancy_data_service.py  # Pregnancy data management
│   │   ├── openai_service.py         # OpenAI integration
│   │   └── baby_image_service.py     # Image generation logic
│   └── config/                   # Configuration
│       ├── __init__.py
│       └── settings.py           # Application settings
├── main_mvc.py                   # New MVC entry point
├── main.py                       # Original entry point (kept for compatibility)
└── requirements.txt
```

## MVC Components

### Models (`app/models/`)
- **Purpose**: Define data structures and validation rules
- **Files**: `pregnancy_models.py`
- **Contains**: Pydantic models for API request/response validation
- **Examples**: `PregnancyWeek`, `BabySize`, `SymptomInfo`, etc.

### Views/Controllers (`app/views/`)
- **Purpose**: Handle HTTP requests and responses (API endpoints)
- **Files**: 
  - `pregnancy_controller.py` - Core pregnancy data endpoints
  - `openai_controller.py` - AI-powered features
  - `image_controller.py` - Image generation endpoints
- **Responsibilities**:
  - Route handling
  - Request validation
  - Response formatting
  - Error handling
  - Dependency injection

### Services (`app/services/`)
- **Purpose**: Business logic and data processing
- **Files**:
  - `pregnancy_data_service.py` - Pregnancy data management
  - `openai_service.py` - OpenAI API integration
  - `baby_image_service.py` - Image generation logic
- **Responsibilities**:
  - Data processing
  - External API calls
  - Business rules
  - Data transformation

### Configuration (`app/config/`)
- **Purpose**: Application settings and environment configuration
- **Files**: `settings.py`
- **Contains**: Environment variables, API keys, server settings

## Key Features

### 1. Dependency Injection
- Centralized dependency management in `app/dependencies.py`
- Lazy loading of services
- Easy testing and mocking

### 2. Separation of Concerns
- **Models**: Data structure and validation
- **Controllers**: HTTP handling and routing
- **Services**: Business logic and external integrations

### 3. Modular Design
- Each controller handles a specific domain
- Services are independent and reusable
- Easy to add new features

### 4. Error Handling
- Centralized error handling in controllers
- Proper HTTP status codes
- Consistent error response format

## Running the Application

### Using the new MVC structure:
```bash
python main_mvc.py
```

### Using the original structure (for compatibility):
```bash
python main.py
```

## API Endpoints

The API endpoints remain the same as before:

- `GET /` - API information
- `GET /health` - Health check
- `GET /pregnancy/week/{week}` - Get pregnancy week data
- `GET /pregnancy/weeks` - Get all weeks
- `GET /pregnancy/week/{week}/developments` - Get week developments
- `GET /pregnancy/trimester/{trimester}` - Get trimester weeks
- `GET /pregnancy/week/{week}/baby-size` - AI-powered baby size
- `GET /pregnancy/week/{week}/symptoms` - AI-powered symptoms
- `GET /pregnancy/week/{week}/screening` - AI-powered screening
- `GET /pregnancy/week/{week}/wellness` - AI-powered wellness tips
- `GET /pregnancy/week/{week}/nutrition` - AI-powered nutrition tips
- `GET /pregnancy/week/{week}/baby-image` - Baby size visualization

## Benefits of MVC Architecture

1. **Maintainability**: Clear separation makes code easier to understand and modify
2. **Testability**: Each component can be tested independently
3. **Scalability**: Easy to add new features without affecting existing code
4. **Reusability**: Services can be reused across different controllers
5. **Organization**: Code is logically organized and easy to navigate
6. **Dependency Management**: Centralized dependency injection makes testing easier

## Migration Notes

- Original `main.py` is preserved for backward compatibility
- All existing functionality is maintained
- New `main_mvc.py` provides the MVC version
- API endpoints and responses remain unchanged
- Configuration and environment variables work the same way
