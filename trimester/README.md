# Pregnancy Week Development API

A FastAPI application that provides detailed information about pregnancy weeks, including key developments, baby size, symptoms, and tips.

## Features

- Get detailed information for any pregnancy week (1-40)
- Key developments for each week with descriptions and icons
- Baby size comparisons and measurements
- Common symptoms and wellness tips
- Trimester-based filtering
- RESTful API with comprehensive documentation

## Installation

1. Install the required dependencies:
```bash
pip install -r requirements.txt
```

2. Create a `.env` file with your configuration:
```env
# OpenAPI Configuration
OPENAPI_BASE_URL=https://api.pregnancy.com/v1
OPENAPI_API_KEY=your_api_key_here
OPENAPI_TIMEOUT=30

# FastAPI Configuration
HOST=0.0.0.0
PORT=8000
DEBUG=True
```

## Running the Application

1. Start the FastAPI server:
```bash
python main.py
```

2. Or use uvicorn directly:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

3. Access the API documentation at: http://localhost:8000/docs

## API Endpoints

### Get Pregnancy Week Information
- **GET** `/pregnancy/week/{week}`
- Get complete information for a specific pregnancy week
- Example: `GET /pregnancy/week/10`

### Get All Pregnancy Weeks
- **GET** `/pregnancy/weeks`
- Get information for all available pregnancy weeks

### Get Week Developments Only
- **GET** `/pregnancy/week/{week}/developments`
- Get only the key developments for a specific week

### Get Trimester Weeks
- **GET** `/pregnancy/trimester/{trimester}`
- Get all weeks for a specific trimester (1, 2, or 3)

### Health Check
- **GET** `/health`
- Check if the API is running

## Example Response

```json
{
  "success": true,
  "data": {
    "week": 10,
    "trimester": 1,
    "days_remaining": 217,
    "baby_size": {
      "size": "Coconut",
      "weight": "0.1g",
      "length": "0.6cm"
    },
    "key_developments": [
      {
        "title": "Healthy Organ Growth",
        "description": "Vital organs are fully developed and functioning.",
        "icon": "❤️",
        "category": "organs"
      },
      {
        "title": "Finger & Toe Development",
        "description": "Eyebrows and eyelids are now fully present.",
        "icon": "👁️",
        "category": "facial"
      },
      {
        "title": "Teeth Formation Begins",
        "description": "Teeth are starting to form under the gums.",
        "icon": "🦷",
        "category": "dental"
      }
    ],
    "symptoms": ["Morning sickness easing", "Breast growth", "Mood stabilization"],
    "tips": ["Continue prenatal vitamins", "Eat balanced meals", "Stay active"]
  },
  "message": "Successfully retrieved data for week 10"
}
```

## Configuration

The application uses environment variables for configuration. You can modify the `.env` file to change:

- API host and port
- Debug mode
- OpenAPI integration settings
- Database configuration

## Development

To add more pregnancy week data, modify the `pregnancy_data.py` file and add new week entries to the `_initialize_data()` method.

## License

This project is open source and available under the MIT License.
