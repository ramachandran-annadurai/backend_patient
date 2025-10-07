# 📱 Flutter Appointment Module - Integration Documentation

## 🎯 Overview

This document provides complete integration guide for the Patient Appointment Module in your Flutter application. The appointment system uses **two separate fields** for appointment classification:

1. **`type`** - Consultation Type (Follow-up, Consultation, Check-up, Emergency)
2. **`appointment_type`** - Mode (Video Call, In-person)

---

## 🔑 Authentication

All endpoints require JWT Bearer Token authentication.

```dart
final token = await storage.read(key: 'access_token');
final headers = {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
};
```

---

## 📡 API Endpoints

### Base URL
```
http://localhost:8000  // Development
https://your-api.com   // Production
```

---

## 1️⃣ GET All Appointments

### Endpoint
```
GET /patient/appointments
```

### Query Parameters

| Parameter | Type | Required | Options | Description |
|-----------|------|----------|---------|-------------|
| `type` | String | No | `Follow-up`, `Consultation`, `Check-up`, `Emergency` | Filter by consultation type |
| `appointment_type` | String | No | `Video Call`, `In-person` | Filter by appointment mode |
| `status` | String | No | `pending`, `approved`, `rejected`, `cancelled`, `completed` | Filter by status |
| `date` | String | No | `YYYY-MM-DD` | Filter by specific date |

### Flutter Implementation

```dart
class AppointmentService {
  final String baseUrl = 'http://localhost:8000';
  
  Future<List<Appointment>> getAppointments({
    String? type,
    String? appointmentType,
    String? status,
    String? date,
  }) async {
    final token = await storage.read(key: 'access_token');
    
    // Build query parameters
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;
    if (appointmentType != null) queryParams['appointment_type'] = appointmentType;
    if (status != null) queryParams['status'] = status;
    if (date != null) queryParams['date'] = date;
    
    final uri = Uri.parse('$baseUrl/patient/appointments')
        .replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final appointments = (data['appointments'] as List)
          .map((json) => Appointment.fromJson(json))
          .toList();
      return appointments;
    } else {
      throw Exception('Failed to load appointments');
    }
  }
}
```

### Response Example

```json
{
  "appointments": [
    {
      "appointment_id": "507f1f77bcf86cd799439011",
      "appointment_date": "2024-01-20",
      "appointment_time": "10:00 AM",
      "type": "Follow-up",
      "appointment_type": "Video Call",
      "appointment_status": "pending",
      "notes": "Regular checkup",
      "patient_notes": "Feeling better",
      "doctor_id": "DOC123",
      "created_at": "2024-01-15T08:30:00",
      "updated_at": "2024-01-15T08:30:00",
      "status": "active",
      "requested_by": "patient",
      "patient_id": "PAT456",
      "patient_name": "John Doe"
    }
  ],
  "total_count": 1,
  "patient_id": "PAT456",
  "message": "Appointments retrieved successfully"
}
```

---

## 2️⃣ GET Specific Appointment by ID

### Endpoint
```
GET /patient/appointments/{appointment_id}
```

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `appointment_id` | String | ✅ Yes | The unique ID of the appointment |

### Flutter Implementation

```dart
Future<Appointment> getAppointmentById(String appointmentId) async {
  final token = await storage.read(key: 'access_token');
  
  final response = await http.get(
    Uri.parse('$baseUrl/patient/appointments/$appointmentId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return Appointment.fromJson(data['appointment']);
  } else if (response.statusCode == 404) {
    throw Exception('Appointment not found');
  } else {
    throw Exception('Failed to load appointment');
  }
}
```

### Success Response (200 OK)

```json
{
  "appointment": {
    "appointment_id": "507f1f77bcf86cd799439011",
    "appointment_date": "2024-01-20",
    "appointment_time": "10:00 AM",
    "type": "Follow-up",
    "appointment_type": "Video Call",
    "appointment_status": "pending",
    "notes": "Regular checkup",
    "patient_notes": "Feeling better",
    "doctor_id": "DOC123",
    "created_at": "2024-01-15T08:30:00",
    "updated_at": "2024-01-15T08:30:00",
    "status": "active",
    "requested_by": "patient",
    "patient_id": "PAT456",
    "patient_name": "John Doe"
  },
  "message": "Appointment retrieved successfully"
}
```

### Error Response (404 Not Found)

```json
{
  "error": "Appointment not found"
}
```

### Usage Example

```dart
// Get appointment details by ID
try {
  final appointment = await appointmentService.getAppointmentById(
    '507f1f77bcf86cd799439011',
  );
  
  print('Appointment: ${appointment.type} on ${appointment.appointmentDate}');
  print('Status: ${appointment.appointmentStatus}');
  
} catch (e) {
  print('Error: $e');
}
```

---

## 3️⃣ CREATE New Appointment

### Endpoint
```
POST /patient/appointments
```

### Request Body

| Field | Type | Required | Options | Description |
|-------|------|----------|---------|-------------|
| `appointment_date` | String | ✅ Yes | `YYYY-MM-DD` | Date of appointment |
| `appointment_time` | String | ✅ Yes | e.g., `10:00 AM` | Time of appointment |
| `type` | String | ✅ Yes | `Follow-up`, `Consultation`, `Check-up`, `Emergency` | Consultation type |
| `appointment_type` | String | ✅ Yes | `Video Call`, `In-person` | Appointment mode |
| `doctor_id` | String | No | - | ID of preferred doctor |
| `notes` | String | No | - | Additional notes |
| `patient_notes` | String | No | - | Patient's personal notes |

### Flutter Implementation

```dart
Future<String> createAppointment({
  required String appointmentDate,
  required String appointmentTime,
  required String type,
  required String appointmentType,
  String? doctorId,
  String? notes,
  String? patientNotes,
}) async {
  final token = await storage.read(key: 'access_token');
  
  final body = {
    'appointment_date': appointmentDate,
    'appointment_time': appointmentTime,
    'type': type,
    'appointment_type': appointmentType,
    if (doctorId != null) 'doctor_id': doctorId,
    if (notes != null) 'notes': notes,
    if (patientNotes != null) 'patient_notes': patientNotes,
  };
  
  final response = await http.post(
    Uri.parse('$baseUrl/patient/appointments'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(body),
  );
  
  if (response.statusCode == 201) {
    final data = json.decode(response.body);
    return data['appointment_id'];
  } else {
    final error = json.decode(response.body);
    throw Exception(error['error'] ?? 'Failed to create appointment');
  }
}
```

### Request Example

```json
{
  "appointment_date": "2024-01-20",
  "appointment_time": "10:00 AM",
  "type": "Follow-up",
  "appointment_type": "Video Call",
  "doctor_id": "DOC123",
  "notes": "Regular checkup",
  "patient_notes": "Feeling better than last week"
}
```

### Success Response (201 Created)

```json
{
  "appointment_id": "507f1f77bcf86cd799439011",
  "message": "Appointment request created successfully",
  "status": "pending",
  "type": "Follow-up",
  "appointment_type": "Video Call"
}
```

### Error Response (400 Bad Request)

```json
{
  "error": "type is required"
}
```

---

## 4️⃣ UPDATE Appointment

### Endpoint
```
PUT /patient/appointments/{appointment_id}
```

### ⚠️ IMPORTANT BUSINESS RULE

**Only PENDING appointments can be updated!**

- ✅ **Pending**: Can update all fields
- ❌ **Approved**: Returns `403 Forbidden` - Must cancel and recreate

### Allowed Fields to Update

| Field | Type | Description |
|-------|------|-------------|
| `appointment_date` | String | New date |
| `appointment_time` | String | New time |
| `type` | String | Change consultation type |
| `appointment_type` | String | Change mode |
| `notes` | String | Update notes |
| `patient_notes` | String | Update patient notes |

### Flutter Implementation

```dart
Future<bool> updateAppointment({
  required String appointmentId,
  String? appointmentDate,
  String? appointmentTime,
  String? type,
  String? appointmentType,
  String? notes,
  String? patientNotes,
}) async {
  final token = await storage.read(key: 'access_token');
  
  final body = <String, dynamic>{};
  if (appointmentDate != null) body['appointment_date'] = appointmentDate;
  if (appointmentTime != null) body['appointment_time'] = appointmentTime;
  if (type != null) body['type'] = type;
  if (appointmentType != null) body['appointment_type'] = appointmentType;
  if (notes != null) body['notes'] = notes;
  if (patientNotes != null) body['patient_notes'] = patientNotes;
  
  final response = await http.put(
    Uri.parse('$baseUrl/patient/appointments/$appointmentId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(body),
  );
  
  if (response.statusCode == 200) {
    return true;
  } else if (response.statusCode == 403) {
    // Approved appointment - cannot update
    final error = json.decode(response.body);
    throw AppointmentUpdateException(
      message: error['message'],
      actionRequired: error['action_required'],
    );
  } else {
    throw Exception('Failed to update appointment');
  }
}
```

### Success Response (200 OK)

```json
{
  "message": "Appointment updated successfully",
  "appointment_id": "507f1f77bcf86cd799439011",
  "appointment": {
    "appointment_id": "507f1f77bcf86cd799439011",
    "appointment_date": "2024-01-22",
    "appointment_time": "3:00 PM",
    "type": "Consultation",
    "appointment_type": "In-person",
    "appointment_status": "pending",
    "updated_at": "2024-01-16T10:30:00"
  }
}
```

### Error Response for Approved Appointment (403 Forbidden)

```json
{
  "error": "Cannot update approved appointments",
  "message": "This appointment has been approved by the doctor. Please cancel this appointment and create a new one if you need to make changes.",
  "action_required": "cancel_and_recreate",
  "current_status": "approved"
}
```

### Flutter Error Handling

```dart
try {
  await appointmentService.updateAppointment(
    appointmentId: appointmentId,
    appointmentTime: newTime,
  );
  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Appointment updated successfully')),
  );
} on AppointmentUpdateException catch (e) {
  // Handle approved appointment case
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Cannot Update'),
      content: Text(e.message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Cancel current appointment and navigate to create new
            Navigator.pop(context);
            cancelAndRecreate(appointmentId);
          },
          child: Text('Cancel & Recreate'),
        ),
      ],
    ),
  );
} catch (e) {
  // Handle other errors
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

---

## 5️⃣ DELETE/Cancel Appointment

### Endpoint
```
DELETE /patient/appointments/{appointment_id}
```

### Notes
- Works for **both pending and approved** appointments
- Permanently removes the appointment

### Flutter Implementation

```dart
Future<bool> cancelAppointment(String appointmentId) async {
  final token = await storage.read(key: 'access_token');
  
  final response = await http.delete(
    Uri.parse('$baseUrl/patient/appointments/$appointmentId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return true;
  } else if (response.statusCode == 404) {
    throw Exception('Appointment not found');
  } else {
    throw Exception('Failed to cancel appointment');
  }
}
```

### Success Response (200 OK)

```json
{
  "message": "Appointment cancelled successfully",
  "appointment_id": "507f1f77bcf86cd799439011"
}
```

---

## 📦 Data Models

### Appointment Model

```dart
class Appointment {
  final String appointmentId;
  final String appointmentDate;
  final String appointmentTime;
  final String type;  // Consultation type
  final String appointmentType;  // Mode
  final String appointmentStatus;
  final String? notes;
  final String? patientNotes;
  final String? doctorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final String requestedBy;
  final String patientId;
  final String patientName;

  Appointment({
    required this.appointmentId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.type,
    required this.appointmentType,
    required this.appointmentStatus,
    this.notes,
    this.patientNotes,
    this.doctorId,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.requestedBy,
    required this.patientId,
    required this.patientName,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointment_id'],
      appointmentDate: json['appointment_date'],
      appointmentTime: json['appointment_time'],
      type: json['type'],
      appointmentType: json['appointment_type'],
      appointmentStatus: json['appointment_status'],
      notes: json['notes'],
      patientNotes: json['patient_notes'],
      doctorId: json['doctor_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      status: json['status'],
      requestedBy: json['requested_by'],
      patientId: json['patient_id'],
      patientName: json['patient_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'type': type,
      'appointment_type': appointmentType,
      'appointment_status': appointmentStatus,
      'notes': notes,
      'patient_notes': patientNotes,
      'doctor_id': doctorId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
      'requested_by': requestedBy,
      'patient_id': patientId,
      'patient_name': patientName,
    };
  }
}
```

### Enums for Type Safety

```dart
enum ConsultationType {
  followUp('Follow-up'),
  consultation('Consultation'),
  checkUp('Check-up'),
  emergency('Emergency');

  final String value;
  const ConsultationType(this.value);
}

enum AppointmentMode {
  videoCall('Video Call'),
  inPerson('In-person');

  final String value;
  const AppointmentMode(this.value);
}

enum AppointmentStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  cancelled('cancelled'),
  completed('completed');

  final String value;
  const AppointmentStatus(this.value);
}
```

---

## 🎨 UI Implementation Examples

### 1. Appointment Booking Form

```dart
class BookAppointmentScreen extends StatefulWidget {
  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  ConsultationType? selectedType;
  AppointmentMode? selectedMode;
  final notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Appointment')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker
            ListTile(
              title: Text('Appointment Date'),
              subtitle: Text(
                selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                    : 'Select date',
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 90)),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
            ),

            // Time Picker
            ListTile(
              title: Text('Appointment Time'),
              subtitle: Text(
                selectedTime != null
                    ? selectedTime!.format(context)
                    : 'Select time',
              ),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => selectedTime = time);
                }
              },
            ),

            SizedBox(height: 20),

            // Consultation Type Dropdown
            Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<ConsultationType>(
              value: selectedType,
              isExpanded: true,
              hint: Text('Select consultation type'),
              items: ConsultationType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedType = value);
              },
            ),

            SizedBox(height: 20),

            // Appointment Type Toggle
            Text('Appointment Type', 
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.video_call),
                    label: Text('Video Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedMode == AppointmentMode.videoCall
                          ? Colors.blue
                          : Colors.grey[300],
                      foregroundColor: selectedMode == AppointmentMode.videoCall
                          ? Colors.white
                          : Colors.black,
                    ),
                    onPressed: () {
                      setState(() => selectedMode = AppointmentMode.videoCall);
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.local_hospital),
                    label: Text('In-person'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedMode == AppointmentMode.inPerson
                          ? Colors.blue
                          : Colors.grey[300],
                      foregroundColor: selectedMode == AppointmentMode.inPerson
                          ? Colors.white
                          : Colors.black,
                    ),
                    onPressed: () {
                      setState(() => selectedMode = AppointmentMode.inPerson);
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Notes
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            Spacer(),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit() ? _submitAppointment : null,
                child: Text('Book Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canSubmit() {
    return selectedDate != null &&
        selectedTime != null &&
        selectedType != null &&
        selectedMode != null;
  }

  Future<void> _submitAppointment() async {
    try {
      final timeString = selectedTime!.format(context);
      final dateString = DateFormat('yyyy-MM-dd').format(selectedDate!);

      final appointmentId = await appointmentService.createAppointment(
        appointmentDate: dateString,
        appointmentTime: timeString,
        type: selectedType!.value,
        appointmentType: selectedMode!.value,
        patientNotes: notesController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment booked successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

### 2. Appointment List with Filters

```dart
class AppointmentListScreen extends StatefulWidget {
  @override
  _AppointmentListScreenState createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  List<Appointment> appointments = [];
  AppointmentMode? filterMode;
  ConsultationType? filterType;
  AppointmentStatus? filterStatus;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    setState(() => isLoading = true);
    try {
      final result = await appointmentService.getAppointments(
        type: filterType?.value,
        appointmentType: filterMode?.value,
        status: filterStatus?.value,
      );
      setState(() {
        appointments = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading appointments: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Appointments'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Active Filters Chips
          if (filterMode != null || filterType != null || filterStatus != null)
            Container(
              padding: EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                children: [
                  if (filterMode != null)
                    Chip(
                      label: Text(filterMode!.value),
                      onDeleted: () {
                        setState(() => filterMode = null);
                        loadAppointments();
                      },
                    ),
                  if (filterType != null)
                    Chip(
                      label: Text(filterType!.value),
                      onDeleted: () {
                        setState(() => filterType = null);
                        loadAppointments();
                      },
                    ),
                  if (filterStatus != null)
                    Chip(
                      label: Text(filterStatus!.value),
                      onDeleted: () {
                        setState(() => filterStatus = null);
                        loadAppointments();
                      },
                    ),
                ],
              ),
            ),

          // Appointment List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : appointments.isEmpty
                    ? Center(child: Text('No appointments found'))
                    : ListView.builder(
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          return AppointmentCard(
                            appointment: appointment,
                            onTap: () => _viewAppointment(appointment),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookAppointmentScreen()),
          ).then((_) => loadAppointments());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filter Appointments',
                      style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 20),

                  // Mode Filter
                  Text('Appointment Type'),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text('All'),
                        selected: filterMode == null,
                        onSelected: (selected) {
                          setModalState(() => filterMode = null);
                        },
                      ),
                      ...AppointmentMode.values.map((mode) {
                        return ChoiceChip(
                          label: Text(mode.value),
                          selected: filterMode == mode,
                          onSelected: (selected) {
                            setModalState(() => filterMode = mode);
                          },
                        );
                      }),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Type Filter
                  Text('Consultation Type'),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text('All'),
                        selected: filterType == null,
                        onSelected: (selected) {
                          setModalState(() => filterType = null);
                        },
                      ),
                      ...ConsultationType.values.map((type) {
                        return ChoiceChip(
                          label: Text(type.value),
                          selected: filterType == type,
                          onSelected: (selected) {
                            setModalState(() => filterType = type);
                          },
                        );
                      }),
                    ],
                  ),

                  SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Filters are already set
                        });
                        Navigator.pop(context);
                        loadAppointments();
                      },
                      child: Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _viewAppointment(Appointment appointment) {
    // Navigate to appointment details
  }
}
```

### 3. Appointment Card Widget

```dart
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;

  const AppointmentCard({
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Mode Icon
                  Icon(
                    appointment.appointmentType == 'Video Call'
                        ? Icons.video_call
                        : Icons.local_hospital,
                    color: appointment.appointmentType == 'Video Call'
                        ? Colors.green
                        : Colors.blue,
                  ),
                  SizedBox(width: 8),
                  // Type
                  Text(
                    appointment.type,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  // Status Badge
                  _buildStatusBadge(appointment.appointmentStatus),
                ],
              ),
              SizedBox(height: 8),
              Text(appointment.appointmentType,
                  style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(appointment.appointmentDate),
                  SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(appointment.appointmentTime),
                ],
              ),
              if (appointment.patientNotes != null &&
                  appointment.patientNotes!.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  appointment.patientNotes!,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'cancelled':
        color = Colors.grey;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
```

---

## ⚠️ Important Notes

### 1. **Update Restrictions**
- Only **pending** appointments can be updated
- Attempting to update an **approved** appointment returns `403 Forbidden`
- Frontend should show "Cancel & Recreate" option for approved appointments

### 2. **Field Validation**
- Both `type` and `appointment_type` are **required** when creating appointments
- Date format: `YYYY-MM-DD`
- Time format: Free text (e.g., `10:00 AM`, `14:30`)

### 3. **Status Flow**
```
pending → approved → completed
        ↘ rejected
        ↘ cancelled (can happen at any stage)
```

### 4. **Error Handling**
Always handle these error cases:
- `400` - Bad Request (missing/invalid fields)
- `401` - Unauthorized (invalid/expired token)
- `403` - Forbidden (cannot update approved appointment)
- `404` - Not Found (appointment doesn't exist)
- `500` - Server Error

---

## 🧪 Testing

### Postman Collection
Import the `Patient_Appointment_Module.postman_collection.json` file to test all endpoints.

### Test Flow
1. Create a video call appointment
2. Get all appointments
3. Filter by appointment type
4. Update the pending appointment
5. Try to update after doctor approves (should fail with 403)
6. Cancel appointment

---

## 📞 Support

For backend API issues, contact the backend team.
For Flutter integration help, refer to this document or contact the mobile team lead.

---

**Last Updated:** January 2024  
**Version:** 1.0  
**Backend API Version:** v1

