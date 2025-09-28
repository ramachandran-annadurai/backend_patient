# ============================================================================
# PATIENT APPOINTMENT ENDPOINTS
# ============================================================================

@app.route('/patient/appointments', methods=['GET'])
@token_required
def get_patient_appointments():
    """Get all appointments for the authenticated patient"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        patient_id = request.user_data['patient_id']
        
        # Get query parameters for filtering
        date = request.args.get('date')
        status = request.args.get('status', 'active')
        appointment_type = request.args.get('appointment_type')
        
        print(f"🔍 Getting appointments for patient {patient_id} - date: {date}, status: {status}, type: {appointment_type}")
        
        # Get patient document
        patient = db.patients_collection.find_one({"patient_id": patient_id})
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        appointments = patient.get('appointments', [])
        
        # Filter appointments based on query parameters
        filtered_appointments = []
        for appointment in appointments:
            # Filter by date if provided
            if date and appointment.get('appointment_date') != date:
                continue
            
            # Filter by status if provided
            if status and appointment.get('appointment_status') != status:
                continue
            
            # Filter by appointment type if provided
            if appointment_type and appointment.get('appointment_type') != appointment_type:
                continue
            
            # Add patient info to appointment
            appointment_data = appointment.copy()
            appointment_data['patient_id'] = patient_id
            appointment_data['patient_name'] = f"{patient.get('first_name', '')} {patient.get('last_name', '')}".strip() or patient.get('username', 'Unknown')
            
            filtered_appointments.append(appointment_data)
        
        # Sort by appointment date
        filtered_appointments.sort(key=lambda x: x.get('appointment_date', ''))
        
        print(f"✅ Found {len(filtered_appointments)} appointments for patient {patient_id}")
        
        return jsonify({
            "appointments": filtered_appointments,
            "total_count": len(filtered_appointments),
            "patient_id": patient_id,
            "message": "Appointments retrieved successfully"
        }), 200
        
    except Exception as e:
        print(f"❌ Error retrieving patient appointments: {str(e)}")
        return jsonify({"error": f"Failed to retrieve appointments: {str(e)}"}), 500

@app.route('/patient/appointments', methods=['POST'])
@token_required
def create_patient_appointment():
    """Create a new appointment request - patient can request appointments"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        data = request.get_json()
        patient_id = request.user_data['patient_id']
        
        print(f"🔍 Patient {patient_id} creating appointment request - data: {data}")
        
        # Validate required fields
        required_fields = ['appointment_date', 'appointment_time', 'appointment_type']
        for field in required_fields:
            if not data.get(field):
                return jsonify({"error": f"{field} is required"}), 400
        
        # Get patient document
        patient = db.patients_collection.find_one({"patient_id": patient_id})
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        print(f"✅ Patient found: {patient.get('first_name', '')} {patient.get('last_name', '')}")
        
        # Generate unique appointment ID
        appointment_id = str(ObjectId())
        
        # Create appointment object
        appointment = {
            "appointment_id": appointment_id,
            "appointment_date": data["appointment_date"],
            "appointment_time": data["appointment_time"],
            "appointment_type": data["appointment_type"],
            "appointment_status": "pending",  # Patient requests start as pending
            "notes": data.get("notes", ""),
            "patient_notes": data.get("patient_notes", ""),  # Additional field for patient notes
            "doctor_id": data.get("doctor_id", ""),
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat(),
            "status": "active",
            "requested_by": "patient"
        }
        
        print(f"💾 Saving appointment request to patient {patient_id}: {appointment}")
        
        # Add appointment to patient's appointments array
        result = db.patients_collection.update_one(
            {"patient_id": patient_id},
            {"$push": {"appointments": appointment}}
        )
        
        if result.modified_count > 0:
            print(f"✅ Appointment request saved successfully!")
            return jsonify({
                "appointment_id": appointment_id,
                "message": "Appointment request created successfully",
                "status": "pending"
            }), 201
        else:
            return jsonify({"error": "Failed to save appointment request"}), 500
        
    except Exception as e:
        print(f"❌ Error creating patient appointment: {str(e)}")
        return jsonify({"error": f"Failed to create appointment: {str(e)}"}), 500

@app.route('/patient/appointments/<appointment_id>', methods=['GET'])
@token_required
def get_patient_appointment(appointment_id):
    """Get specific appointment details for the authenticated patient"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        patient_id = request.user_data['patient_id']
        
        print(f"🔍 Getting appointment {appointment_id} for patient {patient_id}")
        
        # Get patient document
        patient = db.patients_collection.find_one({"patient_id": patient_id})
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        # Find the specific appointment
        appointments = patient.get('appointments', [])
        appointment = None
        for apt in appointments:
            if apt.get('appointment_id') == appointment_id:
                appointment = apt
                break
        
        if not appointment:
            return jsonify({"error": "Appointment not found"}), 404
        
        # Add patient info to appointment
        appointment_data = appointment.copy()
        appointment_data['patient_id'] = patient_id
        appointment_data['patient_name'] = f"{patient.get('first_name', '')} {patient.get('last_name', '')}".strip() or patient.get('username', 'Unknown')
        
        print(f"✅ Found appointment: {appointment_data}")
        
        return jsonify({
            "appointment": appointment_data,
            "message": "Appointment retrieved successfully"
        }), 200
        
    except Exception as e:
        print(f"❌ Error retrieving patient appointment: {str(e)}")
        return jsonify({"error": f"Failed to retrieve appointment: {str(e)}"}), 500

@app.route('/patient/appointments/<appointment_id>', methods=['PUT'])
@token_required
def update_patient_appointment(appointment_id):
    """Update an existing appointment - patient can update their own appointments"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        data = request.get_json()
        patient_id = request.user_data['patient_id']
        
        print(f"🔍 Patient {patient_id} updating appointment {appointment_id} with data: {data}")
        
        # Find patient with this appointment
        patient = db.patients_collection.find_one({
            "patient_id": patient_id,
            "appointments.appointment_id": appointment_id
        })
        if not patient:
            return jsonify({"error": "Appointment not found or access denied"}), 404
        
        # Prepare update data - patients can only update certain fields
        update_fields = {}
        allowed_fields = ['appointment_date', 'appointment_time', 'appointment_type', 'patient_notes', 'notes']
        
        for field in allowed_fields:
            if field in data:
                update_fields[f"appointments.$.{field}"] = data[field]
        
        if update_fields:
            update_fields["appointments.$.updated_at"] = datetime.now().isoformat()
            
            # Update the specific appointment in the array
            result = db.patients_collection.update_one(
                {"patient_id": patient_id, "appointments.appointment_id": appointment_id},
                {"$set": update_fields}
            )
            
            if result.modified_count > 0:
                print(f"✅ Appointment {appointment_id} updated successfully by patient")
                return jsonify({"message": "Appointment updated successfully"}), 200
            else:
                return jsonify({"message": "No changes made"}), 200
        else:
            return jsonify({"message": "No valid fields to update"}), 400
        
    except Exception as e:
        print(f"❌ Error updating patient appointment: {str(e)}")
        return jsonify({"error": f"Failed to update appointment: {str(e)}"}), 500

@app.route('/patient/appointments/<appointment_id>', methods=['DELETE'])
@token_required
def cancel_patient_appointment(appointment_id):
    """Cancel an appointment - patient can cancel their own appointments"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        patient_id = request.user_data['patient_id']
        
        print(f"🔍 Patient {patient_id} canceling appointment {appointment_id}")
        
        # Find patient with this appointment
        patient = db.patients_collection.find_one({
            "patient_id": patient_id,
            "appointments.appointment_id": appointment_id
        })
        if not patient:
            return jsonify({"error": "Appointment not found or access denied"}), 404
        
        # Update appointment status to cancelled instead of deleting
        result = db.patients_collection.update_one(
            {"patient_id": patient_id, "appointments.appointment_id": appointment_id},
            {
                "$set": {
                    "appointments.$.appointment_status": "cancelled",
                    "appointments.$.updated_at": datetime.now().isoformat(),
                    "appointments.$.cancelled_by": "patient"
                }
            }
        )
        
        if result.modified_count > 0:
            print(f"✅ Appointment {appointment_id} cancelled by patient")
            return jsonify({"message": "Appointment cancelled successfully"}), 200
        else:
            return jsonify({"error": "Failed to cancel appointment"}), 500
        
    except Exception as e:
        print(f"❌ Error cancelling patient appointment: {str(e)}")
        return jsonify({"error": f"Failed to cancel appointment: {str(e)}"}), 500

@app.route('/patient/appointments/upcoming', methods=['GET'])
@token_required
def get_upcoming_appointments():
    """Get upcoming appointments for the authenticated patient"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        patient_id = request.user_data['patient_id']
        
        print(f"🔍 Getting upcoming appointments for patient {patient_id}")
        
        # Get patient document
        patient = db.patients_collection.find_one({"patient_id": patient_id})
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        appointments = patient.get('appointments', [])
        today = datetime.now().date()
        
        # Filter upcoming appointments (future dates and active status)
        upcoming_appointments = []
        for appointment in appointments:
            appointment_date_str = appointment.get('appointment_date', '')
            appointment_status = appointment.get('appointment_status', '')
            
            if appointment_status in ['scheduled', 'confirmed', 'pending']:
                try:
                    appointment_date = datetime.strptime(appointment_date_str, '%Y-%m-%d').date()
                    if appointment_date >= today:
                        appointment_data = appointment.copy()
                        appointment_data['patient_id'] = patient_id
                        appointment_data['patient_name'] = f"{patient.get('first_name', '')} {patient.get('last_name', '')}".strip() or patient.get('username', 'Unknown')
                        upcoming_appointments.append(appointment_data)
                except ValueError:
                    # Skip appointments with invalid date format
                    continue
        
        # Sort by appointment date
        upcoming_appointments.sort(key=lambda x: x.get('appointment_date', ''))
        
        print(f"✅ Found {len(upcoming_appointments)} upcoming appointments for patient {patient_id}")
        
        return jsonify({
            "upcoming_appointments": upcoming_appointments,
            "total_count": len(upcoming_appointments),
            "patient_id": patient_id,
            "message": "Upcoming appointments retrieved successfully"
        }), 200
        
    except Exception as e:
        print(f"❌ Error retrieving upcoming appointments: {str(e)}")
        return jsonify({"error": f"Failed to retrieve upcoming appointments: {str(e)}"}), 500

@app.route('/patient/appointments/history', methods=['GET'])
@token_required
def get_appointment_history():
    """Get appointment history for the authenticated patient"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        patient_id = request.user_data['patient_id']
        
        print(f"🔍 Getting appointment history for patient {patient_id}")
        
        # Get patient document
        patient = db.patients_collection.find_one({"patient_id": patient_id})
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        appointments = patient.get('appointments', [])
        today = datetime.now().date()
        
        # Filter past appointments
        past_appointments = []
        for appointment in appointments:
            appointment_date_str = appointment.get('appointment_date', '')
            appointment_status = appointment.get('appointment_status', '')
            
            if appointment_status in ['completed', 'cancelled', 'no_show']:
                try:
                    appointment_date = datetime.strptime(appointment_date_str, '%Y-%m-%d').date()
                    if appointment_date < today:
                        appointment_data = appointment.copy()
                        appointment_data['patient_id'] = patient_id
                        appointment_data['patient_name'] = f"{patient.get('first_name', '')} {patient.get('last_name', '')}".strip() or patient.get('username', 'Unknown')
                        past_appointments.append(appointment_data)
                except ValueError:
                    # Skip appointments with invalid date format
                    continue
        
        # Sort by appointment date (most recent first)
        past_appointments.sort(key=lambda x: x.get('appointment_date', ''), reverse=True)
        
        print(f"✅ Found {len(past_appointments)} past appointments for patient {patient_id}")
        
        return jsonify({
            "appointment_history": past_appointments,
            "total_count": len(past_appointments),
            "patient_id": patient_id,
            "message": "Appointment history retrieved successfully"
        }), 200
        
    except Exception as e:
        print(f"❌ Error retrieving appointment history: {str(e)}")
        return jsonify({"error": f"Failed to retrieve appointment history: {str(e)}"}), 500
