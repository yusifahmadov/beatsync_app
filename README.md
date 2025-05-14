# Beatsync App

Your personal heart health companion. Monitor, analyze, and understand your heart's rhythm.

## Overview

Beatsync App is a Flutter-based mobile application designed to help users track their cardiovascular health. It allows for real-time heart rate monitoring (utilizing the phone's camera), stores PPG sensor data, and provides insightful Heart Rate Variability (HRV) analysis. The app aims to empower users with data-driven insights into their well-being and stress levels.

## ✨ Key Features

*   ❤️ **Real-time Heart Rate Monitoring:** Track your heart rate using your phone's camera.
*   📊 **Comprehensive HRV Analysis:** Gain insights with metrics like SDNN, RMSSD, and LF/HF ratio.
*   👤 **Secure User Authentication:** JWT-based registration, login, and profile management.
*   📅 **Historical Data Tracking:** Review your past measurements and HRV trends.
*   📱 **Cross-Platform:** Built with Flutter for a consistent experience on iOS and Android.
*   🎨 **Intuitive User Interface:** Clean and user-friendly design for ease of use.

## 🛠️ Tech Stack

*   **Frontend:** Flutter, Dart
*   **State Management:** flutter_bloc (BLoC/Cubit pattern)
*   **API Communication:** Dio
*   **Environment Variables:** `flutter_dotenv` for managing configurations.
*   **Routing:** `go_router`
*   **Local Storage:** `shared_preferences` 

## 📋 Prerequisites

*   Flutter SDK (Recommended: 3.19.x or later)
*   Dart SDK (comes with Flutter)
*   An IDE like VS Code or Android Studio
*   An emulator or physical device (iOS/Android) for running the app.

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

**1. Clone the Repository:**
```bash
git clone https://github.com/your-username/beatsync_app.git # Replace with your actual repository URL
cd beatsync_app
```

**2. Set Up Environment Variables:**
The application uses an `.env` file for sensitive configurations like API keys or base URLs.
*   Create a file named `.env` in the `assets/` directory (i.e., `assets/.env`).
*   Populate it with the necessary environment variables. Refer to `assets/.env.example` if provided, or use the following template:

    ```env
    # BASE_URL=http://localhost:3000/api
    ```

**3. Install Dependencies:**
Navigate to the project root and run:
```bash
flutter pub get
```

**4. Run the App:**
```bash
flutter run
```
To run on a specific device, you can use `flutter run -d <deviceId>`.

## 📂 Project Structure (Simplified)

A brief overview of the main directories within `lib/`:

```
lib/
├── app.dart                # Main application widget & setup
├── main.dart               # Main entry point of the application
├── core/                   # Core utilities, services, routing, theme, etc.
├── di/                     # Dependency injection setup (e.g., GetIt)
├── features/               # Feature-specific modules (e.g., authentication, heart_rate)
│   ├── authentication/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/   # Widgets, screens, cubits for this feature
│   └── ...                 # Other features
└── ...
```

## 🤝 Contributing

Contributions are welcome! If you'd like to contribute, please follow these steps:
1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the `LICENSE` file for details (if one exists).
