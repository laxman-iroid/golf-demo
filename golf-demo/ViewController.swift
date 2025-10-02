//
//  ViewController.swift
//  golf-demo
//
//  Created by Laxmansinh Rajpurohit on 24/09/25.
//

import UIKit

class ViewController: UIViewController {

    private var mapView: FairwayMapView!
    private var toolbarStackView: UIStackView!
    private var holeSelectionView: UIView!
    private var holeSegmentedControl: UISegmentedControl!
    private let apiService = GolfCourseAPIService()
    private var loadingOverlay: UIView?
    private var loadingIndicator: UIActivityIndicatorView?
    private var currentHoleNumber: Int = 18  // Start with Hole 18

    var selectedCourse: GolfCourse?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
        setupHoleSelectionView()
        setupToolbar()

        // Load selected course if available, otherwise load sample data
        if let course = selectedCourse {
            loadHoleForCourse(course, holeNumber: currentHoleNumber)
        } else {
            loadSampleData()
        }
    }
    
    private func loadHoleForCourse(_ course: GolfCourse, holeNumber: Int) {
        print("🗺️ Loading hole \(holeNumber) for: \(course.courseName)")

        // Get coordinates for the selected hole from static data
        let holeCoords = PebbleBeachStaticData.getCoordinatesForHole(holeNumber)

        if holeCoords.isEmpty {
            print("❌ No coordinates found for hole \(holeNumber)")
            return
        }

        // Extract tee box (poi 1) and green (poi 12) locations
        var teeLocation: LatLng?
        var greenLocation: LatLng?

        for coord in holeCoords {
            if let poi = coord["poi"] as? String,
               let lat = coord["latitude"] as? Double,
               let lng = coord["longitude"] as? Double {

                if poi == "1" && teeLocation == nil {
                    teeLocation = LatLng(lat, lng)
                } else if poi == "12" {
                    greenLocation = LatLng(lat, lng)
                }
            }
        }

        guard let tee = teeLocation, let green = greenLocation else {
            print("❌ Could not find tee or green location")
            return
        }

        // Get par for this hole
        let par = PebbleBeachStaticData.getParForHole(holeNumber)

        // Create a course with the specific hole
        let hole = Hole(par: par, yardage: 400, handicap: holeNumber)
        let teeBox = TeeBox(
            teeName: "Championship",
            courseRating: 74.9,
            slopeRating: 144,
            bogeyRating: 98.2,
            totalYards: 6828,
            totalMeters: 6242,
            numberOfHoles: 18,
            parTotal: 72,
            holes: [hole]
        )
        let tees = TeeBoxes(male: [teeBox], female: nil)

        let tempCourse = GolfCourse(
            id: 1,
            clubName: course.clubName,
            courseName: "\(course.courseName) - Hole \(holeNumber)",
            location: CourseLocation(
                address: course.location.address,
                city: course.location.city,
                state: course.location.state,
                country: course.location.country,
                latitude: tee.latitude,
                longitude: tee.longitude
            ),
            tees: tees
        )

        // Render the hole using CourseRenderer with GPS coordinates
        let (courseImage, calibration, _, targets) = apiService.generateCourseHoleSync(from: tempCourse, holeNumber: 1, gpsCoordinates: holeCoords)

        // Load into map view
        mapView.setData(
            fairwayBitmap: courseImage,
            calibration: calibration,
            green: green,
            orientationDegrees: 0,
            targets: targets
        )

        // Set player at tee box
        mapView.setPlayerLocation(tee)

        // Set pin at green
        mapView.setPinLocation(green)

        // Zoom to fit the hole
        zoomToFitHole(tee: tee, green: green)

        print("✅ Loaded hole \(holeNumber) - Par \(par)")
    }

    private func zoomToFitHole(tee: LatLng, green: LatLng) {
        // Calculate the bounding box for the hole
        let minLat = min(tee.latitude, green.latitude)
        let maxLat = max(tee.latitude, green.latitude)
        let minLng = min(tee.longitude, green.longitude)
        let maxLng = max(tee.longitude, green.longitude)

        // Calculate center
        let centerLat = (minLat + maxLat) / 2
        let centerLng = (minLng + maxLng) / 2
        let center = LatLng(centerLat, centerLng)

        // Center on the hole with slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mapView.centerOn(center, animate: true)
        }
    }
    
    private func setupMapView() {
        mapView = FairwayMapView(frame: view.bounds)
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupHoleSelectionView() {
        // Create container view
        holeSelectionView = UIView()
        holeSelectionView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        holeSelectionView.layer.cornerRadius = 12
        holeSelectionView.layer.shadowColor = UIColor.black.cgColor
        holeSelectionView.layer.shadowOpacity = 0.2
        holeSelectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        holeSelectionView.layer.shadowRadius = 4
        holeSelectionView.translatesAutoresizingMaskIntoConstraints = false

        // Create segmented control for hole selection
        var holeNumbers: [String] = []
        for i in 1...18 {
            holeNumbers.append("\(i)")
        }

        holeSegmentedControl = UISegmentedControl(items: holeNumbers)
        holeSegmentedControl.selectedSegmentIndex = 17  // Select Hole 18 (index 17)
        holeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        holeSegmentedControl.addTarget(self, action: #selector(holeSelectionChanged), for: .valueChanged)

        holeSelectionView.addSubview(holeSegmentedControl)
        view.addSubview(holeSelectionView)

        NSLayoutConstraint.activate([
            holeSelectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            holeSelectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            holeSelectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            holeSelectionView.heightAnchor.constraint(equalToConstant: 60),

            holeSegmentedControl.centerXAnchor.constraint(equalTo: holeSelectionView.centerXAnchor),
            holeSegmentedControl.centerYAnchor.constraint(equalTo: holeSelectionView.centerYAnchor),
            holeSegmentedControl.leadingAnchor.constraint(equalTo: holeSelectionView.leadingAnchor, constant: 12),
            holeSegmentedControl.trailingAnchor.constraint(equalTo: holeSelectionView.trailingAnchor, constant: -12)
        ])
    }

    @objc private func holeSelectionChanged() {
        currentHoleNumber = holeSegmentedControl.selectedSegmentIndex + 1
        print("🏌️ Selected hole: \(currentHoleNumber)")

        if let course = selectedCourse {
            loadHoleForCourse(course, holeNumber: currentHoleNumber)
        }
    }
    
    private func setupToolbar() {
        let centerOnPlayerButton = createToolbarButton(title: "Player") { [weak self] in
            self?.centerOnPlayer()
        }
        
        let centerOnGreenButton = createToolbarButton(title: "Green") { [weak self] in
            self?.centerOnGreen()
        }
        
        let toggleOverlaysButton = createToolbarButton(title: "Overlays") { [weak self] in
            self?.toggleOverlays()
        }
        
        let togglePinButton = createToolbarButton(title: "Pin Mode") { [weak self] in
            self?.togglePinMode()
        }
        
        let testAPIButton = createToolbarButton(title: "Test API") { [weak self] in
            self?.testRealAPI()
        }
        
        let renderCourseButton = createToolbarButton(title: "Sample Course") { [weak self] in
            self?.loadSampleRenderedCourse()
        }
        
        toolbarStackView = UIStackView(arrangedSubviews: [
            centerOnPlayerButton,
            centerOnGreenButton,
            toggleOverlaysButton,
            togglePinButton,
            testAPIButton,
            renderCourseButton
        ])
        
        toolbarStackView.axis = .horizontal
        toolbarStackView.distribution = .fillEqually
        toolbarStackView.spacing = 8
        toolbarStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toolbarStackView)
        
        NSLayoutConstraint.activate([
            toolbarStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            toolbarStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            toolbarStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            toolbarStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func createToolbarButton(title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        
        return button
    }
    
    private func loadSampleData() {
        let (sampleImage, calibration, greenLocation, targets) = apiService.generateSampleGolfHole()
        
        mapView.setData(
            fairwayBitmap: sampleImage,
            calibration: calibration,
            green: greenLocation,
            orientationDegrees: 0,
            targets: targets
        )
        
        let playerLocation = LatLng(40.7827, -73.9651)
        let pinLocation = LatLng(40.7822, -73.9648)
        
        mapView.setPlayerLocation(playerLocation)
        mapView.setPinLocation(pinLocation)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mapView.centerOn(playerLocation)
        }
    }
    
    @objc private func centerOnPlayer() {
        let playerLocation = LatLng(40.7827, -73.9651)
        mapView.centerOn(playerLocation, animate: true)
    }
    
    @objc private func centerOnGreen() {
        mapView.setZoomToGreenCenter(zoomFactor: 1.5)
    }
    
    @objc private func toggleOverlays() {
        mapView.setOverlaysEnabled(!mapView.areOverlaysEnabled)
    }
    
    @objc private func togglePinMode() {
        mapView.setPinChangeEnabled(!mapView.isPinChangeEnabled)
        
        let button = toolbarStackView.arrangedSubviews[3] as! UIButton
        let isEnabled = mapView.isPinChangeEnabled
        button.backgroundColor = isEnabled ? UIColor.systemOrange.withAlphaComponent(0.8) : UIColor.systemBlue.withAlphaComponent(0.8)
        button.setTitle(isEnabled ? "Pin ON" : "Pin Mode", for: .normal)
    }
    
    @objc private func testRealAPI() {
        print("🔍 Testing Real Golf Course API...")
        
        apiService.searchCourses(query: "pebble beach") { result in
            switch result {
            case .success(let courses):
                print("✅ API Success: Found \(courses.count) courses")
                
                if !courses.isEmpty {
                    let firstCourse = courses[0]
                    let message = """
                    Found \(courses.count) courses!
                    
                    First course:
                    \(firstCourse.clubName)
                    \(firstCourse.courseName)
                    \(firstCourse.location.city), \(firstCourse.location.state)
                    
                    Would you like to load this course on the map?
                    """
                    
                    let alert = UIAlertController(
                        title: "API Success! 🎉",
                        message: message,
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "Load Course", style: .default) { _ in
                        self.loadRealCourseData(firstCourse)
                    })
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(
                        title: "API Success",
                        message: "API call successful but no courses found for 'pebble beach'",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
                
            case .failure(let error):
                print("❌ API Failed: \(error)")
                
                let alert = UIAlertController(
                    title: "API Test Failed",
                    message: "Error: \(error.localizedDescription)\n\nCheck console for detailed logs.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc private func loadSampleRenderedCourse() {
        print("🏌️ Loading sample rendered course...")
        
        // Create sample golf course data to test renderer
        let sampleCourse = createSampleCourse()
        
        // Use the course renderer to draw the golf hole
        let (courseImage, calibration, greenLocation, targets) = apiService.generateCourseHoleSync(from: sampleCourse, holeNumber: 1)
        
        // Load the rendered course into the map view
        mapView.setData(
            fairwayBitmap: courseImage,
            calibration: calibration,
            green: greenLocation,
            orientationDegrees: 0,
            targets: targets
        )
        
        // Set player at tee box
        let teeLocation = LatLng(
            sampleCourse.location.latitude + 0.003,
            sampleCourse.location.longitude
        )
        mapView.setPlayerLocation(teeLocation)
        
        // Set pin at green
        mapView.setPinLocation(greenLocation)
        
        // Center on tee box
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mapView.centerOn(teeLocation)
        }
        
        print("✅ Successfully loaded sample rendered course!")
        
        // Show info alert
        let alert = UIAlertController(
            title: "Sample Course Loaded! ⛳",
            message: "Displaying a rendered Par 4 hole with realistic golf course features including fairway, rough, bunkers, and distance markers.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Great!", style: .default))
        present(alert, animated: true)
    }
    
    private func createSampleCourse() -> GolfCourse {
        // Create a sample hole with realistic data
        let sampleHole = Hole(par: 4, yardage: 385, handicap: 12)
        
        let sampleTeeBox = TeeBox(
            teeName: "Blue",
            courseRating: 72.5,
            slopeRating: 135,
            bogeyRating: 98.2,
            totalYards: 6850,
            totalMeters: 6264,
            numberOfHoles: 18,
            parTotal: 72,
            holes: [sampleHole]
        )
        
        let sampleTees = TeeBoxes(
            male: [sampleTeeBox],
            female: nil
        )
        
        let sampleLocation = CourseLocation(
            address: "1234 Golf Course Drive, Pebble Beach, CA 93953, USA",
            city: "Pebble Beach",
            state: "CA",
            country: "United States",
            latitude: 36.5674,
            longitude: -121.9487
        )
        
        return GolfCourse(
            id: 999,
            clubName: "Sample Golf Club",
            courseName: "Sample Championship Course",
            location: sampleLocation,
            tees: sampleTees
        )
    }
    
    private func loadRealCourseData(_ course: GolfCourse) {
        print("📍 Loading real course data for: \(course.courseName)")
        
        // Use the new course renderer to draw the actual golf course
        let (courseImage, calibration, greenLocation, targets) = apiService.generateCourseHoleSync(from: course, holeNumber: 1)
        
        mapView.setData(
            fairwayBitmap: courseImage,
            calibration: calibration,
            green: greenLocation,
            orientationDegrees: 0,
            targets: targets
        )
        
        // Set player at tee box
        let teeLocation = LatLng(
            course.location.latitude + 0.003,
            course.location.longitude
        )
        mapView.setPlayerLocation(teeLocation)
        
        // Set pin at green
        mapView.setPinLocation(greenLocation)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mapView.centerOn(teeLocation)
        }
        
        print("✅ Successfully loaded rendered course: \(course.courseName)!")
    }
    
    private func showLoadingOverlay() {
        // Create overlay view
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        
        // Create loading indicator
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        
        // Create loading label
        let label = UILabel()
        label.text = "Loading Course..."
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to overlay
        overlay.addSubview(indicator)
        overlay.addSubview(label)
        
        // Add to view
        view.addSubview(overlay)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            indicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            
            label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            label.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: 16)
        ])
        
        // Store references
        loadingOverlay = overlay
        loadingIndicator = indicator
    }
    
    private func hideLoadingOverlay() {
        loadingIndicator?.stopAnimating()
        loadingOverlay?.removeFromSuperview()
        loadingOverlay = nil
        loadingIndicator = nil
    }
}

extension ViewController: FairwayMapViewDelegate {
    func fairwayMapView(_ mapView: FairwayMapView, didSelectTarget target: Target) {
        print("Selected target: \(target.name) - \(target.yardage) yards")
        
        let alert = UIAlertController(
            title: "Target Selected",
            message: "\(target.name)\n\(target.yardage) yards",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func fairwayMapView(_ mapView: FairwayMapView, didMovePinTo location: LatLng) {
        print("Pin moved to: \(location.latitude), \(location.longitude)")
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        
        let message = "Lat: \(formatter.string(from: NSNumber(value: location.latitude)) ?? "")\nLng: \(formatter.string(from: NSNumber(value: location.longitude)) ?? "")"
        
        let alert = UIAlertController(
            title: "Pin Moved",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

