# Eni - Unified Flutter Application

A unified Flutter project combining modern UI practice designs and Riverpod state management into a single application.

## Features

- **Home Screen**: Modern lifestyle and habit dashboard with custom headers, daily inspiration cards, horizontal quote carousel, and category grid.
- **Riverpod State Management**: Interactive `StateProvider` counter tutorial demonstrating `ref.watch`, `ref.read`, and scoped reactivity.
- **Profile & Settings**: User profile display with dynamic Riverpod-powered Dark/Light theme switching (`themeModeProvider`).
- **Interactive Login**: Clean authentication UI screen (`Homepage`).
- **Notifications**: Notification feed and updates center.
- **Unified Navigation**: Custom floating bottom navigation bar connecting all core modules.

## Architecture

- **State Management**: `flutter_riverpod` (`ProviderScope`, `StateProvider`, `ConsumerWidget`)
- **Design System**: Centralized color palette, typography tokens, and light/dark theme definitions in `lib/app_style.dart`.
- **Project Structure**:
  - `lib/`
    - `main.dart` - Entry point wrapping `ProviderScope` and reactive `MyApp`
    - `app_style.dart` - Styles, theme providers, and `AppTheme`
    - `homepage.dart` - Authentication and login screen
    - `screens/`
      - `bottom_bar.dart` - Root persistent navigation bar
      - `home_screen.dart` - Habits, quotes, and categories dashboard
      - `state_provider_screen.dart` - Riverpod state management tutorial
      - `notification_screen.dart` - Notification list
      - `profile_screen.dart` - Profile and settings with theme switch
      - `proifle_screen.dart` - Backward-compatibility alias

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the application:
   ```bash
   flutter run
   ```

3. Run tests:
   ```bash
   flutter test
   ```
