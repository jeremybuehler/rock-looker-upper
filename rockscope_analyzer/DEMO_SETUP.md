# RockScope Analyzer - Demo Setup Guide

## Overview
This is a clickable Flutter prototype for the RockScope Analyzer app - a comprehensive geological specimen identification and field research tool. The app includes fully functional navigation between all screens with rich mock data for demonstration purposes.

## Features Implemented
✅ **Collection Manager** - Home screen with 25+ specimen samples  
✅ **Camera Capture** - Simulated camera interface with AI identification  
✅ **Specimen Identification** - Detailed rock and mineral analysis  
✅ **Field Notes** - Research documentation with location data  
✅ **Database Browser** - Comprehensive geological database  
✅ **Symbol Detail View** - Detailed specimen information  

## Mock Data Included
- **25+ Rock & Mineral Specimens** with detailed properties
- **15+ Field Notes** with location and research data
- **19+ Geological Database Entries** categorized by type
- **Comprehensive Rock Database** covering Igneous, Sedimentary, and Metamorphic rocks
- **Ocean-specific specimens** including hydrothermal deposits, manganese nodules, etc.

## Quick Start (Web Demo)

### Option 1: Flutter Web (Recommended)
If you have Flutter installed:

```bash
cd /Users/buehler/Documents/repos/rock-looker-upper/rockscope_analyzer
flutter pub get
flutter run -d chrome
```

### Option 2: Run without Flutter CLI
If Flutter is not in PATH but installed:

```bash
cd /Users/buehler/Documents/repos/rock-looker-upper/rockscope_analyzer
~/flutter/bin/flutter pub get
~/flutter/bin/flutter run -d chrome
```

### Option 3: Install Flutter (if needed)
```bash
# Download Flutter
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Add to PATH (add this to your ~/.zshrc or ~/.bash_profile)
export PATH="$HOME/flutter/bin:$PATH"

# Verify installation
flutter doctor

# Then run the app
cd /Users/buehler/Documents/repos/rock-looker-upper/rockscope_analyzer
flutter pub get
flutter run -d chrome
```

## Project Structure

```
rockscope_analyzer/
├── lib/
│   ├── core/
│   │   └── app_export.dart          # Central exports
│   ├── models/
│   │   └── specimen_model.dart      # Data models
│   ├── services/
│   │   ├── rock_database_service.dart    # 19+ geological specimens
│   │   └── field_notes_service.dart      # 5+ field research notes
│   ├── presentation/
│   │   ├── collection_manager/      # Home screen with 25+ specimens
│   │   ├── camera_capture/          # AI identification interface
│   │   ├── specimen_identification/ # Detailed analysis view
│   │   ├── field_notes/            # Research documentation
│   │   ├── database_browser/        # Geological database
│   │   └── symbol_detail_view/     # Detailed specimen info
│   ├── routes/
│   │   └── app_routes.dart         # Navigation configuration
│   └── main.dart                   # Application entry point
├── assets/                         # Images and resources
├── web/                           # Web-specific files
└── pubspec.yaml                   # Dependencies
```

## Navigation Flow

1. **Collection Manager (Home)** 
   - View 25+ generated specimens
   - Search and filter functionality
   - Navigate to other screens

2. **Camera Capture**
   - Simulated camera interface
   - Mock AI identification results
   - Link to specimen details

3. **Specimen Identification**
   - Detailed analysis view
   - Physical properties and composition
   - Usage and formation information

4. **Field Notes**
   - 5+ research documentation entries
   - Location-based organization
   - Priority and collaboration features

5. **Database Browser**
   - 19+ comprehensive geological specimens
   - Advanced search and filtering
   - Alphabetical index navigation

6. **Symbol Detail View**
   - Detailed specimen information
   - Scientific classification
   - Visual documentation

## Demo Data Highlights

### Rock Database (19+ Specimens)
- **Igneous**: Granite, Gabbro, Diorite, Basalt, Andesite, Rhyolite
- **Sedimentary**: Sandstone, Shale, Conglomerate, Limestone, Dolostone
- **Metamorphic**: Gneiss, Schist, Slate, Marble, Quartzite
- **Ocean Specimens**: Pillow Basalt, Manganese Nodules, Serpentinite, Hydrothermal Sulfides

### Collection Manager (25+ Generated Specimens)
- Realistic confidence scores (60-95%)
- Ocean locations and coordinates
- Recent dates (last 30 days)
- Various geological formations

### Field Notes (5+ Research Entries)
- Hydrothermal vent field surveys
- Mid-ocean ridge basalt collection
- Abyssal plain sediment analysis
- Seamount exploration data
- Transform fault investigations

## Interactive Features

### Fully Clickable UI
- All buttons and navigation elements work
- Smooth transitions between screens
- Modal dialogs and bottom sheets
- Search and filter functionality
- Multi-select modes with actions

### Realistic Data Flow
- Search results update in real-time
- Filter combinations work properly
- Sort options affect display order
- Export functions show success messages
- Statistics update based on data

### Responsive Design
- Optimized for web demonstration
- Grid layouts adapt to screen size
- Touch-friendly interface elements
- Consistent theming throughout

## Technical Implementation

### Services Layer
- **RockDatabaseService**: Manages geological specimen database
- **FieldNotesService**: Handles research documentation
- **Mock AI Identification**: Simulates specimen analysis

### State Management
- Local state management with StatefulWidget
- Proper data flow between services and UI
- Real-time updates for search and filtering

### Navigation
- Centralized route management
- Argument passing between screens
- Proper back navigation handling

## Web Demo Optimization
- Fast loading with compressed images
- Optimized for Chrome/Safari
- Responsive design for desktop viewing
- Mock camera functionality for web safety

## Troubleshooting

### Common Issues
1. **Flutter not found**: Install Flutter or use full path
2. **Dependencies error**: Run `flutter pub get` 
3. **Web not supported**: Ensure Flutter web is enabled
4. **Chrome not detected**: Use `flutter run -d web-server` instead

### Performance Tips
- Use Chrome for best performance
- Enable hardware acceleration
- Close other browser tabs while demo running

## Demo Script Suggestions

1. **Start at Collection Manager**
   - Show 25+ specimens with realistic data
   - Demonstrate search functionality
   - Try different filter options

2. **Navigate to Database Browser**
   - Explore the comprehensive geological database
   - Use alphabetical index navigation
   - Search for specific rock types

3. **View Field Notes**
   - Browse research documentation
   - Show detailed location data
   - Demonstrate priority filtering

4. **Camera Capture Demo**
   - Show simulated camera interface
   - Demonstrate AI identification results
   - Navigate to specimen details

5. **Specimen Identification**
   - View detailed analysis results
   - Show physical properties
   - Explore formation information

This Flutter prototype demonstrates a fully functional geological research application with comprehensive data and smooth navigation between all major features.