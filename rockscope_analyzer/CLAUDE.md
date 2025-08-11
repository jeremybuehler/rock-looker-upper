# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RockScope Analyzer is a Flutter-based mobile application for geological specimen identification and collection management. The app enables field researchers to identify rocks and minerals using AI-powered analysis, maintain detailed field notes, and organize their specimen collections.

## Development Commands

### Build and Run
```bash
# Install dependencies
flutter pub get

# Run the application (automatically selects available device)
flutter run

# Run on specific platform
flutter run -d chrome    # Web browser
flutter run -d ios       # iOS simulator
flutter run -d android   # Android emulator

# Build for production
flutter build apk --release        # Android APK
flutter build ios --release        # iOS (requires Xcode)
flutter build web --release        # Web deployment
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run a specific test file
flutter test test/widget_test.dart
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .

# Check for outdated dependencies
flutter pub outdated
```

## Architecture Overview

### Core Application Structure

The application follows a feature-based architecture with clear separation of concerns:

- **Presentation Layer** (`lib/presentation/`): Contains all UI screens and their associated widgets
  - Each feature has its own directory with the main screen and a `widgets/` subdirectory
  - Examples: `specimen_identification/`, `camera_capture/`, `field_notes/`, `collection_manager/`

- **Data Layer** (`lib/services/` and `lib/models/`):
  - `RockDatabaseService`: Singleton service managing the rock specimen database with ~30 pre-defined specimens
  - `FieldNotesService`: Manages field notes and voice recordings
  - `SpecimenModel`: Core data model with physical properties, mineralogy, and identification metadata

- **Routing** (`lib/routes/app_routes.dart`): Centralized navigation management with named routes

- **Theme System** (`lib/theme/app_theme.dart`): Comprehensive Material 3 theming with "Deep Ocean Professional" color palette optimized for field research

### Key Design Patterns

1. **Singleton Services**: Database and field notes services use singleton pattern for consistent data access
2. **Factory Constructors**: Models use factory constructors for JSON/Map conversion
3. **Widget Composition**: Complex UIs built from smaller, reusable widget components
4. **Responsive Design**: Uses Sizer package for responsive sizing (e.g., `50.w` for 50% width)

### Navigation Flow

The app has 6 main screens accessible via bottom navigation:
1. **Collection Manager**: Browse and manage collected specimens
2. **Database Browser**: Search and explore the rock database
3. **Specimen Identification**: AI-powered rock identification with compare mode
4. **Camera Capture**: Advanced camera interface for specimen photography
5. **Field Notes**: Voice recording and note-taking for field observations
6. **Symbol Detail View**: Detailed specimen information display

### State Management

Currently uses StatefulWidget for local state management. For cross-screen state sharing, data is passed through constructor parameters during navigation.

## Critical Configuration

### Dependencies (pubspec.yaml)
- **Core UI**: `sizer`, `flutter_svg`, `google_fonts` - DO NOT REMOVE
- **Data Storage**: `shared_preferences` for local persistence
- **Network**: `dio` for HTTP requests, `cached_network_image` for image caching
- **Media**: `camera`, `image_picker`, `record` for multimedia capture
- **Location**: `geolocator` for GPS coordinates
- **Visualization**: `fl_chart` for data visualization

### Asset Management
- Assets stored in `assets/` and `assets/images/` directories only
- DO NOT add new asset directories
- Uses Google Fonts instead of local fonts - DO NOT add font files

### Theme Customization
The app uses a scientific color palette optimized for outdoor visibility:
- Primary: Deep ocean teal (#1B4B5C)
- Accent: Coral orange (#FF6B35) for critical actions
- Success: Forest green (#059669)
- Error: Clear red (#DC2626)

## Development Guidelines

### Adding New Features
1. Create feature directory in `lib/presentation/`
2. Add route in `lib/routes/app_routes.dart`
3. Export any new models/services in `lib/core/app_export.dart`
4. Follow existing widget patterns for consistency

### Working with the Rock Database
- Database is hardcoded in `RockDatabaseService` with extensive specimen data
- Each specimen includes: mineralogy, physical properties, formation info, uses, and locations
- Use service methods for querying: `searchSpecimens()`, `getSpecimensByCategory()`, etc.

### Responsive Design
Always use Sizer units for responsive sizing:
- `.w` for width percentages (e.g., `50.w`)
- `.h` for height percentages (e.g., `20.h`)
- `.sp` for scaled font sizes (e.g., `14.sp`)

## Flutter Version Requirements
- Flutter SDK: ^3.29.2
- Dart SDK: ^3.6.0
- Minimum platform versions configured in platform-specific directories