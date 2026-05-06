# 🚀 Flutter Analytics & Admin Dashboard

A high-performance, professional-grade analytics dashboard built with Flutter. This project demonstrates advanced data visualization, complex drill-down interactions, and a robust administrator management system.

![App Header](https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/catalog-widget-placeholder.png)

## 🌟 Key Features

### 📊 Advanced Analytics
- **3-Level Sales Drill-Down**: Interactive geographic analysis from Country → State → City with paginated city results.
- **Dynamic Charting**: 
  - **Revenue Trends**: Interactive line charts with cubic-bezier smoothing and touch-responsive tooltips.
  - **Sales Analysis**: Modern donut charts showing success rates and percentage distributions.
- **Location-Based Insights**: Real-time sales data extraction with smart identifier mapping (supports names and ISO codes).

### 🛡️ Admin Management
- **User Administration**: Complete CRUD operations for managing dashboard users.
- **Instant Search**: Optimized client-side filtering for ultra-responsive user discovery.
- **Security Controls**: One-tap functionality to Enable/Disable accounts or Reset Passwords via secure bottom sheets.
- **Role-Based UI**: Automated UI adjustments based on user roles (Admin vs. User).

### 🎨 Premium UI/UX
- **Unified Design System**: A consistent "branded" experience with standardized buttons, text fields, and typography.
- **Adaptive Dark Mode**: Fully responsive theme that looks stunning in both light and dark environments.
- **Interactive Micro-animations**: Smooth transitions and touch effects on charts for an "alive" dashboard feel.

---

## 🏗️ Technical Architecture

This project follows **Feature-First Clean Architecture** principles, ensuring high maintainability and scalability.

- **State Management**: [Riverpod](https://riverpod.dev/) (Providers, FutureProviders, and StateProviders) for reactive and testable state.
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) for declarative, URL-based routing.
- **Networking**: [Dio](https://pub.dev/packages/dio) with custom interceptors for Auth, Logging, and centralized Error Handling.
- **Persistence**: [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) for sensitive session data.
- **Visualization**: [fl_chart](https://pub.dev/packages/fl_chart) for high-performance canvas-based rendering.

---

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- A running instance of the Dashboard API

### Installation
1. **Clone the repository**
   ```bash
   git clone https://github.com/ajithmannarakkal/flutter_analytics_dashboard.git
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment**
   Update `lib/core/network/api_constants.dart` with your server's base URL.

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 📁 Folder Structure
```text
lib/
 ├── core/              # Shared utilities, themes, and network logic
 ├── features/
 │    ├── auth/         # Login, Session management, and User models
 │    ├── admin/        # User management, Search, and Admin tools
 │    └── analytics/    # Charts, Drill-downs, and Sales reports
 └── main.dart          # Entry point
```

---

## 🔒 Permissions
The app is pre-configured for production with:
- **Android**: `INTERNET` permission added for secure API communication in Release mode.
- **iOS/macOS**: App Sandbox network entitlements configured.

---

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

---
*Created by [Ajith Mannarakkal](https://github.com/ajithmannarakkal)*
