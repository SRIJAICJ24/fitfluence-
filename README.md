# FitFluence

FitFluence is a social fitness application built with Flutter and Supabase.

## Prerequisites

- **Flutter SDK**: [Download & Install](https://docs.flutter.dev/get-started/install/windows)
- **Supabase Account**: You need a Supabase project for the backend.

## Getting Started

### 1. Setup Environment

Ensure Flutter is in your PATH. Open a terminal and run:

```bash
flutter doctor
```

Fix any issues listed (e.g., missing Android Toolchain or Visual Studio).

### 2. Install Dependencies

Navigate to the project directory and install the required packages:

```bash
cd fitfluence
flutter pub get
```

### 3. Configure Supabase

Open `lib/config/constants.dart` and update the following with your actual Supabase keys:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

*(Note: The app will run in "Mock Mode" for some features if these aren't set, but Authentication requires them.)*

### 4. Run the App

Connect a device (or start an emulator) and run:

```bash
flutter run
```

## Project Structure

- `lib/config`: Theme, Routes, Constants.
- `lib/features`: Feature-based architecture (Auth, Profile, Gym, Buddy, Messaging, Home).
- `lib/shared`: Reusable widgets (GlassContainer, MainShell).
- `backend`: SQL schemas for Supabase.

## Features Implemented (Phase 1)

- **Auth**: Login, OTP, Splash.
- **Profile**: Onboarding, Editing.
- **Gyms**: Search, Details.
- **Buddies**: 3D Swipe Discovery.
- **Messaging**: Real-time Chat UI.
- **Navigation**: Persistent Bottom Bar.
