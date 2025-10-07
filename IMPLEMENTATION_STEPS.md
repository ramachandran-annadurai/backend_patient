# 🤰 Auto Pregnancy Week Update - Implementation Steps

## 📋 Overview
This guide shows you exactly how to implement automatic pregnancy week updates using Method 1 (Real-time Calculation) as discussed in our last chat.

## 🚀 Quick Implementation (3 Steps)

### Step 1: Add the Calculation Function
Add this function to your `app_simple.py` file (anywhere before the profile endpoint):

```python
def calculate_current_pregnancy_week(last_period_date_str):
    """Calculate current pregnancy week based on last period date"""
    try:
        from datetime import datetime, timedelta
        
        last_period = datetime.strptime(last_period_date_str, '%Y-%m-%d')
        today = datetime.now()
        
        # Validate that last period date is not in the future
        if last_period > today:
            return {
                'error': 'Last period date cannot be in the future',
                'current_week': None,
                'expected_delivery': None
            }
        
        # Calculate pregnancy week (gestational age)
        days_diff = (today - last_period).days
        current_week = max(1, min(42, days_diff // 7))
        
        # Calculate expected delivery date (40 weeks from last period)
        expected_delivery = last_period + timedelta(weeks=40)
        expected_delivery_str = expected_delivery.strftime('%Y-%m-%d')
        
        return {
            'current_week': current_week,
            'expected_delivery': expected_delivery_str,
            'days_pregnant': days_diff,
            'last_updated': today.isoformat(),
            'error': None
        }
    except Exception as e:
        print(f"Error calculating pregnancy week: {e}")
        return {
            'error': f'Error calculating pregnancy week: {str(e)}',
            'current_week': None,
            'expected_delivery': None
        }
```

### Step 2: Replace Your Profile Endpoint
Find this in your `app_simple.py`:
```python
@app.route('/profile/<patient_id>', methods=['GET'])
def get_profile(patient_id):
    # Your existing code...
```

Replace it with this:
```python
@app.route('/profile/<patient_id>', methods=['GET'])
@token_required
def get_profile(patient_id):
    """Get patient profile information with automatically calculated pregnancy week"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        # Get patient from database
        patient = db.patients_collection.find_one({"patient_id": patient_id})
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        # Auto-calculate pregnancy week if patient is pregnant and has last_period_date
        if (patient.get('is_pregnant', False) and 
            patient.get('last_period_date')):
            
            print(f"🤰 Auto-calculating pregnancy week for patient {patient_id}")
            
            pregnancy_info = calculate_current_pregnancy_week(patient['last_period_date'])
            
            if pregnancy_info and not pregnancy_info.get('error'):
                # Update the patient document with current pregnancy info
                update_data = {
                    'pregnancy_week': pregnancy_info['current_week'],
                    'expected_delivery_date': pregnancy_info['expected_delivery'],
                    'pregnancy_last_updated': pregnancy_info['last_updated']
                }
                
                # Update in database
                db.patients_collection.update_one(
                    {"patient_id": patient_id},
                    {"$set": update_data}
                )
                
                # Add to response
                patient.update(update_data)
                
                print(f"✅ Updated pregnancy week for {patient_id}: Week {pregnancy_info['current_week']}")
            else:
                print(f"⚠️ Could not calculate pregnancy week for {patient_id}: {pregnancy_info.get('error', 'Unknown error')}")
        
        # Prepare response data
        response_data = {
            "patient_id": patient["patient_id"],
            "username": patient["username"],
            "email": patient["email"],
            "mobile": patient["mobile"],
            "first_name": patient.get("first_name"),
            "last_name": patient.get("last_name"),
            "age": patient.get("age"),
            "blood_type": patient.get("blood_type"),
            "is_pregnant": patient.get("is_pregnant"),
            "last_period_date": patient.get("last_period_date"),
            "pregnancy_week": patient.get("pregnancy_week"),
            "expected_delivery_date": patient.get("expected_delivery_date"),
            "pregnancy_last_updated": patient.get("pregnancy_last_updated"),
            "emergency_contact": patient.get("emergency_contact"),
            "preferences": patient.get("preferences")
        }
        
        return jsonify({
            "success": True,
            "patient": response_data,
            "message": "Profile retrieved with auto-calculated pregnancy week"
        }), 200
    
    except Exception as e:
        print(f"❌ Error in get_profile: {e}")
        return jsonify({"error": f"Failed to get profile: {str(e)}"}), 500
```

### Step 3: Optional - Add Manual Update Endpoint
Add this endpoint after your profile endpoint:

```python
@app.route('/api/pregnancy/update-week/<patient_id>', methods=['POST'])
@token_required
def update_patient_pregnancy_week(patient_id):
    """Manually update pregnancy week for a specific patient"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        # Get patient from database
        patient = db.patients_collection.find_one({"patient_id": patient_id})
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        if not patient.get('is_pregnant', False):
            return jsonify({"error": "Patient is not marked as pregnant"}), 400
        
        if not patient.get('last_period_date'):
            return jsonify({"error": "Patient is missing last period date"}), 400
        
        # Calculate current pregnancy week
        pregnancy_info = calculate_current_pregnancy_week(patient['last_period_date'])
        
        if pregnancy_info and not pregnancy_info.get('error'):
            # Update patient record
            update_data = {
                'pregnancy_week': pregnancy_info['current_week'],
                'expected_delivery_date': pregnancy_info['expected_delivery'],
                'pregnancy_last_updated': pregnancy_info['last_updated']
            }
            
            db.patients_collection.update_one(
                {"patient_id": patient_id},
                {"$set": update_data}
            )
            
            return jsonify({
                'success': True,
                'message': f'Pregnancy week updated to {pregnancy_info["current_week"]}',
                'pregnancy_info': pregnancy_info,
                'patient_id': patient_id
            }), 200
        else:
            return jsonify({
                'success': False,
                'message': f'Error calculating pregnancy week: {pregnancy_info.get("error", "Unknown error")}'
            }), 400
            
    except Exception as e:
        print(f"❌ Error updating pregnancy week: {e}")
        return jsonify({
            'success': False,
            'message': f'Error updating pregnancy week: {str(e)}'
        }), 500
```

## ✅ How It Works

1. **User calls** `GET /profile/<patient_id>` (your existing endpoint)
2. **System checks** if patient is pregnant and has `last_period_date`
3. **If yes**, calculates current pregnancy week based on today's date
4. **Updates database** with the new pregnancy week
5. **Returns profile** with the updated pregnancy week

## 🎯 Benefits

- ✅ **No additional API calls needed**
- ✅ **Automatic updates** every time profile is accessed
- ✅ **Always current** pregnancy week
- ✅ **No scheduled tasks** or background processes needed
- ✅ **Works with existing** frontend code

## 🧪 Testing

### Test 1: Check Auto-Calculation
```bash
# Get profile of a pregnant patient
curl -H "Authorization: Bearer YOUR_TOKEN" \
     http://localhost:8000/profile/PAT123

# Response should include:
# {
#   "success": true,
#   "patient": {
#     "pregnancy_week": 15,  // Auto-calculated
#     "expected_delivery_date": "2024-06-15",
#     "pregnancy_last_updated": "2024-01-27T10:30:00"
#   }
# }
```

### Test 2: Verify Database Update
Check your MongoDB to see that the patient document has been updated with the new pregnancy week.

### Test 3: Multiple Calls
Call the same endpoint multiple times - the pregnancy week should remain consistent (unless days have passed).

## 🔧 Troubleshooting

### Issue: Pregnancy week not updating
**Solution**: Check that:
1. Patient has `is_pregnant: true`
2. Patient has `last_period_date` in correct format (YYYY-MM-DD)
3. `last_period_date` is not in the future

### Issue: Error in calculation
**Solution**: Check the console logs for error messages and verify the date format.

### Issue: Database not updating
**Solution**: Verify database connection and check MongoDB logs.

## 📊 Expected Results

After implementation:
- Every time someone accesses a pregnant patient's profile
- The pregnancy week will be automatically calculated and updated
- The database will contain the current pregnancy week
- The API response will include the updated information

**No additional API calls or frontend changes needed!** 🎉


