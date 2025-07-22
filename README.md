# Neptrek - Trek Discovery Application

Neptrek is a Flutter-based mobile application designed to help users discover, explore, and save their favorite trekking destinations. The app provides personalized trek recommendations and allows users to manage their favorite treks.

## Features

- **User Authentication**: Secure login and signup functionality
- **Trek Discovery**: Browse and search through various trekking destinations
- **Personalized Recommendations**: Get trek recommendations based on user interests
- **Favorites Management**: Save and manage favorite treks
- **Detailed Trek Information**: Access comprehensive details about each trek
- **Profile Management**: User profile customization and management
- **Responsive UI**: Clean and intuitive user interface

## Technology Stack

- **Frontend**: Flutter/Dart
- **State Management**: Provider Pattern
- **Network**: HTTP package for API integration
- **Local Storage**: Shared Preferences for token management
- **API Integration**: RESTful API integration

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK
- Android Studio / VS Code
- Android Emulator / iOS Simulator

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/subashghimirey/neptrek.git
   ```

2. Navigate to project directory:
   ```bash
   cd neptrek
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Update the API base URL in `lib/providers/trek_provider.dart` and `lib/providers/auth_provider.dart` to match your backend server.

5. Run the application:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── models/         # Data models
├── providers/      # State management
├── screens/        # UI screens
└── main.dart       # Entry point
```

## Key Features Implementation

### Authentication
- Token-based authentication
- Secure storage of user credentials
- Automatic login on app restart

### Trek Management
- Fetch and display trek listings
- Favorite/unfavorite functionality
- Detailed trek information view

### State Management
- Provider pattern for state management
- Centralized data store
- Efficient UI updates

## Building for Release

To create a release build:

```bash
flutter build apk --release         # For Android
flutter build ios --release        # For iOS
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

Subash Ghimire - [@subashghimirey](https://github.com/subashghimirey)
