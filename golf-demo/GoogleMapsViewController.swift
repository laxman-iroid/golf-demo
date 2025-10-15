import UIKit
import GoogleMaps
import CoreLocation

class GoogleMapsViewController: UIViewController {

    @IBOutlet weak var mainMapView: UIView!
    @IBOutlet weak var tableViewBackegroundView: UIView!
    @IBOutlet weak var infoTableView: UITableView!
    
    // MARK: - Properties
    var selectedCourse: GolfCourse?
    var selectedHoleNumber: Int = 1  // Default to hole 18
    private var golfFeatures: [GolfCourseFeature] = []

    private var mapView: GMSMapView!
    private var locationManager = CLLocationManager()
    private var lastLocationUpdateTime: Date?
    private let locationUpdateInterval: TimeInterval = 5.0 // Update every 5 seconds

    // Three points for the polyline
    private var player1Point: CLLocationCoordinate2D!  // Red player
    private var player2Point: CLLocationCoordinate2D!  // Green player
    private var midPoint: CLLocationCoordinate2D!      // White mid point

    // Map markers
    private var player1Marker: GMSMarker?
    private var player2Marker: GMSMarker?
    private var midMarker: GMSMarker?
    
    // User location markers
    private var userMarkers: [String: GMSMarker] = [:]  // Dictionary to store user markers by userId

    // Polyline segments
    private var polylinePlayer1ToMid: GMSPolyline?
    private var polylinePlayer2ToMid: GMSPolyline?

    // Radius circle around midpoint
    private var midPointCircle: GMSCircle?
    private var centerDotMarker: GMSMarker?  // White dot at center

    // Hole navigation
    private var holeInfoLabel: UILabel!
//    private var previousHoleButton: UIButton!
//    private var nextHoleButton: UIButton!

    // Rotation controls
    private var rotateLeftButton: UIButton!
    private var rotateRightButton: UIButton!
    private var resetNorthButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocationManager()
        setupMapView()
       // setupHoleNavigationUI()
       // setupRotationControls()

        // Use selected course if available, otherwise use default
        if let course = selectedCourse {
//            initializePointsFromCourse(course)
            initializeDefaultPoints()
        } else {
            initializeDefaultPoints()
        }
        setupCell()
        setupTableViewGradient()
        loadGolfFeatures()
        setupMarkers()
        drawPolylines()
        updateDistanceLabels()
      //  updateHoleInfo()
        centerMapOnHole()
        setupSocket()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        disconnectSocket()
    }

    func setupCell(){
        self.infoTableView.dataSource = self
        self.infoTableView.delegate = self
        self.infoTableView.register(UINib(nibName: "InfoTableViewCell", bundle: nil), forCellReuseIdentifier: "InfoTableViewCell")
    }
    
    private func setupTableViewGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = tableViewBackegroundView.bounds
        
        // Create a horizontal gradient with intense white glow growing from the right side
        gradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor.white.withAlphaComponent(0.7).cgColor,
            UIColor.white.withAlphaComponent(0.7).cgColor,
            UIColor.white.withAlphaComponent(0.1).cgColor
        ]
        
        // Set gradient direction (horizontal - left to right)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        // Position the gradient colors to create a more intense glow effect from the right
        gradientLayer.locations = [0.0, 0.5, 0.8, 1.0]
        
        // Add the gradient layer to the background view
        tableViewBackegroundView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Store reference for later frame updates
        tableViewBackegroundView.layer.setValue(gradientLayer, forKey: "gradientLayer")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update gradient frame when view layout changes
        if let gradientLayer = tableViewBackegroundView.layer.value(forKey: "gradientLayer") as? CAGradientLayer {
            gradientLayer.frame = tableViewBackegroundView.bounds
        }
    }
    
    private func loadGolfFeatures() {
        golfFeatures = GolfCourseFeatureData.getHoleFeatures()
        infoTableView.reloadData()
    }
    
    // MARK: - Socket Setup
    private func setupSocket() {
        SocketHelper.shared.connectSocket { [weak self] success in
            if success {
                print("✅ Socket connected successfully")
                self?.setupLocationListener()
            } else {
                print("❌ Failed to connect socket")
            }
        }
    }
    
    private func setupLocationListener() {
        // Listen for other users' location updates
        SocketHelper.Events.updateUserLocation.listen { [weak self] response in
            print("📍 Received location update from other user: \(response)")
            
            if let locationData = response as? [String: Any],
               let latitude = locationData["latitude"] as? Double,
               let longitude = locationData["longitude"] as? Double,
               let userId = locationData["userId"] as? String {
                
                DispatchQueue.main.async {
                    self?.handleOtherUserLocationUpdate(userId: userId, latitude: latitude, longitude: longitude)
                }
            }
        }
    }
    
    private func handleOtherUserLocationUpdate(userId: String, latitude: Double, longitude: Double) {
        print("🔄 Updating other user location - ID: \(userId), Lat: \(latitude), Lng: \(longitude)")
        
        // Don't show marker for current user
        if userId == String(Utility.getUserData()?.id ?? 0) {
            return
        }
        
        let userLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Check if marker already exists for this user
        if let existingMarker = userMarkers[userId] {
            // Update existing marker position
            existingMarker.position = userLocation
            print("📍 Updated existing marker for user: \(userId)")
        } else {
            // Create new marker for this user
            let userMarker = GMSMarker(position: userLocation)
            userMarker.title = "User: \(userId)"
            userMarker.snippet = "Online User"
            userMarker.icon = createUserMarkerIcon()
            userMarker.map = mapView
            
            // Store the marker in dictionary
            userMarkers[userId] = userMarker
            print("✅ Created new marker for user: \(userId)")
        }
    }
    
    private func createUserMarkerIcon() -> UIImage? {
        let size = CGSize(width: 40, height: 40)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Draw orange circle for other users
        let circleRect = CGRect(x: 5, y: 5, width: 30, height: 30)
        context.setFillColor(UIColor.systemOrange.cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(3)
        context.addEllipse(in: circleRect)
        context.drawPath(using: .fillStroke)
        
        // Add user icon in the center
        let iconSize: CGFloat = 16
        let iconRect = CGRect(
            x: (size.width - iconSize) / 2,
            y: (size.height - iconSize) / 2,
            width: iconSize,
            height: iconSize
        )
        
        // Draw simple user icon (person symbol)
        context.setFillColor(UIColor.white.cgColor)
        let headRect = CGRect(x: iconRect.midX - 3, y: iconRect.minY + 2, width: 6, height: 6)
        context.addEllipse(in: headRect)
        context.fillPath()
        
        let bodyRect = CGRect(x: iconRect.midX - 4, y: iconRect.minY + 8, width: 8, height: 6)
        context.addEllipse(in: bodyRect)
        context.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private func removeUserMarker(userId: String) {
        if let marker = userMarkers[userId] {
            marker.map = nil
            userMarkers.removeValue(forKey: userId)
            print("🗑️ Removed marker for user: \(userId)")
        }
    }
    
    private func clearAllUserMarkers() {
        for (userId, marker) in userMarkers {
            marker.map = nil
        }
        userMarkers.removeAll()
        print("🧹 Cleared all user markers")
    }
    
    private func emitUserLocationUpdate(latitude: Double, longitude: Double) {
        guard SocketHelper.shared.checkConnection() else {
            print("❌ Socket not connected, cannot emit location")
            return
        }
        
        let locationData: [String: Any] = [
            "userId": String(Utility.getUserData()?.id ?? 0),
            "latitude": latitude,
            "longitude": longitude,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        SocketHelper.Events.updateUserLocation.emit(params: locationData) {
            print("📡 Location update emitted successfully")
        }
    }
    
    private func disconnectSocket() {
        SocketHelper.Events.updateUserLocation.off()
        SocketHelper.shared.disconnectSocket()
        clearAllUserMarkers()
        print("🔌 Socket disconnected")
    }

    // MARK: - Setup Methods
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func setupMapView() {
        // Use selected course location or default to Pebble Beach
        let initialLat = selectedCourse?.location.latitude ?? 36.5674
        let initialLng = selectedCourse?.location.longitude ?? -121.9487

        let camera = GMSCameraPosition(latitude: initialLat, longitude: initialLng, zoom: 17)
        let options = GMSMapViewOptions()
        options.camera = camera
        options.frame = mainMapView.bounds
        mapView = GMSMapView(options: options)
        mapView.mapType = .satellite
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.settings.zoomGestures = true
        mapView.settings.scrollGestures = true
        mapView.settings.rotateGestures = true
        mapView.settings.tiltGestures = true
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false

        mainMapView.addSubview(mapView)

        // Add constraints to fill mainMapView
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: mainMapView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: mainMapView.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: mainMapView.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: mainMapView.bottomAnchor)
        ])
    }

    private func setupHoleNavigationUI() {
        // Hole info label (center top)
        holeInfoLabel = UILabel()
        holeInfoLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        holeInfoLabel.textColor = .white
        holeInfoLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        holeInfoLabel.textAlignment = .center
        holeInfoLabel.layer.cornerRadius = 8
        holeInfoLabel.clipsToBounds = true
        holeInfoLabel.numberOfLines = 2
        holeInfoLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(holeInfoLabel)

       
        NSLayoutConstraint.activate([
            // Hole info label at top center
            holeInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            holeInfoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            holeInfoLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            holeInfoLabel.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    private func initializePointsFromCourse(_ course: GolfCourse) {
        // Get GPS coordinates for the selected hole from static data
        let holeCoords = PebbleBeachStaticData.getCoordinatesForHole(selectedHoleNumber)

        guard !holeCoords.isEmpty else {
            print("❌ No GPS coordinates found for hole \(selectedHoleNumber), using defaults")
            initializeDefaultPoints()
            return
        }

        // Extract tee box (POI 1) and green (POI 12) locations
        var teeLocation: (lat: Double, lng: Double)?
        var greenLocation: (lat: Double, lng: Double)?

        for coord in holeCoords {
            if let poi = coord["poi"] as? String,
               let lat = coord["latitude"] as? Double,
               let lng = coord["longitude"] as? Double {

                if poi == "1" && teeLocation == nil {
                    teeLocation = (lat, lng)
                } else if poi == "12" {
                    greenLocation = (lat, lng)
                }
            }
        }

        guard let tee = teeLocation, let green = greenLocation else {
            print("❌ Could not find tee or green location for hole \(selectedHoleNumber)")
            initializeDefaultPoints()
            return
        }

        // Player 1 position - Tee box (starting point)
        player1Point = CLLocationCoordinate2D(
            latitude: tee.lat,
            longitude: tee.lng
        )

        // Player 2 position - Green (ending point)
        player2Point = CLLocationCoordinate2D(
            latitude: green.lat,
            longitude: green.lng
        )

        // Set midpoint at the second point (Green/Player 2)
        midPoint = CLLocationCoordinate2D(
            latitude: player2Point.latitude,
            longitude: player2Point.longitude
        )

        // Get hole info
        let par = PebbleBeachStaticData.getParForHole(selectedHoleNumber)
        let yardages = [378, 509, 397, 333, 189, 498, 107, 416, 483, 444, 370, 202, 401, 559, 393, 400, 182, 541]
        let yardage = yardages[selectedHoleNumber - 1]

        print("🏌️ Initialized Hole \(selectedHoleNumber) (Par \(par), \(yardage) yards):")
        print("   Tee Box (Player 1): \(player1Point.latitude), \(player1Point.longitude)")
        print("   Green (Player 2): \(player2Point.latitude), \(player2Point.longitude)")
        print("   Midpoint: \(midPoint.latitude), \(midPoint.longitude)")
    }

    private func initializeDefaultPoints() {
        // Player 1 (Red) - Start position
        player1Point = CLLocationCoordinate2D(latitude: 21.191075361172107, longitude: 72.78558602318863)

        // Player 2 (Green) - End position
        player2Point = CLLocationCoordinate2D(latitude: 21.19415203405939, longitude: 72.78658751154329)

        // Set midpoint at the second point (Green/Player 2)
        midPoint = CLLocationCoordinate2D(
            latitude: player2Point.latitude,
            longitude: player2Point.longitude
        )

        print("Player 1: \(player1Point.latitude), \(player1Point.longitude)")
        print("Player 2: \(player2Point.latitude), \(player2Point.longitude)")
        print("Mid Point: \(midPoint.latitude), \(midPoint.longitude)")
    }

    private func setupMarkers() {
        // Player 1 marker (Red)
        player1Marker = GMSMarker(position: player1Point)
        player1Marker?.title = "Tee Box"
        player1Marker?.icon = GMSMarker.markerImage(with: .systemRed)
        player1Marker?.map = mapView

        // Player 2 marker (Green)
        player2Marker = GMSMarker(position: player2Point)
        player2Marker?.title = "Green"
        player2Marker?.icon = GMSMarker.markerImage(with: .systemGreen)
        player2Marker?.map = mapView

        // Middle marker (White) - draggable
        midMarker = GMSMarker(position: midPoint)
        midMarker?.title = "Mid Point"
        midMarker?.icon = createMiddleMarkerIcon()
        midMarker?.groundAnchor = CGPoint(x: 0.5, y: 0.5) // Center the icon
        midMarker?.isDraggable = true
        midMarker?.map = mapView
    }

    private func createMiddleMarkerIcon() -> UIImage? {
        let size = CGSize(width: 60, height: 60)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // Draw white circle with blue border (larger for easier tapping)
        let circleRect = CGRect(x: 10, y: 10, width: 40, height: 40)
        context.setFillColor(UIColor.clear.cgColor)
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        context.setLineWidth(4)
        context.addEllipse(in: circleRect)
        context.drawPath(using: .fillStroke)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    private func drawPolylines() {
        // Remove existing polylines
        polylinePlayer1ToMid?.map = nil
        polylinePlayer2ToMid?.map = nil

        // Create dashed line style: - - - - - -
        // Need both solid (dash) and transparent (gap) styles
        let solidStyle = GMSStrokeStyle.solidColor(.white)
        let transparentStyle = GMSStrokeStyle.solidColor(.clear)
        let styles = [solidStyle, transparentStyle]

        let dashLength: NSNumber = 3  // Length of each dash
        let gapLength: NSNumber = 1   // Length of each gap
        let lengths = [dashLength, gapLength]

        // Create path for Player 1 to Mid (Dashed white line)
        let pathPlayer1ToMid = GMSMutablePath()
        pathPlayer1ToMid.add(player1Point)
        pathPlayer1ToMid.add(midPoint)

        polylinePlayer1ToMid = GMSPolyline(path: pathPlayer1ToMid)
        polylinePlayer1ToMid?.strokeWidth = 3
        polylinePlayer1ToMid?.spans = GMSStyleSpans(pathPlayer1ToMid, styles, lengths, .rhumb)
        polylinePlayer1ToMid?.map = mapView

        // Create path for Player 2 to Mid (Dashed white line)
        let pathPlayer2ToMid = GMSMutablePath()
        pathPlayer2ToMid.add(player2Point)
        pathPlayer2ToMid.add(midPoint)

        polylinePlayer2ToMid = GMSPolyline(path: pathPlayer2ToMid)
        polylinePlayer2ToMid?.strokeWidth = 3
        polylinePlayer2ToMid?.spans = GMSStyleSpans(pathPlayer2ToMid, styles, lengths, .rhumb)
        polylinePlayer2ToMid?.map = mapView

        // Draw 10-meter radius circle around midpoint
        drawMidPointCircle()
    }

    private func drawMidPointCircle() {
        // Remove existing circle and center dot
        midPointCircle?.map = nil
        centerDotMarker?.map = nil

        // Create a 15-meter radius circle around the midpoint
        midPointCircle = GMSCircle(position: midPoint, radius: 15.0)  // 15 meters
        midPointCircle?.fillColor = UIColor.systemBlue.withAlphaComponent(0.15)  // Light blue fill
        midPointCircle?.strokeColor = UIColor.systemBlue  // Blue border
        midPointCircle?.strokeWidth = 1
        midPointCircle?.map = mapView

        // Add white dot at the center of the circle
        centerDotMarker = GMSMarker(position: midPoint)
        centerDotMarker?.icon = createCenterDotIcon()
        centerDotMarker?.groundAnchor = CGPoint(x: 0.5, y: 0.5)  // Center the icon
        centerDotMarker?.map = mapView
    }

    private func createCenterDotIcon() -> UIImage? {
        let size = CGSize(width: 16, height: 16)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // Draw white filled circle
        let circleRect = CGRect(x: 2, y: 2, width: 12, height: 12)
        context.setFillColor(UIColor.white.cgColor)
        context.addEllipse(in: circleRect)
        context.fillPath()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    private func updateDistanceLabels() {
        let player1Location = CLLocation(latitude: player1Point.latitude, longitude: player1Point.longitude)
        let player2Location = CLLocation(latitude: player2Point.latitude, longitude: player2Point.longitude)
        let midLocation = CLLocation(latitude: midPoint.latitude, longitude: midPoint.longitude)

        let distancePlayer1ToMid = player1Location.distance(from: midLocation)
        let distancePlayer2ToMid = player2Location.distance(from: midLocation)

        // Update the first two items in the golf features array
        if golfFeatures.count >= 2 {
            golfFeatures[0] = GolfCourseFeature(title: "Player 1", number: String(format: "%.0f m", distancePlayer1ToMid))
            golfFeatures[1] = GolfCourseFeature(title: "Player 2", number: String(format: "%.0f m", distancePlayer2ToMid))

            // Reload only the first two rows for efficiency
            infoTableView.reloadRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: .none)
        }
    }

    private func centerMapOnHole() {
        // Calculate bearing from Player 1 (tee) to Player 2 (green)
        let bearing = calculateBearing(from: player1Point, to: player2Point)

        // Calculate the distance between player1 and player2 in meters
        let player1Location = CLLocation(latitude: player1Point.latitude, longitude: player1Point.longitude)
        let player2Location = CLLocation(latitude: player2Point.latitude, longitude: player2Point.longitude)
        let distanceInMeters = player1Location.distance(from: player2Location)

        // Calculate zoom level based on distance
        // Using padding of 200 pixels from top/bottom
        let availableScreenHeight = view.bounds.height - 260 // 200px top

        // Calculate zoom level that fits the distance in available screen height
        // Formula: zoom = log2(screenHeight * 156543.03392 / (distance * cos(latitude)))
        let metersPerPixel = distanceInMeters / availableScreenHeight
        let latitude = (player1Point.latitude + player2Point.latitude) / 2
        let zoom = log2(156543.03392 * cos(latitude * .pi / 180) / metersPerPixel)

        // Center point between tee and green
        let centerLat = (player1Point.latitude + player2Point.latitude) / 2
        let centerLng = (player1Point.longitude + player2Point.longitude) / 2

        // Adjust center to compensate for leading offset (120 points)
        // Map visible width is reduced by 120, so shift center slightly left
        let mapVisibleWidth = view.bounds.width - 120
        let offsetRatio = 120 / (2 * mapVisibleWidth) // Offset as ratio

        // Convert pixel offset to meters at this zoom level
        let metersPerPixelAtZoom = 156543.03392 * cos(latitude * .pi / 180) / pow(2, zoom)
        let offsetMeters = Double(60) * metersPerPixelAtZoom // 60 = half of 120

        // Calculate perpendicular bearing (90 degrees to the left)
        let perpendicularBearing = (bearing - 90).truncatingRemainder(dividingBy: 360)
        let bearingRadians = perpendicularBearing * .pi / 180

        // Calculate offset in lat/lng
        let earthRadius: Double = 6371000
        let deltaLat = (offsetMeters / earthRadius) * (180 / .pi) * cos(bearingRadians)
        let deltaLng = (offsetMeters / (earthRadius * cos(latitude * .pi / 180))) * (180 / .pi) * sin(bearingRadians)

        // Apply offset to center
        let adjustedCenter = CLLocationCoordinate2D(
            latitude: centerLat + deltaLat,
            longitude: centerLng + deltaLng
        )

        // Apply camera with calculated zoom and rotation
        let camera = GMSCameraPosition(
            target: adjustedCenter,
            zoom: Float(zoom),
            bearing: bearing,
            viewingAngle: 0
        )

        mapView.animate(to: camera)

        // Set camera bounds to restrict visible area
        setupCameraBounds()
    }

    private func setupCameraBounds() {
        // Create bounds that include both points with some padding
        let bounds = GMSCoordinateBounds(coordinate: player1Point, coordinate: player2Point)

        // Calculate minimum zoom level to fit both points
        let player1Location = CLLocation(latitude: player1Point.latitude, longitude: player1Point.longitude)
        let player2Location = CLLocation(latitude: player2Point.latitude, longitude: player2Point.longitude)
        let distanceInMeters = player1Location.distance(from: player2Location)

        // Calculate minimum zoom based on screen height and distance
        let availableScreenHeight = view.bounds.height - 260
        let metersPerPixel = distanceInMeters / availableScreenHeight
        let latitude = (player1Point.latitude + player2Point.latitude) / 2
        let minZoom = log2(156543.03392 * cos(latitude * .pi / 180) / metersPerPixel) - 0.5 // Slightly less for padding

        // Set minimum zoom (can't zoom out beyond this) and maximum zoom (can zoom in more)
        mapView.setMinZoom(Float(minZoom), maxZoom: 21)

        // Restrict camera to bounds (user can't scroll outside this area)
        mapView.cameraTargetBounds = bounds
    }
    

    private func calculateBearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {
        let lat1 = start.latitude * .pi / 180
        let lat2 = end.latitude * .pi / 180
        let lon1 = start.longitude * .pi / 180
        let lon2 = end.longitude * .pi / 180

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)

        var bearing = atan2(y, x) * 180 / .pi
        bearing = (bearing + 360).truncatingRemainder(dividingBy: 360)

        return bearing
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onPrev(_ sender: UIButton) {
        guard selectedHoleNumber > 1 else {
            print("Already at first hole")
            return
        }

        selectedHoleNumber -= 1
        loadHoleData()
    }
    
    @IBAction func onNext(_ sender: UIButton) {
        emitUserLocationUpdate(latitude: 2.39, longitude: 56.78)
        
        guard selectedHoleNumber < 18 else {
            print("Already at last hole")
            return
        }

        selectedHoleNumber += 1
        loadHoleData()
    }
}

// MARK: - GMSMapViewDelegate
extension GoogleMapsViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // Handle map taps if needed
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        // Camera position changed
    }

    // Called when user starts dragging
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        if marker == midMarker {
            print("Started dragging mid marker")
        }
    }

    // Called while dragging
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        if marker == midMarker {
            // Update mid point position
            midPoint = marker.position

            // Redraw polylines and update distances in real-time
            drawPolylines()
            updateDistanceLabels()
        }
    }

    // Called when dragging ends
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        if marker == midMarker {
            // Final update
            midPoint = marker.position
            drawPolylines()
            updateDistanceLabels()
            print("Ended dragging mid marker")
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension GoogleMapsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // Check if enough time has passed since last location update
        let currentTime = Date()
        if let lastUpdate = lastLocationUpdateTime {
            let timeSinceLastUpdate = currentTime.timeIntervalSince(lastUpdate)
            if timeSinceLastUpdate < locationUpdateInterval {
                return // Don't emit too frequently
            }
        }
        
        // Update the last location update time
        lastLocationUpdateTime = currentTime
        
        // Emit location update via socket
        emitUserLocationUpdate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        // Optionally update start point to user's current location
        // Uncomment if you want real-time location tracking
        // startPoint = location.coordinate
        // startMarker?.position = startPoint
        // drawPolylines()
        // updateDistanceLabel()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true

        case .denied, .restricted:
            print("Location access denied")

        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        @unknown default:
            break
        }
    }

    private func loadHoleData() {
        guard let course = selectedCourse else { return }

        // Reset camera bounds first to allow movement
        mapView.cameraTargetBounds = nil

        // Reinitialize points for new hole
        initializePointsFromCourse(course)

        // Clear existing markers, polylines, circle, and center dot
        player1Marker?.map = nil
        player2Marker?.map = nil
        midMarker?.map = nil
        polylinePlayer1ToMid?.map = nil
        polylinePlayer2ToMid?.map = nil
        midPointCircle?.map = nil
        centerDotMarker?.map = nil

        // Recreate everything for new hole
        setupMarkers()
        drawPolylines()
        updateDistanceLabels()
        updateHoleInfo()
        centerMapOnHole()

        // Update navigation title
        self.title = "\(course.courseName) - Hole \(selectedHoleNumber)"

        print("📍 Navigated to Hole \(selectedHoleNumber)")
    }

    private func updateHoleInfo() {
        let par = PebbleBeachStaticData.getParForHole(selectedHoleNumber)
        let yardages = [378, 509, 397, 333, 189, 498, 107, 416, 483, 444, 370, 202, 401, 559, 393, 400, 182, 541]
        let yardage = yardages[selectedHoleNumber - 1]

        holeInfoLabel.text = "Hole \(selectedHoleNumber)\nPar \(par) - \(yardage) yards"

        // Enable/disable buttons based on hole number
//        previousHoleButton.isEnabled = selectedHoleNumber > 1
//        previousHoleButton.alpha = selectedHoleNumber > 1 ? 1.0 : 0.5
//
//        nextHoleButton.isEnabled = selectedHoleNumber < 18
//        nextHoleButton.alpha = selectedHoleNumber < 18 ? 1.0 : 0.5
    }
}
extension GoogleMapsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return golfFeatures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoTableViewCell", for: indexPath) as! InfoTableViewCell
        let feature = golfFeatures[indexPath.row]

        // Set custom colors for Player 1 (red) and Player 2 (green)
        if indexPath.row == 0 {
            cell.configure(title: feature.title, number: feature.number, textColor: .systemRed)
        } else if indexPath.row == 1 {
            cell.configure(title: feature.title, number: feature.number, textColor: .systemGreen)
        } else {
            cell.configure(title: feature.title, number: feature.number)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
