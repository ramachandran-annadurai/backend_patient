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
