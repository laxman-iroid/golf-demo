# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS golf course visualization application built with UIKit. The app provides interactive 2D maps of golf courses with GPS coordinate transformation, distance measurements, and real-time course data from the Golf Course API.

## Architecture

- **Platform**: iOS (minimum deployment target: iOS 15.0)
- **Language**: Swift 5.0
- **UI Framework**: UIKit with Storyboards (no SwiftUI)
- **Architecture**: MVC pattern with delegate protocols for view communication
- **Bundle ID**: com.forcegolf.iroid.app
- **Dependency Management**: CocoaPods
- **Navigation**: Mixed - Storyboard-based with programmatic transitions

### Core Architecture Components

**Data Layer:**
- `Models.swift` - Core data structures (`LatLng`, `Target`, `Shot`, `GeoCalibration`) and coordinate transformation
- `GolfCourseAPIService.swift` - API client with comprehensive data models (`GolfCourse`, `TeeBox`, `Hole`)
- `Model/` - Request/response models for API communication
- `ApiManager/` - Centralized networking with service wrappers

**View Layer:**
- `FairwayMapView.swift` - Custom UIView with 2D golf course rendering and gesture handling
- `FairwayMapView+Gestures.swift` - Pan, zoom, tap gesture implementations
- `GoogleMapsViewController.swift` - Google Maps integration with real-time location tracking
- `GolfCourseListViewController.swift` - Course selection with search and API integration
- `Auth/` - Login and sign-up screens

**Business Logic:**
- `CourseRenderer.swift` - Dynamic golf hole rendering based on par and yardage data
- `ViewController.swift` - Course detail view with interactive map controls
- `SocketIOManager.swift` - Real-time location updates via Socket.IO
- `Library/` - Shared utilities, extensions, and UI components

## Development Commands

### Dependencies
```bash
# Install CocoaPods dependencies (required before first build)
pod install

# Update dependencies
pod update
```

### Building
```bash
# IMPORTANT: Always use .xcworkspace, not .xcodeproj (CocoaPods requirement)

# Build for Debug configuration
xcodebuild -workspace golf-demo.xcworkspace -scheme golf-demo -configuration Debug build

# Build for Release configuration
xcodebuild -workspace golf-demo.xcworkspace -scheme golf-demo -configuration Release build

# Clean build folder
xcodebuild -workspace golf-demo.xcworkspace -scheme golf-demo clean
```

### Running
```bash
# Build and run in iOS Simulator (iPhone 15 recommended for testing)
xcodebuild -workspace golf-demo.xcworkspace -scheme golf-demo -destination 'platform=iOS Simulator,name=iPhone 15' build

# For development with Xcode:
open golf-demo.xcworkspace  # NOT golf-demo.xcodeproj
```

### Testing
No test targets configured. API testing available through in-app "Test API" button which validates Golf Course API connectivity.

## Key Technical Patterns

### Dual Map System
The app uses **two different map implementations**:

1. **2D Custom Rendering** (`FairwayMapView.swift`)
   - Custom UIView with GPS ↔ pixel transformation via `GeoCalibration`
   - Multi-transform pipeline: `imageFitTransform` → `userTransform` → `rotationTransform`
   - Fallback: API → OpenStreetMap tiles → rendered course graphics
   - Used in `ViewController.swift` for course detail view

2. **Google Maps Integration** (`GoogleMapsViewController.swift`)
   - Real-time location tracking with `CLLocationManager`
   - Socket.IO for multi-user location sharing
   - Dynamic polyline drawing between players
   - Auto-rotation based on hole bearing (tee → green)
   - Distance calculations between multiple points

### Real-Time Features
- **Socket.IO Integration**: Live location updates emitted every 5 seconds
- **Multi-user Tracking**: Dictionary-based marker management for other users
- **Event System**: `SocketHelper.Events.updateUserLocation` for pub/sub pattern
- **Throttled Updates**: Location updates limited by `locationUpdateInterval`

### API Integration Pattern
- **AlamofireObjectMapper**: JSON → Swift model mapping
- **Completion handlers**: Async network calls with success/failure callbacks
- **Golf Course API**: Real course data with tee boxes, holes, and GPS coordinates
- **Backend Services**: `ApiManager/` with modular service structure

## App Flow & Features

### Navigation Structure
```
AppDelegate.swift (Initial setup)
    ↓
ViewController.swift (2D Custom Map View)
    ↓
GolfCourseListViewController.swift (Course Selection)
    ↓
GoogleMapsViewController.swift (Real-time Google Maps with multi-user tracking)
```

### Screen Details

**1. Course List Screen** (`GolfCourseListViewController`)
- Auto-loads popular courses: "pebble beach", "augusta national", "st andrews", "torrey pines"
- Search functionality via Golf Course API (key: `WYQ4EBPXAB25BH3X2B5ZJ5Z3U4`)
- Custom `GolfCourseTableViewCell` with course details
- Fallback to sample courses if API fails
- Navigates to either custom 2D view or Google Maps view

**2. Custom 2D Map View** (`ViewController` + `FairwayMapView`)
- Rendered golf course with custom drawing
- Par 3/4/5 hole layouts via `CourseRenderer`
- GPS coordinate transformation and distance measurements
- Touch gestures: pan, zoom, tap, double-tap

**3. Google Maps View** (`GoogleMapsViewController`)
- **Real-time location tracking** with `CLLocationManager`
- **Multi-user support** via Socket.IO (emits location every 5 seconds)
- **Dynamic polylines** between two players and midpoint
- **Draggable midpoint marker** with live distance updates
- **Auto-rotation** to align tee → green vertically on screen
- **Hole navigation** with Previous/Next buttons
- **Distance labels** showing meters from each player to midpoint
- **Zoom level display** and camera bounds restriction

## Dependencies (from Podfile)

- **AlamofireObjectMapper** (~> 5.2): Networking with JSON mapping
- **NotificationBannerSwift**: In-app notification UI
- **lottie-ios**: Animation support
- **Socket.IO-Client-Swift** (~> 16.1.1): Real-time WebSocket communication
- **IQKeyboardManagerSwift**: Automatic keyboard handling
- **GoogleMaps**: Integrated via Info.plist key `GMSApiKey`

## API Integration

### Golf Course API
- **Endpoint**: `https://api.golfcourseapi.com/v1/search`
- **Authentication**: Header `Authorization: Key WYQ4EBPXAB25BH3X2B5ZJ5Z3U4`
- **Models**: `GolfCourse`, `TeeBox`, `Hole` (Codable-based)
- **Service**: `GolfCourseAPIService.swift` with completion handlers
- **Static Data**: `PebbleBeachStaticData.swift` for demo GPS coordinates

### Backend API
- **Base URL**: Configured in `WebServicesUrls.swift`
- **Services**: `LogInServices.swift` for authentication
- **Request/Response**: Models in `Model/` directory
- **Manager**: `ApiManager.swift` with AlamofireObjectMapper integration

## Development Guidelines

### Project Setup
1. **Always use workspace**: `open golf-demo.xcworkspace` (NOT .xcodeproj)
2. **Install pods first**: Run `pod install` before building
3. **Google Maps API Key**: Configured in Info.plist as `GMSApiKey`
4. **Socket.IO**: Configure endpoint in `SocketIOManager.swift`

### When Adding Features
- **MVC Pattern**: ViewControllers manage views, Models handle data, delegate protocols for communication
- **Async Operations**: Use completion handlers for network calls and location updates
- **Extensions**: Extensive UIKit extensions in `Library/Extension/` - check before duplicating
- **Reusability**: Shared utilities in `Library/Utility.swift` and `Constant.swift`
- **Location Updates**: Throttle with `locationUpdateInterval` to avoid excessive Socket.IO traffic

### Real-Time Features
- **Socket Events**: Define in `SocketHelper.Events` enum for type-safety
- **User Tracking**: Use dictionary-based marker management (see `GoogleMapsViewController:168`)
- **Connection Lifecycle**: Always disconnect socket in `viewWillDisappear`
- **Error Handling**: Check `SocketHelper.shared.checkConnection()` before emitting

### Debugging
- **Location**: GPS coordinates logged with precision (see `GoogleMapsViewController:463-466`)
- **Socket.IO**: Extensive logging with emoji indicators (✅ ❌ 📍 🔄 📡)
- **API Calls**: Enable debug logging in `ApiManager` and `GolfCourseAPIService`
- **Transformations**: Matrix values logged for coordinate transformations

### Important Notes
- **Two Map Systems**: Don't confuse `FairwayMapView` (custom 2D) with `GoogleMapsViewController` (Google Maps SDK)
- **Authentication**: Login screens exist but may not be enforced on app launch
- **Static Data**: `PebbleBeachStaticData.swift` provides fallback GPS coordinates for 18 holes