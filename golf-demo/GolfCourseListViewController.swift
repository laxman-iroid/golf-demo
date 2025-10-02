import UIKit

class GolfCourseListViewController: UIViewController {
    
    private var tableView: UITableView!
    private var searchBar: UISearchBar!
    private var loadingIndicator: UIActivityIndicatorView!
    
    private let apiService = GolfCourseAPIService()
    private var golfCourses: [GolfCourse] = []
    private var filteredCourses: [GolfCourse] = []
    private var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadInitialCourses()
    }
    
    private func setupUI() {
        title = "Golf Courses"
        view.backgroundColor = UIColor.systemBackground
        
        // Setup search bar
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search golf courses..."
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup table view
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GolfCourseTableViewCell.self, forCellReuseIdentifier: "GolfCourseCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 100
        
        // Setup loading indicator
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        
        // Add subviews
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Setup navigation bar - removed API search/refresh buttons for static data
    }
    
    private func loadInitialCourses() {
        // Load Pebble Beach static data
        loadingIndicator.startAnimating()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadingIndicator.stopAnimating()

            let staticCourse = self?.createPebbleBeachCourse() ?? []
            self?.golfCourses = staticCourse
            self?.filteredCourses = staticCourse

            print("✅ Loaded Pebble Beach Golf Links with 18 holes")

            self?.tableView.reloadData()
        }
    }

    private func createPebbleBeachCourse() -> [GolfCourse] {
        let courseData = PebbleBeachStaticData.courseData

        guard let latitude = Double(courseData["latitude"] as? String ?? ""),
              let longitude = Double(courseData["longitude"] as? String ?? "") else {
            return []
        }

        let location = CourseLocation(
            address: courseData["address"] as? String ?? "",
            city: courseData["city"] as? String ?? "",
            state: courseData["state"] as? String ?? "",
            country: courseData["country"] as? String ?? "",
            latitude: latitude,
            longitude: longitude
        )

        // Create holes based on par data
        let parsMen = courseData["parsMen"] as? [Int] ?? []
        var holes: [Hole] = []

        for (index, par) in parsMen.enumerated() {
            let yardage = getYardageForHole(hole: index + 1, par: par)
            let hole = Hole(par: par, yardage: yardage, handicap: index + 1)
            holes.append(hole)
        }

        let teeBox = TeeBox(
            teeName: "Championship",
            courseRating: 74.9,
            slopeRating: 144,
            bogeyRating: 98.2,
            totalYards: 6828,
            totalMeters: 6242,
            numberOfHoles: 18,
            parTotal: 72,
            holes: holes
        )

        let tees = TeeBoxes(male: [teeBox], female: nil)

        let course = GolfCourse(
            id: 1,
            clubName: courseData["clubName"] as? String ?? "",
            courseName: courseData["courseName"] as? String ?? "",
            location: location,
            tees: tees
        )

        return [course]
    }

    private func getYardageForHole(hole: Int, par: Int) -> Int {
        // Approximate yardages based on typical distances for Pebble Beach
        let yardages = [378, 509, 397, 333, 189, 498, 107, 416, 483, 444, 370, 202, 401, 559, 393, 400, 182, 541]
        return yardages[hole - 1]
    }
    
    private func createSampleCourses() -> [GolfCourse] {
        let courses = [
            createSampleCourse(
                id: 1,
                clubName: "Pebble Beach Golf Links",
                courseName: "Pebble Beach",
                city: "Pebble Beach",
                state: "CA",
                latitude: 36.5674,
                longitude: -121.9487,
                par: 4,
                yardage: 385
            ),
            createSampleCourse(
                id: 2,
                clubName: "Augusta National Golf Club",
                courseName: "Augusta National",
                city: "Augusta",
                state: "GA",
                latitude: 33.5030,
                longitude: -82.0198,
                par: 5,
                yardage: 575
            ),
            createSampleCourse(
                id: 3,
                clubName: "St. Andrews Links",
                courseName: "The Old Course",
                city: "St. Andrews",
                state: "Scotland",
                latitude: 56.3476,
                longitude: -2.8494,
                par: 4,
                yardage: 495
            ),
            createSampleCourse(
                id: 4,
                clubName: "Torrey Pines Golf Course",
                courseName: "South Course",
                city: "La Jolla",
                state: "CA",
                latitude: 32.8893,
                longitude: -117.2536,
                par: 3,
                yardage: 165
            ),
            createSampleCourse(
                id: 5,
                clubName: "Bethpage State Park",
                courseName: "Black Course",
                city: "Farmingdale",
                state: "NY",
                latitude: 40.7451,
                longitude: -73.4579,
                par: 4,
                yardage: 415
            )
        ]
        
        return courses
    }
    
    private func createSampleCourse(id: Int, clubName: String, courseName: String, city: String, state: String, latitude: Double, longitude: Double, par: Int, yardage: Int) -> GolfCourse {
        let sampleHole = Hole(par: par, yardage: yardage, handicap: 12)
        
        let sampleTeeBox = TeeBox(
            teeName: "Championship",
            courseRating: 72.5,
            slopeRating: 135,
            bogeyRating: 98.2,
            totalYards: 7200,
            totalMeters: 6584,
            numberOfHoles: 18,
            parTotal: 72,
            holes: [sampleHole]
        )
        
        let sampleTees = TeeBoxes(
            male: [sampleTeeBox],
            female: nil
        )
        
        let sampleLocation = CourseLocation(
            address: "123 Golf Course Drive, \(city), \(state)",
            city: city,
            state: state,
            country: "United States",
            latitude: latitude,
            longitude: longitude
        )
        
        return GolfCourse(
            id: id,
            clubName: clubName,
            courseName: courseName,
            location: sampleLocation,
            tees: sampleTees
        )
    }
    
}

// MARK: - UITableViewDataSource
extension GolfCourseListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GolfCourseCell", for: indexPath) as! GolfCourseTableViewCell
        let course = filteredCourses[indexPath.row]
        cell.configure(with: course)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension GolfCourseListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedCourse = filteredCourses[indexPath.row]

        // Navigate to Google Maps course detail view
        let googleMapsVC = GoogleMapsViewController()
        googleMapsVC.selectedCourse = selectedCourse
//        googleMapsVC.selectedHoleNumber = 18  // Default to Hole 18
        googleMapsVC.title = "\(selectedCourse.courseName) - Hole 18"

        navigationController?.pushViewController(googleMapsVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension GolfCourseListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredCourses = golfCourses
        } else {
            isSearching = true
            filteredCourses = golfCourses.filter { course in
                course.clubName.lowercased().contains(searchText.lowercased()) ||
                course.courseName.lowercased().contains(searchText.lowercased()) ||
                course.location.city.lowercased().contains(searchText.lowercased()) ||
                course.location.state.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
}
