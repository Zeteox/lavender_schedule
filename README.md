# Lavender Schedule 🪻

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![Flutter Version](https://img.shields.io/badge/flutter-%3E%3D3.19.0-02569B?logo=flutter)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/dart-%3E%3D3.3.0-0175C2?logo=dart)](https://dart.dev/)

---

## 📝 Description

**Lavender Schedule** is a cross-platform mobile application developed with Flutter, designed to help students organize their academic life.
It centralizes key university information, offering a soothing, lavender-themed interface. Built with an offline-first approach, it allows users to manage their timetables, track academic deadlines, and manage their personal budget effectively.

This project serves as a solid foundation for future evolutions, including cloud synchronization through the *lavenderAPI* ecosystem.

---

## 🌟 Features

- **📅 Timetable Management**
    - Daily and weekly views
    - Automatic synchronization via `.ics` URLs (Hyperplanning)
    - Detailed class information (Subject, Room, Teacher, Type)
- **⏰ Deadlines & Exams**
    - Track assignments, projects, and exams
    - Link tasks to specific subjects or unique classes
    - Smart local notifications and pre-class alarms
- **💰 Budget Tracking** *(Upcoming module)*
    - Quick expense additions & customizable categories
    - Monthly budgets and overspending alerts
- **📊 Dashboard & Statistics**
    - Weekly class hours tracking and upcoming deadlines overview
    - Responsive layout adapted for both Mobile and Tablets

---

## 🛠️ Tech Stack

- **Frontend**:
    - **Flutter** – UI Toolkit for building natively compiled applications
    - **Dart** – Programming language
- **State Management & Architecture**:
    - **Riverpod** – Robust and safe state management
    - Feature-oriented modular architecture
- **Data & Storage**:
    - **SharedPreferences** – Local data persistence for tasks and settings
    - **http** – API calls to fetch and parse `.ics` calendar files
- **System**:
    - **GoRouter** – Declarative routing

---

## ⚙️ Installation

To set up the project locally, follow these steps:

### **Prerequisites**

Make sure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) 📦
- Android Studio / Xcode (for emulators and build tools) 🔧

### **Project Setup**

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Zeteox/lavender_schedule.git
   cd Lavender-Schedule
    ```
2. **Install dependencies:**
   ```bash
    flutter pub get
   ```
3. **Generate native icons (Optional):**
    ```Bash
    flutter pub run flutter_launcher_icons
    ```
4. **Run the application:**
    ```Bash
    flutter run
    ```
---
## 🏗️ Project Structure
The project follows a modular and feature-oriented architecture:

```Plaintext
├── 📁 assets/
│   └── 📁 images/
│       └── 🖼️ logo.png
├── 📁 lib/
│   ├── 📁 model/               # Data structures
│   │   └── 📄 school_class.dart
│   ├── 📁 providers/           # Riverpod state management
│   │   ├── 📄 alarm_settings_provider.dart
│   │   ├── 📄 class_provider.dart
│   │   ├── 📄 selected_class_provider.dart
│   │   └── 📄 task_provider.dart
│   ├── 📁 router/              # GoRouter configuration
│   │   └── 📄 main.dart
│   ├── 📁 ui/                  # User Interface & Pages
│   │   ├── 📄 calendar_page.dart
│   │   ├── 📄 dashboard_page.dart
│   │   ├── 📄 day_detail_page.dart
│   │   ├── 📄 edit_task_page.dart
│   │   ├── 📄 main_navigation_screen.dart
│   │   └── 📄 splash_screen.dart
│   ├── 📁 utils/               # Helpers and logic
│   │   ├── 📄 dialog_utils.dart
│   │   ├── 📄 scrapper.dart    # .ics parser
│   │   └── 📄 task_utils.dart
│   └── 📄 main.dart            # Entry point & App Theme
├── 📄 pubspec.yaml
└── 📖 README.md
```
---
## 🎮 Usage
1. Open the app and wait for the Splash Screen.
2. On the Dashboard, click the gear icon to configure your schedule.
3. Paste your .ics calendar URL (e.g., from Hyperplanning). The app will automatically fetch and parse your classes.
4. Navigate to the Saisie tab to add assignments (Rendus) or notes to specific modules.
5. Use the Planning tab to visualize your week, and tap any class to see its details and associated tasks.
---
## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for more details.

---
## 📬 Contact
For any questions or issues, feel free to reach out:

### Loïc DELPRAT
- **Email** : [loic.delprat@ynov.com](mailto:loic.delprat@ynov.com)
- **LinkedIn** : [Loïc DELPRAT](https://linkedin.com/in/loïc-delprat)
- **GitHub** : [Zeteox](https://github.com/Zeteox)

### Ylan DESSENE
- **Email** : [ylan.dessenne@ynov.com](mailto:ylan.dessenne@ynov.com)
- **LinkedIn** : [ylan DESSENNE](https://linkedin.com/in/dessenne-ylan)
- **GitHub** : [Torolgo](https://github.com/Torolgo)