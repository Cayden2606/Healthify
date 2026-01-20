# Healthify 🏥

Making healthcare accessible, intelligent, and user-friendly. 🌟

> **📚 School Project Disclaimer**  
> This is a mock concept application developed as part of **EGE312** coursework. No actual clinic bookings or medical appointments are made through this app. All features are for demonstration and educational purposes only.

Your health and wellness journey starts here. Healthify is a comprehensive Flutter application that provides AI-powered health assistance, appointment booking, clinic discovery, and personal health management features tailored for Singapore.

## Features ✨

### 🤖 AI Health Assistant (Powered by Google Gemini)
- **Intelligent Chat Interface**: Natural health conversations with Gemini 2.0 Flash model
- **Image Analysis**: Upload medical images for AI-powered analysis and insights
- **Markdown Support**: Rich text formatting with code blocks, lists, tables, and blockquotes
- **Appointment Intent Detection**: AI extracts booking intent and suggests appropriate services
- **Conversational Memory**: Maintains context throughout health discussions
- **AI Shortcuts**: Quick access buttons for Symptoms, Medicines, and Wellness tips

### 📅 Appointment Management
- **Smart Booking Flow**: Step-by-step appointment creation with service selection
- **AI-Assisted Booking**: Gemini suggests appropriate appointment types based on conversation
- **Appointment CRUD**: Create, view, edit, and cancel appointments
- **Status Tracking**: Automatic status updates (upcoming → passed) based on time
- **Email Notifications**: Confirmation emails via Resend API
- **Service Categories**: 
  - Doctor Consultation (General, Chronic Conditions, Family Planning, Specialist Referral)
  - Vaccination (Adult, Child, COVID-19, Flu, Travel)
  - Screening & Tests (Cervical Cancer, Diabetic Eye, Mammogram, Blood Pressure, Cholesterol)
  - Nursing Services (Wound Dressing, Injection, Health Education, Postnatal Care)
  - Allied Health (Nutritionist, Physiotherapy, Medical Social Service, Financial Counselling)
  - Dental (Cleaning, Check-up, Fluoride Treatment, X-Ray)

### 🗺️ Interactive Clinic Map
- **Flutter Map Integration**: Interactive OpenStreetMap-based clinic locator
- **Geoapify API**: Fetches healthcare clinics across Singapore regions
- **Search Options**:
  - By Region (Central, Northwest, Southwest, Northeast, Southeast)
  - By Distance (5km radius from current location)
  - Saved Clinics (personal favorites)
  - Open Status (currently operating clinics)
- **Real-time GPS**: Accurate location services with Geolocator
- **Opening Hours Parser**: Intelligent parsing of OSM opening hours format
- **Distance Calculation**: Haversine formula for accurate distances
- **Draggable Sheet**: Smooth bottom sheet with clinic list

### 👤 User Profile & Settings
- **Comprehensive Profile**: Name, contact, age, gender, email management
- **Profile Pictures**: Cloudinary integration for image upload
- **International Phone Input**: Country code selector with validation
- **Theme Customization**: 
  - Dark/Light mode toggle with persistence
  - 15+ color palette options for theme personalization
- **Language Support**: English, 中文, Bahasa Melayu, தமிழ் (UI prepared)
- **Firebase Sync**: All preferences stored and synced across devices

### 🚶 Health Tracking
- **Step Counter**: Real-time pedometer integration
- **Activity Permission**: Android activity recognition support
- **Daily Goals**: Visual progress tracking

### 🎨 Onboarding Experience
- **4-Page Introduction**: Welcome, AI Assistant, Find & Connect, Get Started
- **Shared Preferences**: Remembers first-time users
- **Animated Transitions**: Smooth page indicators and navigation

## Tech Stack 🛠️

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.6.0+ / Dart ^3.6.0 |
| **Backend** | Firebase (Authentication, Firestore) |
| **AI Integration** | Google Gemini 2.0 Flash via `flutter_gemini` |
| **Maps** | Flutter Map + OpenStreetMap tiles |
| **Location API** | Geoapify Places API |
| **Image Storage** | Cloudinary (profile pictures) |
| **Email Service** | Resend API |
| **State Management** | Provider + StatefulWidget patterns |
| **UI Design** | Material Design 3 with custom theming |
| **Typography** | Product Sans font family |

## Dependencies 📦

### Core Packages
```yaml
flutter_gemini: ^3.0.0          # AI chat integration
dash_chat_2: ^0.0.21            # Chat UI components
flutter_markdown: ^0.7.7+1      # Markdown rendering
```

### Firebase Suite
```yaml
firebase_core: ^3.14.0          # Core Firebase functionality
firebase_auth: ^5.6.0           # User authentication
firebase_ui_auth: ^1.17.0       # Pre-built auth UI
cloud_firestore: ^5.6.9         # NoSQL database
```

### Location & Maps
```yaml
flutter_map: ^8.2.1             # Interactive maps
geolocator: ^14.0.2             # GPS location services
latlong2: ^0.9.1                # Geographic coordinates
```

### UI/UX Enhancements
```yaml
provider: ^6.0.2                # State management
community_material_icon: ^5.9.55 # Extended icon set
font_awesome_flutter: ^10.5.0   # Additional icons
flutter_svg: ^2.0.7             # SVG rendering
flutter_native_splash: ^2.4.6   # Custom splash screen
introduction_screen: ^3.1.17    # Onboarding pages
```

### User Input & Media
```yaml
phone_input: ^1.0.0             # International phone input
image_picker: ^1.1.2            # Image selection
```

### Health & Activity
```yaml
pedometer: ^4.1.1               # Step counting
permission_handler: ^11.3.0     # Runtime permissions
```

### Utilities
```yaml
http: ^1.4.0                    # HTTP requests
flutter_dotenv: ^5.2.1          # Environment variables
url_launcher: ^6.2.6            # External URL handling
shared_preferences: ^2.5.3      # Local storage
resend: ^1.0.0                  # Email sending
```

## Getting Started 🚀

### Prerequisites
- Flutter SDK 3.6.0 or higher
- Dart SDK ^3.6.0
- Android Studio / VS Code with Flutter extensions
- Firebase project with Authentication and Firestore enabled

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Cayden2606/Healthify
   cd Healthify
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   
   Create a `.env` file in the root directory:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   GEOAPIFY_API_KEY=your_geoapify_api_key_here
   RESEND_API_KEY=your_resend_api_key_here
   CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
   CLOUDINARY_UPLOAD_PRESET=your_cloudinary_upload_preset
   ```

4. **Firebase Configuration**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Email/Password authentication
   - Create a Firestore database with the following collections:
     - `appUsers` - User profiles and preferences
     - `appointments` - Appointment records
     - `clinics` - Cached clinic data
   - Download and configure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

5. **Run the application**
   ```bash
   flutter run
   ```

## Project Structure 📁

```
lib/
├── main.dart                    # App entry point, theme configuration, routes
├── firebase_options.dart        # Firebase configuration
│
├── models/                      # Data models
│   ├── app_user.dart           # User profile with theme preferences
│   ├── appointment.dart        # Appointment with clinic reference
│   ├── appointment_data.dart   # Service categories and time slots
│   ├── clinic.dart             # Clinic with Geoapify JSON parsing
│   ├── gemini_appointment.dart # AI-extracted appointment intent
│   ├── opening_hours.dart      # OSM opening hours parser
│   ├── settings_item.dart      # Settings list item model
│   └── theme_colors.dart       # Available theme color palette
│
├── screens/                     # UI screens
│   ├── appointments_screen.dart    # View/manage appointments
│   ├── clinics_screen.dart         # Map + clinic discovery
│   ├── health_assistant.dart       # AI chat interface
│   ├── home.dart                   # Dashboard with steps, shortcuts
│   ├── login_screen.dart           # Firebase authentication
│   ├── make_appointments_screen.dart # Booking workflow
│   ├── onboarding_screen.dart      # First-time user intro
│   ├── settings.dart               # App settings & profile
│   └── update_app_user_screen.dart # Profile editor
│
├── utilities/                   # Backend services
│   ├── firebase_calls.dart     # Firestore CRUD, auth, themes
│   ├── geoapify_calls.dart     # Clinic API integration
│   └── status_bar_utils.dart   # System UI styling
│
└── widgets/                     # Reusable components
    ├── bottom_navigation_bar.dart
    ├── appointments/           # Appointment list widgets
    ├── clinics/               # Map, search bar, dialogs
    ├── home/                  # App bar, search, steps card, schedule
    └── make_appointments/     # Booking flow components
```

## Key Features Implementation 🔧

### AI Health Assistant
The health assistant leverages Google Gemini 2.0 Flash for intelligent health guidance:
- System prompt engineering for healthcare context
- JSON-structured appointment intent extraction
- Conversational history management (last 6 messages)
- Real-time typing animation during AI response
- Image analysis with `textAndImage` API
- Automatic nearest clinic detection for booking

### Location Services
- Real-time GPS tracking with permission handling
- Distance calculation using the Haversine formula
- Region-based clinic search (Singapore CDC regions)
- Radius-based search (5km default)
- Background clinic caching to Firestore

### Appointment Booking
- Multi-step selection: Category → Service → Date → Time → Info
- Pre-fill from AI conversation or existing appointment
- Edit and reschedule upcoming appointments
- Automatic status transition (upcoming → passed)
- Firestore batched writes for efficiency

### Theme System
- Material Design 3 color scheme seeding
- HSL color manipulation for dark mode
- Per-user theme persistence in Firestore
- 15 curated pastel color options
- Custom Product Sans typography

## Screenshots 📱

<p align="center">
  <img src="screenshots/app_icon.png" alt="App Icon" width="120" style="border-radius: 24px;">
</p>

### Onboarding
<p align="center">
  <img src="screenshots/introScreen1.png" alt="Intro 1" width="200">
  <img src="screenshots/introScreen2.png" alt="Intro 2" width="200">
  <img src="screenshots/introScreen3.png" alt="Intro 3" width="200">
  <img src="screenshots/introScreen4.png" alt="Intro 4" width="200">
</p>

### Authentication & Home
<p align="center">
  <img src="screenshots/loginscreen.PNG" alt="Login" width="200">
  <img src="screenshots/HomeScreen.PNG" alt="Home" width="200">
</p>

### AI Health Assistant
<p align="center">
  <img src="screenshots/AIChat.PNG" alt="AI Chat" width="200">
  <img src="screenshots/AIChatWithPicture.PNG" alt="AI Image Analysis" width="200">
</p>

### Clinic Discovery
<p align="center">
  <img src="screenshots/NearbyClinicsMap.png" alt="Clinics Map" width="200">
  <img src="screenshots/ClinicMapDetials.PNG" alt="Clinic Details" width="200">
</p>

### Appointment Booking
<p align="center">
  <img src="screenshots/makeAppointmentScreen1.png" alt="Select Category" width="200">
  <img src="screenshots/makeAppointmentScreen2.png" alt="Select Service" width="200">
  <img src="screenshots/makeAppointmentScreen3.png" alt="Select Date" width="200">
  <img src="screenshots/makeAppointmentScreen4.png" alt="Select Time" width="200">
</p>

### Appointments Management
<p align="center">
  <img src="screenshots/UpcomingAppointment.png" alt="Upcoming" width="200">
  <img src="screenshots/PassedAppointment.png" alt="Passed" width="200">
  <img src="screenshots/EmailNotficationResend.png" alt="Email Notification" width="200">
</p>

### Settings & Profile
<p align="center">
  <img src="screenshots/SettingsPage.png" alt="Settings" width="200">
  <img src="screenshots/SettingsPageDarkMode.png" alt="Dark Mode" width="200">
  <img src="screenshots/SettingsPageThemesOptions.png" alt="Themes" width="200">
</p>

### User Profile
<p align="center">
  <img src="screenshots/UpdateUserProfilePage.png" alt="Profile" width="200">
  <img src="screenshots/UpdateUserPhoneNumber.png" alt="Phone Input" width="200">
</p>

## API Keys Required 🔑

| Service | Purpose | Get Key |
|---------|---------|---------|
| **Google Gemini** | AI chat & image analysis | [AI Studio](https://aistudio.google.com/) |
| **Geoapify** | Clinic location data | [Geoapify](https://www.geoapify.com/) |
| **Resend** | Email notifications | [Resend](https://resend.com/) |
| **Cloudinary** | Profile image hosting | [Cloudinary](https://cloudinary.com/) |

## Firebase Collections 📊

### `appUsers`
```json
{
  "userid": "firebase-uid",
  "name": "John",
  "nameLast": "Doe",
  "email": "john@example.com",
  "contact": "+65 9123 4567",
  "age": "25",
  "gender": "Male",
  "profilePic": "https://cloudinary.com/...",
  "darkMode": false,
  "colorSeed": 4290190335,
  "savedClinics": ["place_id_1", "place_id_2"]
}
```

### `appointments`
```json
{
  "userId": "firebase-uid",
  "placeId": "clinic-place-id",
  "appointmentDateTime": "Timestamp",
  "serviceCategory": "Doctor Consultation",
  "serviceType": "General Consultation",
  "status": "upcoming",
  "additionalInfo": "",
  "createdAt": "Timestamp"
}
```

### `clinics`
```json
{
  "properties": {
    "name": "Clinic Name",
    "place_id": "geoapify-place-id",
    "address_line2": "Address",
    "opening_hours": "Mo-Fr 09:00-18:00",
    "contact": { "phone": "+65...", "email": "..." },
    "facilities": { "wheelchair": true }
  },
  "geometry": { "coordinates": [103.8, 1.3] }
}
```

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.

## License 📄

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgements 🙏

- [Flutter](https://flutter.dev/) - UI framework
- [Firebase](https://firebase.google.com/) - Backend services
- [Google Gemini](https://deepmind.google/technologies/gemini/) - AI capabilities
- [Geoapify](https://www.geoapify.com/) - Location data
- [OpenStreetMap](https://www.openstreetmap.org/) - Map tiles
