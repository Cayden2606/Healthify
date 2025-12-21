# Healthify 🏥

Making healthcare accessible, intelligent, and user-friendly. 🌟

Your health and wellness journey starts here. Healthify is a comprehensive Flutter application that provides AI-powered health assistance, appointment booking, and health management features.

## Features ✨

### 🤖 AI Health Assistant
- **Intelligent Chat Interface**: Powered by Google Gemini AI for natural health conversations
- **Image Analysis**: Upload medical images for AI-powered analysis and insights
- **Markdown Support**: Rich text formatting for clear, readable health information
- **Conversational Memory**: Maintains context throughout your health discussions

### 📅 Appointment Management
- **Smart Booking**: AI analyzes your needs and suggests appropriate appointment types
- **Location-Based**: Finds nearby clinics using GPS and distance calculation
- **Service Categories**: 
  - Doctor Consultation
  - Vaccination
  - Screening & Tests
  - Nursing Services
  - Allied Health
  - Dental

### 🗺️ Interactive Maps
- **Clinic Locator**: Interactive map showing nearby healthcare facilities
- **Distance Calculation**: Accurate distance measurements to healthcare providers
- **Real-time Location**: GPS integration for precise location services

### 👤 User Management
- **Profile Management**: Comprehensive user profiles with health information
- **Authentication**: Secure Firebase Authentication
- **Personalized Experience**: Tailored health recommendations

## Tech Stack 🛠️

- **Framework**: Flutter 3.6.0+
- **Backend**: Firebase (Authentication, Firestore)
- **AI Integration**: Google Gemini API
- **Maps**: Flutter Map with OpenStreetMap
- **State Management**: Provider
- **UI Components**: Material Design 3

## Dependencies 📦

### Core
- `flutter_gemini` - AI chat integration
- `dash_chat_2` - Chat interface
- `flutter_markdown` - Rich text rendering

### Firebase
- `firebase_core` - Core Firebase functionality
- `firebase_auth` - User authentication
- `cloud_firestore` - Database

### Location & Maps
- `flutter_map` - Interactive maps
- `geolocator` - GPS location services
- `latlong2` - Geographic coordinates

### UI/UX
- `provider` - State management
- `community_material_icon` - Extended icon set
- `font_awesome_flutter` - Additional icons
- `flutter_native_splash` - Custom splash screen

## Getting Started 🚀

### Prerequisites
- Flutter SDK 3.6.0 or higher
- Dart SDK
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Shockz132/Healthify
   cd Healthify
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   - Create a `.env` file in the root directory
   - Add your API keys:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   GEOAPIFY_API_KEY=your_geoapify_api_key_here
   RESEND_API_KEY=your_resend_api_key_here
   ```

4. **Firebase Configuration**
   - Configure Firebase Authentication and Firestore

5. **Run the application (using terminal)**
   ```bash
   flutter run
   ```

## Project Structure 📁

```
lib/
├── models/          # Data models (Clinic, GeminiAppointment, etc.)
├── screens/         # UI screens
│   ├── health_assistant.dart
│   └── make_appointments_screen.dart
├── utilities/       # Helper functions and Firebase calls
├── widgets/         # Reusable UI components
└── main.dart       # Application entry point
```

## Key Features Implementation 🔧

### AI Health Assistant
The health assistant uses Google Gemini to provide intelligent health guidance:
- Maintains conversation context
- Extracts appointment intent from natural language
- Provides markdown-formatted responses
- Supports image analysis for health-related queries

### Location Services
- Real-time GPS tracking
- Distance calculation using the Haversine formula
- Nearest clinic detection
- Interactive map integration

### Appointment Booking
- AI-powered service categorisation
- Integration with clinic availability
- Smart appointment suggestions based on user needs
