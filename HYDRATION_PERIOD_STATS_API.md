# 💧 Hydration Period Stats API Documentation

## 🎯 **New Period-Specific Hydration Statistics Endpoints**

I've created three separate endpoints for different time periods to give you detailed hydration statistics:

## 📅 **1. Daily Hydration Stats**

### **Endpoint:**
```
GET /api/hydration/stats/daily
```

### **Parameters:**
- `date` (optional): Date in YYYY-MM-DD format (defaults to today)

### **Example Requests:**
```bash
# Today's stats
GET {{baseUrl}}/api/hydration/stats/daily

# Specific date stats
GET {{baseUrl}}/api/hydration/stats/daily?date=2024-01-15
```

### **Response Format:**
```json
{
  "success": true,
  "data": {
    "patient_id": "PAT1759141374B65D62",
    "date": "2024-01-15",
    "period": "daily",
    "total_intake_ml": 1500,
    "total_intake_oz": 50.7,
    "goal_ml": 2000,
    "goal_oz": 67.6,
    "goal_percentage": 75.0,
    "remaining_ml": 500,
    "remaining_oz": 16.9,
    "intake_by_type": {
      "water": 1000,
      "tea": 300,
      "coffee": 200
    },
    "record_count": 5,
    "records": [...]
  },
  "message": "Daily hydration stats retrieved successfully for 2024-01-15"
}
```

## 📊 **2. Weekly Hydration Stats**

### **Endpoint:**
```
GET /api/hydration/stats/weekly
```

### **Parameters:**
- `date` (optional): Any date in YYYY-MM-DD format (defaults to current week)

### **Example Requests:**
```bash
# Current week stats
GET {{baseUrl}}/api/hydration/stats/weekly

# Week containing specific date
GET {{baseUrl}}/api/hydration/stats/weekly?date=2024-01-15
```

### **Response Format:**
```json
{
  "success": true,
  "data": {
    "patient_id": "PAT1759141374B65D62",
    "week_start": "2024-01-15",
    "week_end": "2024-01-21",
    "period": "weekly",
    "total_intake_ml": 10500,
    "total_intake_oz": 355.0,
    "goal_ml": 14000,
    "goal_oz": 473.2,
    "goal_percentage": 75.0,
    "remaining_ml": 3500,
    "remaining_oz": 118.2,
    "intake_by_type": {
      "water": 7000,
      "tea": 2100,
      "coffee": 1400
    },
    "record_count": 35,
    "daily_breakdown": [
      {
        "date": "2024-01-15",
        "total_ml": 1500,
        "total_oz": 50.7,
        "record_count": 5,
        "intake_by_type": {"water": 1000, "tea": 300, "coffee": 200}
      }
    ],
    "average_daily_ml": 1500.0,
    "average_daily_oz": 50.7
  },
  "message": "Weekly hydration stats retrieved successfully for week 2024-01-15 to 2024-01-21"
}
```

## 📈 **3. Monthly Hydration Stats**

### **Endpoint:**
```
GET /api/hydration/stats/monthly
```

### **Parameters:**
- `date` (optional): Any date in YYYY-MM-DD format (defaults to current month)

### **Example Requests:**
```bash
# Current month stats
GET {{baseUrl}}/api/hydration/stats/monthly

# Month containing specific date
GET {{baseUrl}}/api/hydration/stats/monthly?date=2024-01-15
```

### **Response Format:**
```json
{
  "success": true,
  "data": {
    "patient_id": "PAT1759141374B65D62",
    "month_start": "2024-01-01",
    "month_end": "2024-01-31",
    "period": "monthly",
    "total_intake_ml": 45000,
    "total_intake_oz": 1521.0,
    "goal_ml": 62000,
    "goal_oz": 2095.6,
    "goal_percentage": 72.6,
    "remaining_ml": 17000,
    "remaining_oz": 574.6,
    "intake_by_type": {
      "water": 30000,
      "tea": 9000,
      "coffee": 6000
    },
    "record_count": 150,
    "weekly_breakdown": [
      {
        "week": "Week 1",
        "total_ml": 10500,
        "total_oz": 355.0,
        "record_count": 35,
        "intake_by_type": {"water": 7000, "tea": 2100, "coffee": 1400}
      }
    ],
    "average_daily_ml": 1451.6,
    "average_daily_oz": 49.1,
    "days_in_month": 31
  },
  "message": "Monthly hydration stats retrieved successfully for January 2024"
}
```

## 🔧 **Key Features**

### **✅ Smart Date Handling:**
- **Daily**: Shows stats for specific date
- **Weekly**: Shows stats for week containing the date
- **Monthly**: Shows stats for month containing the date

### **✅ Comprehensive Statistics:**
- Total intake (ML and OZ)
- Goal tracking and percentage
- Remaining amount needed
- Intake breakdown by type
- Record counts

### **✅ Detailed Breakdowns:**
- **Daily**: Individual records
- **Weekly**: Daily breakdown within the week
- **Monthly**: Weekly breakdown within the month

### **✅ Goal Calculations:**
- **Daily Goal**: Uses patient's daily goal
- **Weekly Goal**: Daily goal × 7
- **Monthly Goal**: Daily goal × days in month

## 🚀 **Usage Examples**

### **Frontend Integration:**
```javascript
// Get today's stats
const dailyStats = await fetch('/api/hydration/stats/daily', {
  headers: { 'Authorization': `Bearer ${token}` }
});

// Get this week's stats
const weeklyStats = await fetch('/api/hydration/stats/weekly', {
  headers: { 'Authorization': `Bearer ${token}` }
});

// Get this month's stats
const monthlyStats = await fetch('/api/hydration/stats/monthly', {
  headers: { 'Authorization': `Bearer ${token}` }
});
```

### **Postman Collection:**
```json
{
  "name": "Daily Hydration Stats",
  "request": {
    "method": "GET",
    "header": [
      {
        "key": "Authorization",
        "value": "Bearer {{token}}"
      }
    ],
    "url": {
      "raw": "{{baseUrl}}/api/hydration/stats/daily",
      "host": ["{{baseUrl}}"],
      "path": ["api", "hydration", "stats", "daily"]
    }
  }
}
```

## 🎯 **Benefits**

1. **Granular Analysis**: Get detailed stats for any time period
2. **Goal Tracking**: Monitor progress against daily/weekly/monthly goals
3. **Trend Analysis**: Compare performance across different periods
4. **Data Visualization**: Rich data structure for charts and graphs
5. **Patient Insights**: Detailed breakdowns help patients understand their habits

## ✅ **Ready to Use**

All three endpoints are now available and ready for testing! Use the test script `test_hydration_period_stats.py` to verify they're working correctly.

**Your hydration tracking system now has comprehensive period-specific statistics!** 💧📊





