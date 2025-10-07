# Add this code to app_simple.py before the if __name__ == '__main__': section

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
        status = request.args.get('status')
        consultation_type = request.args.get('type')  # "Follow-up", "Consultation"
        appointment_type = request.args.get('appointment_type')  # "Video Call", "In-person"
        
        print(f"🔍 Getting appointments for patient {patient_id} - date: {date}, status: {status}, type: {consultation_type}, appointment_type: {appointment_type}")
        
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
            
            # Filter by consultation type if provided (Follow-up, Consultation, etc.)
            if consultation_type and appointment.get('type') != consultation_type:
                continue
            
            # Filter by appointment type (Video Call, In-person) if provided
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
        
        # Validate required fields - NOW INCLUDES BOTH type AND appointment_type
        required_fields = ['appointment_date', 'appointment_time', 'type', 'appointment_type']
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
        
        # Create appointment object with SEPARATE type and appointment_type
        appointment = {
            "appointment_id": appointment_id,
            "appointment_date": data["appointment_date"],
            "appointment_time": data["appointment_time"],
            "type": data["type"],  # Consultation type: "Follow-up", "Consultation", "Check-up", "Emergency"
            "appointment_type": data["appointment_type"],  # Mode: "Video Call", "In-person"
            "appointment_status": "pending",  # Patient requests start as pending
            "notes": data.get("notes", ""),
            "patient_notes": data.get("patient_notes", ""),
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
                "status": "pending",
                "type": data["type"],
                "appointment_type": data["appointment_type"]
            }), 201
        else:
            return jsonify({"error": "Failed to save appointment request"}), 500
        
    except Exception as e:
        print(f"❌ Error creating patient appointment: {str(e)}")
        return jsonify({"error": f"Failed to create appointment: {str(e)}"}), 500

@app.route('/patient/appointments/<appointment_id>', methods=['PUT'])
@token_required
def update_patient_appointment(appointment_id):
    """
    Update appointment details - ONLY for pending appointments
    
    ⚠️ BUSINESS RULE: Patients CANNOT update approved appointments
    They must cancel and recreate if the appointment is already approved
    """
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        data = request.get_json()
        patient_id = request.user_data['patient_id']
        
        print(f"🔍 Patient {patient_id} updating appointment {appointment_id} - data: {data}")
        
        # Get patient document
        patient = db.patients_collection.find_one({"patient_id": patient_id})
        if not patient:
            return jsonify({"error": "Patient not found"}), 404
        
        # Find the appointment
        appointments = patient.get('appointments', [])
        appointment_index = None
        current_appointment = None
        
        for idx, appt in enumerate(appointments):
            if appt.get('appointment_id') == appointment_id:
                appointment_index = idx
                current_appointment = appt
                break
        
        if appointment_index is None:
            return jsonify({"error": "Appointment not found"}), 404
        
        # ⚠️ CRITICAL BUSINESS RULE: Cannot update approved appointments
        if current_appointment.get('appointment_status') == 'approved':
            return jsonify({
                "error": "Cannot update approved appointments",
                "message": "This appointment has been approved by the doctor. Please cancel this appointment and create a new one if you need to make changes.",
                "action_required": "cancel_and_recreate",
                "current_status": "approved"
            }), 403  # 403 Forbidden
        
        # Only allow updating specific fields for pending appointments
        allowed_fields = ['appointment_date', 'appointment_time', 'type', 'appointment_type', 'notes', 'patient_notes']
        
        # Build update object
        update_data = {}
        for field in allowed_fields:
            if field in data:
                update_data[f"appointments.{appointment_index}.{field}"] = data[field]
        
        if not update_data:
            return jsonify({"error": "No valid fields to update"}), 400
        
        # Add updated_at timestamp
        update_data[f"appointments.{appointment_index}.updated_at"] = datetime.now().isoformat()
        
        print(f"💾 Updating appointment fields: {update_data}")
        
        # Update appointment in database
        result = db.patients_collection.update_one(
            {"patient_id": patient_id},
            {"$set": update_data}
        )
        
        if result.modified_count > 0:
            print(f"✅ Appointment {appointment_id} updated successfully!")
            
            # Get updated appointment
            updated_patient = db.patients_collection.find_one({"patient_id": patient_id})
            updated_appointment = updated_patient['appointments'][appointment_index]
            
            return jsonify({
                "message": "Appointment updated successfully",
                "appointment": updated_appointment,
                "appointment_id": appointment_id
            }), 200
        else:
            return jsonify({"error": "No changes made to appointment"}), 400
        
    except Exception as e:
        print(f"❌ Error updating patient appointment: {str(e)}")
        return jsonify({"error": f"Failed to update appointment: {str(e)}"}), 500

@app.route('/patient/appointments/<appointment_id>', methods=['DELETE'])
@token_required
def cancel_patient_appointment(appointment_id):
    """Cancel/delete appointment - works for both pending and approved"""
    try:
        if db.patients_collection is None:
            return jsonify({"error": "Database not connected"}), 500
        
        patient_id = request.user_data['patient_id']
        
        print(f"🔍 Patient {patient_id} cancelling appointment {appointment_id}")
        
        # Remove appointment from patient's appointments array
        result = db.patients_collection.update_one(
            {"patient_id": patient_id},
            {"$pull": {"appointments": {"appointment_id": appointment_id}}}
        )
        
        if result.modified_count > 0:
            print(f"✅ Appointment {appointment_id} cancelled successfully!")
            return jsonify({
                "message": "Appointment cancelled successfully",
                "appointment_id": appointment_id
            }), 200
        else:
            return jsonify({"error": "Appointment not found or already cancelled"}), 404
        
    except Exception as e:
        print(f"❌ Error cancelling patient appointment: {str(e)}")
        return jsonify({"error": f"Failed to cancel appointment: {str(e)}"}), 500
