# ============================================================================
# HYDRATION ENDPOINTS - Following Appointment Pattern
# ============================================================================

@app.route('/api/hydration/intake', methods=['POST'])
@token_required
def save_hydration_intake():
    """Save hydration intake record - following appointment pattern"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        data = request.get_json()
        patient_id = request.user_data['patient_id']
        
        # Validate required fields
        if not data or 'hydration_type' not in data or 'amount_ml' not in data:
            return jsonify({
                'success': False,
                'message': 'hydration_type and amount_ml are required'
            }), 400
        
        # Check if patient exists
        patient = db.patients_collection.find_one({"patient_id": patient_id})
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        # Create hydration record (following appointment pattern)
        hydration_record = {
            "hydration_id": str(uuid.uuid4()),
            "patient_id": patient_id,
            "hydration_type": data['hydration_type'],
            "amount_ml": float(data['amount_ml']),
            "amount_oz": float(data['amount_ml']) * 0.033814,
            "notes": data.get('notes', ''),
            "temperature": data.get('temperature', 'room_temperature'),
            "additives": data.get('additives', []),
            "timestamp": datetime.now().isoformat(),
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat()
        }
        
        print(f"💾 Saving hydration intake to patient {patient_id}: {hydration_record['hydration_id']}")
        
        # Add hydration record to patient's hydration_records array (same as appointments)
        result = db.patients_collection.update_one(
            {"patient_id": patient_id},
            {"$push": {"hydration_records": hydration_record}}
        )
        
        if result.modified_count > 0:
            print(f"✅ Hydration intake saved to Patient_test collection for patient {patient_id}")
            
            return jsonify({
                "success": True,
                "data": hydration_record,
                "message": "Hydration intake saved successfully to Patient_test collection"
            }), 200
        else:
            return jsonify({
                "success": False,
                "message": "Failed to save hydration intake"
            }), 500
        
    except Exception as e:
        print(f"❌ Error saving hydration intake: {str(e)}")
        return jsonify({
            "success": False,
            "message": f"Failed to save hydration intake: {str(e)}"
        }), 500

@app.route('/api/hydration/history', methods=['GET'])
@token_required
def get_hydration_history():
    """Get hydration intake history - following appointment pattern"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        patient_id = request.user_data['patient_id']
        days = request.args.get('days', 7, type=int)
        
        print(f"🔍 Getting hydration history for patient {patient_id} - days: {days}")
        
        # Get patient document
        patient = db.patients_collection.find_one({"patient_id": patient_id})
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        # Get hydration records from patient document (same as appointments)
        hydration_records = patient.get('hydration_records', [])
        print(f"📋 Found {len(hydration_records)} total hydration records for patient {patient_id}")
        
        # Filter by date range
        cutoff_date = datetime.now() - timedelta(days=days)
        filtered_records = []
        for record in hydration_records:
            record_timestamp = record.get('timestamp', '')
            if record_timestamp:
                try:
                    record_date = datetime.fromisoformat(record_timestamp.replace('Z', '+00:00'))
                    if record_date >= cutoff_date:
                        filtered_records.append(record)
                except ValueError:
                    # Skip records with invalid timestamp format
                    continue
        
        # Sort by timestamp (newest first)
        filtered_records.sort(key=lambda x: x.get('timestamp', ''), reverse=True)
        
        print(f"✅ Found {len(filtered_records)} filtered hydration records for patient {patient_id}")
        
        return jsonify({
            "success": True,
            "data": filtered_records,
            "total_count": len(filtered_records),
            "patient_id": patient_id,
            "message": f"Retrieved {len(filtered_records)} hydration records from Patient_test collection"
        }), 200
        
    except Exception as e:
        print(f"❌ Error retrieving hydration history: {str(e)}")
        return jsonify({
            "success": False,
            "message": f"Failed to retrieve hydration history: {str(e)}"
        }), 500

@app.route('/api/hydration/goal', methods=['POST'])
@token_required
def set_hydration_goal():
    """Set or update hydration goal - following appointment pattern"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        data = request.get_json()
        patient_id = request.user_data['patient_id']
        
        # Validate required fields
        if not data or 'daily_goal_ml' not in data:
            return jsonify({
                'success': False,
                'message': 'daily_goal_ml is required'
            }), 400
        
        # Check if patient exists
        patient = db.patients_collection.find_one({"patient_id": patient_id})
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        # Create hydration goal data
        goal_data = {
            "daily_goal_ml": float(data['daily_goal_ml']),
            "daily_goal_oz": float(data['daily_goal_ml']) * 0.033814,
            "reminder_enabled": data.get('reminder_enabled', True),
            "reminder_times": data.get('reminder_times', ["08:00", "12:00", "16:00", "20:00"]),
            "start_date": date.today().isoformat(),
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat()
        }
        
        print(f"💾 Setting hydration goal for patient {patient_id}: {goal_data['daily_goal_ml']}ml")
        
        # Update patient's hydration goal (same pattern as appointments)
        result = db.patients_collection.update_one(
            {"patient_id": patient_id},
            {"$set": {"hydration_goal": goal_data}}
        )
        
        if result.modified_count > 0:
            print(f"✅ Hydration goal saved to Patient_test collection for patient {patient_id}")
            
            return jsonify({
                "success": True,
                "data": goal_data,
                "message": "Hydration goal set successfully in Patient_test collection"
            }), 200
        else:
            return jsonify({
                "success": False,
                "message": "Failed to set hydration goal"
            }), 500
        
    except Exception as e:
        print(f"❌ Error setting hydration goal: {str(e)}")
        return jsonify({
            "success": False,
            "message": f"Failed to set hydration goal: {str(e)}"
        }), 500

@app.route('/api/hydration/goal', methods=['GET'])
@token_required
def get_hydration_goal():
    """Get current hydration goal - following appointment pattern"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        patient_id = request.user_data['patient_id']
        
        print(f"🔍 Getting hydration goal for patient {patient_id}")
        
        # Get patient document
        patient = db.patients_collection.find_one({"patient_id": patient_id})
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        # Get hydration goal from patient document
        hydration_goal = patient.get('hydration_goal', {})
        
        if not hydration_goal:
            # Return default goal if none set
            default_goal = {
                "patient_id": patient_id,
                "daily_goal_ml": 2000,
                "daily_goal_oz": 67.6,
                "start_date": date.today().isoformat(),
                "is_active": True,
                "reminder_enabled": True,
                "reminder_times": ["08:00", "12:00", "16:00", "20:00"]
            }
            return jsonify({
                "success": True,
                "data": default_goal,
                "message": "No hydration goal set, returning default"
            }), 200
        
        print(f"✅ Found hydration goal for patient {patient_id}: {hydration_goal['daily_goal_ml']}ml")
        
        return jsonify({
            "success": True,
            "data": hydration_goal,
            "message": "Hydration goal retrieved successfully from Patient_test collection"
        }), 200
        
    except Exception as e:
        print(f"❌ Error retrieving hydration goal: {str(e)}")
        return jsonify({
            "success": False,
            "message": f"Failed to retrieve hydration goal: {str(e)}"
        }), 500

@app.route('/api/hydration/reminder', methods=['POST'])
@token_required
def create_hydration_reminder():
    """Create hydration reminder - following appointment pattern"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        data = request.get_json()
        patient_id = request.user_data['patient_id']
        
        # Validate required fields
        if not data or 'reminder_time' not in data or 'message' not in data:
            return jsonify({
                'success': False,
                'message': 'reminder_time and message are required'
            }), 400
        
        # Check if patient exists
        patient = db.patients_collection.find_one({"patient_id": patient_id})
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        # Create reminder data
        reminder_data = {
            "reminder_id": str(uuid.uuid4()),
            "patient_id": patient_id,
            "reminder_time": data['reminder_time'],
            "message": data['message'],
            "days_of_week": data.get('days_of_week', [0, 1, 2, 3, 4, 5, 6]),
            "is_enabled": True,
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat()
        }
        
        print(f"💾 Creating hydration reminder for patient {patient_id}: {reminder_data['reminder_id']}")
        
        # Add reminder to patient's hydration_reminders array (same as appointments)
        result = db.patients_collection.update_one(
            {"patient_id": patient_id},
            {"$push": {"hydration_reminders": reminder_data}}
        )
        
        if result.modified_count > 0:
            print(f"✅ Hydration reminder saved to Patient_test collection for patient {patient_id}")
            
            return jsonify({
                "success": True,
                "data": reminder_data,
                "message": "Hydration reminder created successfully in Patient_test collection"
            }), 200
        else:
            return jsonify({
                "success": False,
                "message": "Failed to create hydration reminder"
            }), 500
        
    except Exception as e:
        print(f"❌ Error creating hydration reminder: {str(e)}")
        return jsonify({
            "success": False,
            "message": f"Failed to create hydration reminder: {str(e)}"
        }), 500

@app.route('/api/hydration/reminders', methods=['GET'])
@token_required
def get_hydration_reminders():
    """Get all hydration reminders - following appointment pattern"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        patient_id = request.user_data['patient_id']
        
        print(f"🔍 Getting hydration reminders for patient {patient_id}")
        
        # Get patient document
        patient = db.patients_collection.find_one({"patient_id": patient_id})
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        # Get hydration reminders from patient document
        reminders = patient.get('hydration_reminders', [])
        
        print(f"✅ Found {len(reminders)} hydration reminders for patient {patient_id}")
        
        return jsonify({
            "success": True,
            "data": {"reminders": reminders},
            "total_count": len(reminders),
            "patient_id": patient_id,
            "message": f"Retrieved {len(reminders)} hydration reminders from Patient_test collection"
        }), 200
        
    except Exception as e:
        print(f"❌ Error retrieving hydration reminders: {str(e)}")
        return jsonify({
            "success": False,
            "message": f"Failed to retrieve hydration reminders: {str(e)}"
        }), 500

@app.route('/api/hydration/stats', methods=['GET'])
@token_required
def get_daily_hydration_stats():
    """Get daily hydration statistics - following appointment pattern"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        patient_id = request.user_data['patient_id']
        target_date = request.args.get('date')
        
        if target_date:
            target_date = datetime.strptime(target_date, '%Y-%m-%d').date()
        else:
            target_date = date.today()
        
        print(f"🔍 Getting hydration stats for patient {patient_id} - date: {target_date}")
        
        # Get patient document
        patient = db.patients_collection.find_one({"patient_id": patient_id})
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        # Get hydration records and goal from patient document
        hydration_records = patient.get('hydration_records', [])
        hydration_goal = patient.get('hydration_goal', {})
        
        # Filter records for target date
        target_date_str = target_date.isoformat()
        daily_records = [
            record for record in hydration_records
            if record.get('timestamp', '').startswith(target_date_str)
        ]
        
        # Calculate stats
        total_intake_ml = sum(record.get('amount_ml', 0) for record in daily_records)
        total_intake_oz = sum(record.get('amount_oz', 0) for record in daily_records)
        
        goal_ml = hydration_goal.get('daily_goal_ml', 2000)
        goal_oz = hydration_goal.get('daily_goal_oz', 67.6)
        goal_percentage = (total_intake_ml / goal_ml * 100) if goal_ml > 0 else 0
        
        # Calculate intake by type
        intake_by_type = {}
        for record in daily_records:
            hydration_type = record.get('hydration_type', 'water')
            amount = record.get('amount_ml', 0)
            intake_by_type[hydration_type] = intake_by_type.get(hydration_type, 0) + amount
        
        stats = {
            "patient_id": patient_id,
            "date": target_date.isoformat(),
            "total_intake_ml": total_intake_ml,
            "total_intake_oz": total_intake_oz,
            "goal_ml": goal_ml,
            "goal_oz": goal_oz,
            "goal_percentage": round(goal_percentage, 1),
            "intake_by_type": intake_by_type,
            "is_goal_met": total_intake_ml >= goal_ml,
            "records_count": len(daily_records)
        }
        
        print(f"✅ Calculated hydration stats for patient {patient_id}: {total_intake_ml}ml / {goal_ml}ml ({goal_percentage:.1f}%)")
        
        return jsonify({
            "success": True,
            "data": stats,
            "message": "Hydration statistics retrieved successfully from Patient_test collection"
        }), 200
        
    except Exception as e:
        print(f"❌ Error retrieving hydration stats: {str(e)}")
        return jsonify({
            "success": False,
            "message": f"Failed to retrieve hydration stats: {str(e)}"
        }), 500

@app.route('/api/hydration/status', methods=['GET'])
@token_required
def get_hydration_status():
    """Get current hydration status - following appointment pattern"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        patient_id = request.user_data['patient_id']
        
        print(f"🔍 Getting hydration status for patient {patient_id}")
        
        # Get patient document
        patient = db.patients_collection.find_one({"patient_id": patient_id})
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        # Get today's stats
        today = date.today()
        hydration_records = patient.get('hydration_records', [])
        hydration_goal = patient.get('hydration_goal', {})
        
        # Filter today's records
        today_str = today.isoformat()
        today_records = [
            record for record in hydration_records
            if record.get('timestamp', '').startswith(today_str)
        ]
        
        # Calculate current status
        current_intake_ml = sum(record.get('amount_ml', 0) for record in today_records)
        goal_ml = hydration_goal.get('daily_goal_ml', 2000)
        progress_percentage = (current_intake_ml / goal_ml * 100) if goal_ml > 0 else 0
        is_goal_met = current_intake_ml >= goal_ml
        
        # Calculate hours since last intake
        hours_since_last = 24  # Default if no records
        if today_records:
            last_record = max(today_records, key=lambda x: x.get('timestamp', ''))
            last_timestamp = last_record.get('timestamp')
            if last_timestamp:
                try:
                    last_dt = datetime.fromisoformat(last_timestamp.replace('Z', '+00:00'))
                    hours_since_last = (datetime.now() - last_dt).total_seconds() / 3600
                except:
                    pass
        
        # Generate recommendation
        if hours_since_last > 3:
            recommendation = "You haven't had water in a while. Time to hydrate!"
        elif progress_percentage < 50:
            recommendation = "You're behind on your hydration goal. Try to catch up!"
        elif progress_percentage < 75:
            recommendation = "Good progress! Keep drinking water throughout the day."
        elif progress_percentage < 100:
            recommendation = "Almost at your goal! Just a bit more to go."
        else:
            recommendation = "Excellent! You've met your hydration goal for today."
        
        status = {
            "patient_id": patient_id,
            "current_intake_ml": current_intake_ml,
            "goal_ml": goal_ml,
            "progress_percentage": round(progress_percentage, 1),
            "is_goal_met": is_goal_met,
            "hours_since_last_intake": round(hours_since_last, 1),
            "recommendation": recommendation,
            "records_today": len(today_records)
        }
        
        print(f"✅ Hydration status for patient {patient_id}: {current_intake_ml}ml / {goal_ml}ml ({progress_percentage:.1f}%)")
        
        return jsonify({
            "success": True,
            "data": status,
            "message": "Hydration status retrieved successfully from Patient_test collection"
        }), 200
        
    except Exception as e:
        print(f"❌ Error retrieving hydration status: {str(e)}")
        return jsonify({
            "success": False,
            "message": f"Failed to retrieve hydration status: {str(e)}"
        }), 500
