# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS golf course visualization application built with UIKit. The app provides interactive 2D maps of golf courses with GPS coordinate transformation, distance measurements, and real-time course data from the Golf Course API.

## Architecture

- **Platform**: iOS (minimum deployment target: iOS 18.4)
- **Language**: Swift 5.0
- **UI Framework**: UIKit (no SwiftUI)
- **Architecture**: MVC pattern with delegate protocols for view communication
- **Bundle ID**: test.golf-demo
- **Navigation**: Programmatic UI (no storyboard segues for main flow)

### Core Architecture Components

**Data Layer:**
- `Models.swift` - Core data structures (`LatLng`, `Target`, `Shot`, `GeoCalibration`) and coordinate transformation
- `GolfCourseAPIService.swift` - API client with comprehensive data models (`GolfCourse`, `TeeBox`, `Hole`)

**View Layer:**
- `FairwayMapView.swift` - Custom UIView with gesture handling, rendering, and coordinate mapping
- `FairwayMapView+Gestures.swift` - Pan, zoom, tap gesture implementations
- `GolfCourseListViewController.swift` - Course selection with search and API integration
- `GolfCourseTableViewCell.swift` - Custom cells for course display

**Business Logic:**
- `CourseRenderer.swift` - Dynamic golf hole rendering based on par and yardage data
- `ViewController.swift` - Course detail view with interactive map controls

## Development Commands

### Building
```bash
# Build for Debug configuration
xcodebuild -project golf-demo.xcodeproj -scheme golf-demo -configuration Debug build

# Build for Release configuration  
xcodebuild -project golf-demo.xcodeproj -scheme golf-demo -configuration Release build

# Clean build folder
xcodebuild -project golf-demo.xcodeproj -scheme golf-demo clean
```

### Running
```bash
# Build and run in iOS Simulator (iPhone 15 recommended for testing)
xcodebuild -project golf-demo.xcodeproj -scheme golf-demo -destination 'platform=iOS Simulator,name=iPhone 15' build

# For development with Xcode:
open golf-demo.xcodeproj
```

### Testing
No test targets configured. API testing available through in-app "Test API" button which validates Golf Course API connectivity.

## Key Technical Patterns

### Coordinate System Architecture
- **GPS ↔ Pixel Transformation**: `GeoCalibration` class handles lat/lng to screen coordinate mapping using `CGAffineTransform`
- **Multi-transform Pipeline**: `imageFitTransform` → `userTransform` → `rotationTransform` for complex view transformations
- **Distance Calculations**: Implements haversine formula through `CLLocation.yardsBetween()` extension

### Custom View Pattern
- `FairwayMapView`: Core UIView subclass handling rendering, gestures, and coordinate mapping
- Delegate protocol `FairwayMapViewDelegate` for event communication
- Gesture recognizers: pan, pinch, tap, double-tap with animation support

### API Integration Pattern
- Async completion handlers for network calls
- Fallback mechanism: API → OpenStreetMap tiles → rendered course graphics
- Real-time tile downloading and combination for ground imagery

## Golf Map Implementation

### Files Added:
- `Models.swift` - Core data structures for golf course data
- `FairwayMapView.swift` - Main 2D golf map view implementation
- `FairwayMapView+Gestures.swift` - Gesture handling for pan/zoom/tap
- `GolfCourseAPIService.swift` - Golf Course API integration and sample data
- `CourseRenderer.swift` - Dynamic golf course rendering engine
- `GolfCourseListViewController.swift` - Course selection screen
- `GolfCourseTableViewCell.swift` - Custom cells for course display

### App Flow 📱

**1. Golf Course List Screen (First Screen)**
- **Loads REAL golf courses from API on app launch** 🎯
- Automatically searches for popular courses: "pebble beach", "augusta national", "st andrews", "torrey pines"
- Professional course cards showing course name, club name, location, and basic stats from real API data
- Search functionality adds more courses from Golf Course API (WYQ4EBPXAB25BH3X2B5ZJ5Z3U4)
- Fallback to sample courses only if API completely fails
- Loading indicators and error handling for API calls
- Refresh button to reload real courses from API
- Tap any course to navigate to detailed golf course view

**2. Golf Course Detail Screen**
- Shows rendered golf course ground based on selected course data
- Interactive 2D map with pan/zoom/gesture controls
- Player and pin locations with GPS coordinates
- Distance measurements and target overlays
- Course-specific rendering with Par 3/4/5 hole layouts

### Key Features:
- **Course Selection Flow**: Professional course list → detailed course view
- **Dynamic Course Rendering**: Realistic golf hole layouts based on API data
- **2D Golf Hole Visualization**: Different layouts for Par 3, 4, and 5 holes
- **GPS Coordinate Transformation**: lat/lng ↔ pixels with accurate mapping
- **Interactive Elements**: player position, pin placement, targets with touch controls
- **Multi-touch Gestures**: pan, zoom, tap, double-tap with animation
- **Distance Calculations**: Real-time yardage display and measurements
- **Golf Course API Integration**: Live search with key WYQ4EBPXAB25BH3X2B5ZJ5Z3U4

### Demo Controls (Course Detail Screen):
- Player: Center on player location
- Green: Zoom to green with animation
- Overlays: Toggle overlay visibility  
- Pin Mode: Enable/disable pin editing
- Test API: Live API testing with real course search
- Sample Course: Load rendered demonstration course

The implementation replicates GolfLogix's FairwayImageView functionality with a modern iOS course selection flow.

## API Integration Status - Updated

### Current Implementation:
- **Endpoint**: `https://api.golfcourseapi.com/v1/search`
- **Authentication**: Header-based with `Authorization: Key <api_key>`
- **Data Models**: Full OpenAPI spec compliance with proper Codable support
- **Parameters**: Uses `search_query` parameter as per OpenAPI specification
- **Response Parsing**: Complete data structures for courses, tee boxes, and holes

### API Features:
- Search courses by name/club name
- Get detailed course information with tee box data
- Proper error handling and debug logging
- Real course data integration with map visualization
- Test button for immediate API validation

### Demo Controls Updated:
- Player: Center on player location
- Green: Zoom to green with animation
- Overlays: Toggle overlay visibility  
- Pin Mode: Enable/disable pin editing
- **Test API**: Live API testing with real course search

## Development Guidelines

### When Adding Features:
- Follow MVC pattern with delegate protocols for view communication
- Use completion handlers for async operations (API calls, image downloads)
- Implement coordinate transformations through `GeoCalibration` for GPS accuracy
- Add gesture support through dedicated gesture recognizer methods
- Follow the fallback pattern: API → alternative data → rendered graphics

### When Debugging:
- Use "Test API" button for immediate API validation
- Check Xcode console for detailed API request/response logging
- GPS coordinates logged with 6 decimal precision
- All transformations logged with matrix values

### API Key Management:
The Golf Course API key `WYQ4EBPXAB25BH3X2B5ZJ5Z3U4` is embedded in `GolfCourseAPIService.swift`. For production:
1. Move to secure keychain storage
2. Verify key activation on golfcourseapi.com
3. Monitor quota usage through API dashboard