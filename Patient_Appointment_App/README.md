# Patient Appointment App - MVC Pattern

A Flutter application for patient appointment management using the MVC (Model-View-Controller) architectural pattern. This app uses the existing `new_appointment_screen.dart` design and functionality from the original Pregnancy AI Flutter Frontend project.

## 📁 Project Structure

```
Patient_Appointment_App/
├── lib/
│   ├── controllers/           # Business Logic Layer
│   │   └── appointment_controller.dart
│   ├── models/               # Data Models Layer
│   │   ├── appointment_model.dart
│   │   └── api_response_model.dart
│   ├── services/             # Data Access Layer
│   │   └── api_service.dart
│   ├── views/                # Presentation Layer
│   │   ├── screens/
│   │   │   ├── new_appointment_screen.dart    # Original design with MVC integration
│   │   │   └── appointment_list_screen.dart
│   │   └── widgets/
│   │       ├── custom_button.dart
│   │       └── custom_text_field.dart
│   ├── widgets/              # UI Components from original project
│   │   ├── app_background.dart
│   │   └── gradient_button.dart
│   ├── theme/                # Theme from original project
│   │   └── app_theme.dart
│   ├── utils/                # Utilities from original project
│   │   └── date_utils.dart
│   └── main.dart
├── pubspec.yaml
└── README.md
```

## 🏗️ Architecture

### MVC Pattern Implementation

1. **Model (M)**: 
   - `AppointmentModel`: Represents appointment data
   - `ApiResponseModel`: Generic API response wrapper

2. **View (V)**: 
   - Flutter UI screens and widgets
   - `NewAppointmentScreen`: Main appointment creation screen
   - `AppointmentListScreen`: List and manage appointments
   - Custom widgets for reusable UI components

3. **Controller (C)**: 
   - `AppointmentController`: Manages business logic and state
   - Handles API calls and data transformation
   - Uses Provider for state management

### Services Layer
- `ApiService`: Handles all HTTP communications with the backend
- Implements CRUD operations for appointments
- Error handling and response parsing

## 🚀 Features

- ✅ Create new appointments
- ✅ View appointment list
- ✅ Cancel appointments
- ✅ View appointment details
- ✅ Form validation
- ✅ Date and time pickers
- ✅ Appointment type selection
- ✅ Video call vs In-person toggle
- ✅ Problem description input
- ✅ Loading states
- ✅ Error handling
- ✅ Success feedback
- ✅ Pull-to-refresh

## 🔧 API Integration

Uses the backend API endpoints:
- `POST /patient/appointments` - Create appointment
- `GET /patient/appointments` - Get appointments
- `PUT /patient/appointments/{id}` - Update appointment
- `DELETE /patient/appointments/{id}` - Cancel appointment
- `GET /patient/appointments/upcoming` - Get upcoming appointments
- `GET /patient/appointments/history` - Get appointment history

## 📱 Usage

1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to start the app
3. View your appointments on the main screen
4. Tap the + button to create a new appointment
5. Fill in the appointment form and submit
6. Manage your appointments from the list

## 🛠️ Dependencies

- `http`: For API calls
- `provider`: For state management
- `intl`: For date formatting
- `shared_preferences`: For local storage (if needed)

## 🎯 Key Features

### Appointment Creation
- Select appointment type from dropdown
- Choose date and time
- Toggle between video call and in-person
- Add problem description
- Form validation

### Appointment Management
- View all appointments in a list
- See appointment status (pending, scheduled, confirmed, cancelled, completed)
- Cancel pending/scheduled appointments
- View detailed appointment information
- Pull-to-refresh functionality

### Error Handling
- Network error handling
- User-friendly error messages
- Retry functionality
- Loading states

## 🔄 State Management

The app uses Provider for state management:
- `AppointmentController` manages all appointment-related state
- Reactive UI updates when state changes
- Centralized business logic
- Easy testing and maintenance

## 🎨 UI/UX Features

- Material Design 3
- Responsive layout
- Intuitive navigation
- Status indicators with color coding
- Loading indicators
- Error states
- Success feedback
- Pull-to-refresh

## 🚀 Getting Started

1. Clone the repository
2. Navigate to the project directory
3. Run `flutter pub get`
4. Run `flutter run`
5. Start managing your appointments!

## 📝 Notes

- The app connects to `https://pregnancy-ai.onrender.com` backend
- All API calls include proper error handling
- The app follows Flutter best practices
- MVC pattern ensures maintainable and scalable code
