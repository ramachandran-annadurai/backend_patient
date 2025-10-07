#!/usr/bin/env python3
"""
AUTO PREGNANCY WEEK UPDATE - METHOD 1 IMPLEMENTATION
Complete implementation for automatic pregnancy week updates
"""

# ============================================================================
# STEP 1: ADD THIS FUNCTION TO YOUR app_simple.py
# Add this function anywhere in your app_simple.py file (before the profile endpoint)
# ============================================================================

def calculate_current_pregnancy_week(last_period_date_str):
    """
    Calculate current pregnancy week based on last period date
    
    Args:
        last_period_date_str (str): Last period date in 'YYYY-MM-DD' format
    
    Returns:
        dict: Pregnancy information including current week, expected delivery, etc.
    """
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

# ============================================================================
# STEP 2: REPLACE YOUR EXISTING PROFILE ENDPOINT
# Find this in your app_simple.py and replace it completely:
# @app.route('/profile/<patient_id>', methods=['GET'])
# def get_profile(patient_id):
#     # Your existing code...
# ============================================================================

@app.route('/profile/<patient_id>', methods=['GET'])
@token_required
def get_profile(patient_id):
    """
    Get patient profile information with automatically calculated pregnancy week
    
    This endpoint automatically calculates and updates the pregnancy week
    every time the profile is accessed, ensuring it's always current.
    """
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

# ============================================================================
# STEP 3: OPTIONAL - ADD MANUAL UPDATE ENDPOINT
# Add this endpoint after your profile endpoint
# ============================================================================

@app.route('/api/pregnancy/update-week/<patient_id>', methods=['POST'])
@token_required
def update_patient_pregnancy_week(patient_id):
    """
    Manually update pregnancy week for a specific patient
    
    This endpoint can be called to force an update of the pregnancy week
    without accessing the full profile.
    """
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

# ============================================================================
# IMPLEMENTATION INSTRUCTIONS
# ============================================================================

"""
IMPLEMENTATION STEPS:

1. ADD THE FUNCTION:
   - Copy the calculate_current_pregnancy_week() function
   - Add it anywhere in your app_simple.py file (before the profile endpoint)

2. REPLACE THE PROFILE ENDPOINT:
   - Find your existing @app.route('/profile/<patient_id>', methods=['GET'])
   - Replace the entire function with the new get_profile() function above

3. OPTIONAL - ADD MANUAL UPDATE ENDPOINT:
   - Add the update_patient_pregnancy_week() function
   - This allows manual triggering of pregnancy week updates

4. TEST THE IMPLEMENTATION:
   - Call GET /profile/<patient_id> for a pregnant patient
   - Check that pregnancy_week is automatically calculated and updated
   - Verify the database is updated with the new pregnancy week

HOW IT WORKS:

1. When someone calls GET /profile/<patient_id>
2. System checks if patient is pregnant and has last_period_date
3. If yes, calculates current pregnancy week based on today's date
4. Updates the database with the new pregnancy week
5. Returns the profile with the updated pregnancy week

BENEFITS:

✅ No additional API calls needed
✅ Automatic updates every time profile is accessed
✅ Always current pregnancy week
✅ No scheduled tasks or background processes needed
✅ Works with existing frontend code

TESTING:

1. Get a pregnant patient's profile:
   curl -H "Authorization: Bearer YOUR_TOKEN" \
        http://localhost:8000/profile/PAT123

2. Check the response includes updated pregnancy_week

3. Call again after a few days to see the week has increased
"""


