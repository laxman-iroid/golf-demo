import UIKit
import GoogleMaps
import CoreLocation

class GoogleMapsViewController: UIViewController {

    // MARK: - Properties
    var selectedCourse: GolfCourse?
    var selectedHoleNumber: Int = 1  // Default to hole 18

    private var mapView: GMSMapView!
    private var locationManager = CLLocationManager()

    // Three points for the polyline
    private var player1Point: CLLocationCoordinate2D!  // Red player
    private var player2Point: CLLocationCoordinate2D!  // Green player
    private var midPoint: CLLocationCoordinate2D!      // White mid point

    // Map markers
    private var player1Marker: GMSMarker?
    private var player2Marker: GMSMarker?
    private var midMarker: GMSMarker?

    // Polyline segments
    private var polylinePlayer1ToMid: GMSPolyline?
    private var polylinePlayer2ToMid: GMSPolyline?

    // Distance labels
    private var player1DistanceLabel: UILabel!
    private var player2DistanceLabel: UILabel!

    // Hole navigation
    private var holeInfoLabel: UILabel!
    private var previousHoleButton: UIButton!
    private var nextHoleButton: UIButton!


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocationManager()
        setupMapView()
        setupDistanceLabels()
        setupHoleNavigationUI()

        // Use selected course if available, otherwise use default
        if let course = selectedCourse {
            initializePointsFromCourse(course)
        } else {
            initializeDefaultPoints()
        }

        setupMarkers()
        drawPolylines()
        updateDistanceLabels()
        updateHoleInfo()
        centerMapOnHole()
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
        options.frame = view.bounds
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

        view.addSubview(mapView)
    }

    private func setupDistanceLabels() {
        // Player 1 (Red) distance label
        player1DistanceLabel = UILabel()
        player1DistanceLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
        player1DistanceLabel.textColor = .white
        player1DistanceLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        player1DistanceLabel.textAlignment = .center
        player1DistanceLabel.layer.cornerRadius = 8
        player1DistanceLabel.clipsToBounds = true
        player1DistanceLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(player1DistanceLabel)

        NSLayoutConstraint.activate([
            player1DistanceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            player1DistanceLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            player1DistanceLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            player1DistanceLabel.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Player 2 (Green) distance label
        player2DistanceLabel = UILabel()
        player2DistanceLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
        player2DistanceLabel.textColor = .white
        player2DistanceLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        player2DistanceLabel.textAlignment = .center
        player2DistanceLabel.layer.cornerRadius = 8
        player2DistanceLabel.clipsToBounds = true
        player2DistanceLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(player2DistanceLabel)

        NSLayoutConstraint.activate([
            player2DistanceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            player2DistanceLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            player2DistanceLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            player2DistanceLabel.heightAnchor.constraint(equalToConstant: 50)
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

        // Previous button
        previousHoleButton = UIButton(type: .system)
        previousHoleButton.setTitle("◀ Prev", for: .normal)
        previousHoleButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        previousHoleButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
        previousHoleButton.setTitleColor(.white, for: .normal)
        previousHoleButton.layer.cornerRadius = 8
        previousHoleButton.translatesAutoresizingMaskIntoConstraints = false
        previousHoleButton.addTarget(self, action: #selector(previousHoleTapped), for: .touchUpInside)

        view.addSubview(previousHoleButton)

        // Next button
        nextHoleButton = UIButton(type: .system)
        nextHoleButton.setTitle("Next ▶", for: .normal)
        nextHoleButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nextHoleButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
        nextHoleButton.setTitleColor(.white, for: .normal)
        nextHoleButton.layer.cornerRadius = 8
        nextHoleButton.translatesAutoresizingMaskIntoConstraints = false
        nextHoleButton.addTarget(self, action: #selector(nextHoleTapped), for: .touchUpInside)

        view.addSubview(nextHoleButton)

        NSLayoutConstraint.activate([
            // Hole info label at top center
            holeInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            holeInfoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            holeInfoLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            holeInfoLabel.heightAnchor.constraint(equalToConstant: 60),

            // Previous button at bottom left
            previousHoleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            previousHoleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            previousHoleButton.widthAnchor.constraint(equalToConstant: 100),
            previousHoleButton.heightAnchor.constraint(equalToConstant: 50),

            // Next button at bottom right
            nextHoleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextHoleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextHoleButton.widthAnchor.constraint(equalToConstant: 100),
            nextHoleButton.heightAnchor.constraint(equalToConstant: 50)
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

        // Calculate middle point dynamically between tee and green
        midPoint = CLLocationCoordinate2D(
            latitude: (player1Point.latitude + player2Point.latitude) / 2,
            longitude: (player1Point.longitude + player2Point.longitude) / 2
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
        player1Point = CLLocationCoordinate2D(latitude: 36.57020081124087, longitude: -121.948783993721)

        // Player 2 (Green) - End position
        player2Point = CLLocationCoordinate2D(latitude: 36.57068307134521, longitude: -121.94711364805698)

        // Calculate middle point exactly at center between two players
        let midLat = (player1Point.latitude + player2Point.latitude) / 2.0
        let midLng = (player1Point.longitude + player2Point.longitude) / 2.0

        midPoint = CLLocationCoordinate2D(latitude: midLat, longitude: midLng)

        print("Player 1: \(player1Point.latitude), \(player1Point.longitude)")
        print("Player 2: \(player2Point.latitude), \(player2Point.longitude)")
        print("Mid Point: \(midLat), \(midLng)")
    }

    private func setupMarkers() {
        // Player 1 marker (Red)
        player1Marker = GMSMarker(position: player1Point)
        player1Marker?.title = "Player 1"
        player1Marker?.icon = GMSMarker.markerImage(with: .systemRed)
        player1Marker?.map = mapView

        // Player 2 marker (Green)
        player2Marker = GMSMarker(position: player2Point)
        player2Marker?.title = "Player 2"
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

        // Create path for Player 1 to Mid (Red line)
        let pathPlayer1ToMid = GMSMutablePath()
        pathPlayer1ToMid.add(player1Point)
        pathPlayer1ToMid.add(midPoint)

        polylinePlayer1ToMid = GMSPolyline(path: pathPlayer1ToMid)
        polylinePlayer1ToMid?.strokeColor = UIColor.systemRed
        polylinePlayer1ToMid?.strokeWidth = 5
        polylinePlayer1ToMid?.map = mapView

        // Create path for Player 2 to Mid (Green line)
        let pathPlayer2ToMid = GMSMutablePath()
        pathPlayer2ToMid.add(player2Point)
        pathPlayer2ToMid.add(midPoint)

        polylinePlayer2ToMid = GMSPolyline(path: pathPlayer2ToMid)
        polylinePlayer2ToMid?.strokeColor = UIColor.systemGreen
        polylinePlayer2ToMid?.strokeWidth = 5
        polylinePlayer2ToMid?.map = mapView
    }

    private func updateDistanceLabels() {
        let player1Location = CLLocation(latitude: player1Point.latitude, longitude: player1Point.longitude)
        let player2Location = CLLocation(latitude: player2Point.latitude, longitude: player2Point.longitude)
        let midLocation = CLLocation(latitude: midPoint.latitude, longitude: midPoint.longitude)

        let distancePlayer1ToMid = player1Location.distance(from: midLocation)
        let distancePlayer2ToMid = player2Location.distance(from: midLocation)

        // Display Player 1 distance (Red)
        player1DistanceLabel.text = String(format: "Player 1\n%.0f m", distancePlayer1ToMid)
        player1DistanceLabel.numberOfLines = 2

        // Display Player 2 distance (Green)
        player2DistanceLabel.text = String(format: "Player 2\n%.0f m", distancePlayer2ToMid)
        player2DistanceLabel.numberOfLines = 2
    }

    private func centerMapOnHole() {
        // Create bounds that include all three points
        let bounds = GMSCoordinateBounds(coordinate: player1Point, coordinate: player2Point)
            .includingCoordinate(midPoint)

        let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
        mapView.animate(with: update)
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

    // MARK: - Hole Navigation

    @objc private func previousHoleTapped() {
        guard selectedHoleNumber > 1 else {
            print("Already at first hole")
            return
        }

        selectedHoleNumber -= 1
        loadHoleData()
    }

    @objc private func nextHoleTapped() {
        guard selectedHoleNumber < 18 else {
            print("Already at last hole")
            return
        }

        selectedHoleNumber += 1
        loadHoleData()
    }

    private func loadHoleData() {
        guard let course = selectedCourse else { return }

        // Reinitialize points for new hole
        initializePointsFromCourse(course)

        // Clear existing markers and polylines
        player1Marker?.map = nil
        player2Marker?.map = nil
        midMarker?.map = nil
        polylinePlayer1ToMid?.map = nil
        polylinePlayer2ToMid?.map = nil

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
        previousHoleButton.isEnabled = selectedHoleNumber > 1
        previousHoleButton.alpha = selectedHoleNumber > 1 ? 1.0 : 0.5

        nextHoleButton.isEnabled = selectedHoleNumber < 18
        nextHoleButton.alpha = selectedHoleNumber < 18 ? 1.0 : 0.5
    }
}
