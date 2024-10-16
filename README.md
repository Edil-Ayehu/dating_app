# Dating App

## Table of Contents
1. [Introduction](#introduction)
2. [Features](#features)
3. [Project Structure](#project-structure)
4. [Getting Started](#getting-started)
   - [Prerequisites](#prerequisites)
   - [Installation](#installation)
5. [Firebase Setup](#firebase-setup)
6. [Running the App](#running-the-app)
7. [Key Components](#key-components)
8. [State Management](#state-management)
9. [Authentication](#authentication)
10. [Database](#database)
11. [Storage](#storage)
12. [Theming](#theming)
13. [Contributing](#contributing)
14. [License](#license)

## Introduction
This Dating App is a Flutter-based mobile application that allows users to create profiles, match with other users, and interact with potential partners. The app uses Firebase for authentication, database, and storage functionalities.

## Features
- User authentication (Sign up, Login, Forgot Password)
- User profile creation and editing
- Matching system
- Real-time chat (TODO)
- Dark mode support

## Project Structure
The project follows a standard Flutter project structure with additional organization for better code management:

dating_app/
├── lib/
│ ├── models/
│ ├── providers/
│ ├── screens/
│ │ ├── auth/
│ │ ├── home/
│ │ └── profile/
│ ├── utils/
│ ├── widgets/
│ ├── export.dart
│ └── main.dart
├── test/
├── android/
├── ios/
├── web/
├── pubspec.yaml
└── README.md


## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- Firebase account

### Installation
1. Clone the repository:
   ```
   git clone https://github.com/yourusername/dating_app.git
   ```
2. Navigate to the project directory:
   ```
   cd dating_app
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```

## Firebase Setup
1. Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. Add an Android app to your Firebase project and download the `google-services.json` file.
3. Place the `google-services.json` file in the `android/app/` directory.
4. Add an iOS app to your Firebase project and download the `GoogleService-Info.plist` file.
5. Place the `GoogleService-Info.plist` file in the `ios/Runner/` directory.
6. Enable Authentication, Firestore, and Storage in your Firebase project.

## Running the App
To run the app on an emulator or physical device:
```
flutter run
```

## Key Components

### Screens
1. SplashScreen (`lib/screens/splash_screen.dart`):
   - Checks the user's authentication state and navigates accordingly.

2. LoginScreen (`lib/screens/auth/login_screen.dart`):
   - Handles user login functionality.

3. SignupScreen (`lib/screens/auth/signup_screen.dart`):
   - Manages user registration process.

4. ForgotPasswordScreen (`lib/screens/auth/forgot_password_screen.dart`):
   - Allows users to reset their password.

5. HomeScreen (`lib/screens/home/home_screen.dart`):
   - Displays potential matches and main app functionality.

6. ProfileScreen (`lib/screens/profile/profile_screen.dart`):
   - Shows user profile and allows editing.

### Models
- UserModel (`lib/models/user_model.dart`):
  - Represents the user data structure.

### Providers
- AuthProvider (`lib/providers/auth_provider.dart`):
  - Manages authentication state and user-related operations.

- ThemeProvider (`lib/providers/theme_provider.dart`):
  - Handles app theme changes.

## State Management
The app uses Provider for state management. The main providers are:
- AuthProvider: Manages user authentication state.
- ThemeProvider: Handles app theme (light/dark mode).

## Authentication
Firebase Authentication is used for user sign-up, login, and password reset functionalities. The `AuthProvider` class in `lib/providers/auth_provider.dart` handles these operations.

## Database
Firestore is used as the database for storing user profiles and other app data. User profiles are stored in the 'users' collection.

## Storage
Firebase Storage is used for storing user profile images. The `_uploadImage` method in `ProfileScreen` handles image uploads.

## Theming
The app supports both light and dark modes. The theme can be toggled using the icon in the app bar. The `ThemeProvider` manages theme changes.

## Contributing
Contributions to the project are welcome. Please follow these steps:
1. Fork the repository
2. Create a new branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details.