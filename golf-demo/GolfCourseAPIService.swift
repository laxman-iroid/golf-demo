import Foundation
import UIKit

struct GolfCourse: Codable, Hashable {
    let id: Int
    let clubName: String
    let courseName: String
    let location: CourseLocation
    let tees: TeeBoxes?
    
    enum CodingKeys: String, CodingKey {
        case id
        case clubName = "club_name"
        case courseName = "course_name"
        case location, tees
    }
    
    // Implement Hashable using ID as unique identifier
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: GolfCourse, rhs: GolfCourse) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CourseLocation: Codable, Hashable {
    let address: String
    let city: String
    let state: String
    let country: String
    let latitude: Double
    let longitude: Double
}

struct TeeBoxes: Codable, Hashable {
    let male: [TeeBox]?
    let female: [TeeBox]?
}

struct TeeBox: Codable, Hashable {
    let teeName: String
    let courseRating: Double
    let slopeRating: Int
    let bogeyRating: Double
    let totalYards: Int
    let totalMeters: Int
    let numberOfHoles: Int
    let parTotal: Int
    let holes: [Hole]?
    
    enum CodingKeys: String, CodingKey {
        case teeName = "tee_name"
        case courseRating = "course_rating"
        case slopeRating = "slope_rating"
        case bogeyRating = "bogey_rating"
        case totalYards = "total_yards"
        case totalMeters = "total_meters"
        case numberOfHoles = "number_of_holes"
        case parTotal = "par_total"
        case holes
    }
}

struct Hole: Codable, Hashable {
    let par: Int
    let yardage: Int
    let handicap: Int
}

class GolfCourseAPIService {
    private let apiKey = "WYQ4EBPXAB25BH3X2B5ZJ5Z3U4"
    private let baseURL = "https://api.golfcourseapi.com"
    
    private let session = URLSession.shared
    
    func searchCourses(query: String, completion: @escaping (Result<[GolfCourse], Error>) -> Void) {
        var components = URLComponents(string: "\(baseURL)/v1/search")!
        components.queryItems = [
            URLQueryItem(name: "search_query", value: query)
        ]
        
        guard let url = components.url else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        print("🌐 Calling Golf Course API: \(url)")
        print("🔑 Authorization Header: Key \(apiKey)")
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 API Response Status: \(httpResponse.statusCode)")
                }
                
                if let error = error {
                    print("❌ API Error: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    completion(.failure(APIError.noData))
                    return
                }
                
                // Print raw response for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Raw API Response: \(responseString)")
                }
                
                do {
                    let response = try JSONDecoder().decode(CourseSearchResponse.self, from: data)
                    print("✅ Successfully decoded \(response.courses.count) courses")
                    completion(.success(response.courses))
                } catch {
                    print("❌ Decoding Error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func getCourseDetails(courseId: Int, completion: @escaping (Result<GolfCourse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/v1/courses/\(courseId)") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        print("🌐 Calling Golf Course Details API: \(url)")
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 API Response Status: \(httpResponse.statusCode)")
                }
                
                if let error = error {
                    print("❌ API Error: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    completion(.failure(APIError.noData))
                    return
                }
                
                // Print raw response for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Raw API Response: \(responseString)")
                }
                
                do {
                    let course = try JSONDecoder().decode(GolfCourse.self, from: data)
                    print("✅ Successfully decoded course: \(course.courseName)")
                    completion(.success(course))
                } catch {
                    print("❌ Decoding Error: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }
                completion(UIImage(data: data))
            }
        }.resume()
    }
    
    func downloadGolfCourseGroundImage(for course: GolfCourse, completion: @escaping (UIImage?) -> Void) {
        // Create satellite/terrain imagery URL for the golf course
        let latitude = course.location.latitude
        let longitude = course.location.longitude
        
        // Use multiple mapping services for real golf course imagery
        downloadSatelliteImage(latitude: latitude, longitude: longitude) { [weak self] satelliteImage in
            if let image = satelliteImage {
                completion(image)
            } else {
                // Fallback to OpenStreetMap if satellite fails
                self?.downloadOpenStreetMapImage(latitude: latitude, longitude: longitude) { osmImage in
                    if let image = osmImage {
                        completion(image)
                    } else {
                        // Final fallback to rendered course
                        let renderedImage = CourseRenderer.renderCourse(course, holeNumber: 1)
                        completion(renderedImage)
                    }
                }
            }
        }
    }
    
    private func downloadSatelliteImage(latitude: Double, longitude: Double, completion: @escaping (UIImage?) -> Void) {
        // Use Google Static Maps API for satellite imagery
        let zoom = 16 // Good zoom level for golf courses
        let size = "800x1200" // Match our course image dimensions
        let mapType = "satellite"
        
        // Create the satellite imagery URL
        let urlString = "https://maps.googleapis.com/maps/api/staticmap?center=\(latitude),\(longitude)&zoom=\(zoom)&size=\(size)&maptype=\(mapType)&key=YOUR_GOOGLE_MAPS_API_KEY"
        
        // Note: For demo purposes, we'll skip Google Maps API key requirement
        // In production, you would need a Google Maps API key
        print("🗺️ Would fetch satellite image from: \(urlString)")
        completion(nil) // Skip for now due to API key requirement
    }
    
    private func downloadOpenStreetMapImage(latitude: Double, longitude: Double, completion: @escaping (UIImage?) -> Void) {
        // Use OpenStreetMap tile service (free, no API key required)
        let zoom = 16
        
        // Convert lat/lng to tile coordinates
        let (tileX, tileY) = latLngToTile(latitude: latitude, longitude: longitude, zoom: zoom)
        
        // Download multiple tiles to create a larger image
        downloadTilesAndCombine(centerTileX: tileX, centerTileY: tileY, zoom: zoom, completion: completion)
    }
    
    private func latLngToTile(latitude: Double, longitude: Double, zoom: Int) -> (Int, Int) {
        let latRad = latitude * Double.pi / 180.0
        let n = pow(2.0, Double(zoom))
        let x = Int((longitude + 180.0) / 360.0 * n)
        let y = Int((1.0 - asinh(tan(latRad)) / Double.pi) / 2.0 * n)
        return (x, y)
    }
    
    private func downloadTilesAndCombine(centerTileX: Int, centerTileY: Int, zoom: Int, completion: @escaping (UIImage?) -> Void) {
        let tileSize = 256
        let tilesWide = 4 // 4x6 tiles = 1024x1536 pixels
        let tilesHigh = 6
        
        let totalWidth = tilesWide * tileSize
        let totalHeight = tilesHigh * tileSize
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: totalWidth, height: totalHeight), false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            completion(nil)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        var downloadedTiles: [(UIImage, Int, Int)] = []
        
        // Download tiles in a grid around the center
        let startX = centerTileX - tilesWide / 2
        let startY = centerTileY - tilesHigh / 2
        
        for x in 0..<tilesWide {
            for y in 0..<tilesHigh {
                let tileX = startX + x
                let tileY = startY + y
                
                dispatchGroup.enter()
                
                // OpenStreetMap tile URL
                let tileURL = "https://tile.openstreetmap.org/\(zoom)/\(tileX)/\(tileY).png"
                
                downloadImage(from: tileURL) { tileImage in
                    defer { dispatchGroup.leave() }
                    
                    if let image = tileImage {
                        downloadedTiles.append((image, x, y))
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            // Draw all downloaded tiles
            for (tileImage, x, y) in downloadedTiles {
                let drawX = x * tileSize
                let drawY = y * tileSize
                let drawRect = CGRect(x: drawX, y: drawY, width: tileSize, height: tileSize)
                tileImage.draw(in: drawRect)
            }
            
            let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if downloadedTiles.isEmpty {
                print("❌ Failed to download any map tiles")
                completion(nil)
            } else {
                print("✅ Successfully combined \(downloadedTiles.count) map tiles into ground image")
                completion(combinedImage)
            }
        }
    }
    
    func generateSampleGolfHole() -> (UIImage, GeoCalibration, LatLng, [Target]) {
        let sampleImage = createSampleFairwayImage()
        
        let topLeft = LatLng(40.7829, -73.9654)
        let topRight = LatLng(40.7829, -73.9644)
        let bottomLeft = LatLng(40.7819, -73.9654)
        
        let calibration = GeoCalibration.fromCorners(
            latLngTopLeft: topLeft,
            latLngTopRight: topRight,
            latLngBottomLeft: bottomLeft,
            imageWidth: sampleImage.size.width,
            imageHeight: sampleImage.size.height
        )
        
        let greenLocation = LatLng(40.7822, -73.9648)
        
        let targets = [
            Target(latLng: LatLng(40.7827, -73.9651), name: "Tee", yardage: 0),
            Target(latLng: LatLng(40.7825, -73.9650), name: "150", yardage: 150),
            Target(latLng: LatLng(40.7823, -73.9649), name: "100", yardage: 100),
            Target(latLng: greenLocation, name: "Pin", yardage: 0)
        ]
        
        return (sampleImage, calibration, greenLocation, targets)
    }
    
    func generateCourseHole(from course: GolfCourse, holeNumber: Int = 1, completion: @escaping (UIImage, GeoCalibration, LatLng, [Target]) -> Void) {
        // Try to download real ground image first
        downloadGolfCourseGroundImage(for: course) { courseImage in
            let actualImage = courseImage ?? CourseRenderer.renderCourse(course, holeNumber: holeNumber)
            
            // Create calibration based on course location
            let centerLat = course.location.latitude
            let centerLng = course.location.longitude
            
            // Estimate course bounds (approximately 1km x 1.5km for a typical hole)
            let latDelta = 0.004 // ~400m
            let lngDelta = 0.005 // ~500m
            
            let topLeft = LatLng(centerLat + latDelta, centerLng - lngDelta)
            let topRight = LatLng(centerLat + latDelta, centerLng + lngDelta)
            let bottomLeft = LatLng(centerLat - latDelta, centerLng - lngDelta)
            
            let calibration = GeoCalibration.fromCorners(
                latLngTopLeft: topLeft,
                latLngTopRight: topRight,
                latLngBottomLeft: bottomLeft,
                imageWidth: actualImage.size.width,
                imageHeight: actualImage.size.height
            )
            
            let greenLocation = LatLng(centerLat - latDelta * 0.6, centerLng)
            
            // Generate targets based on course data
            var targets: [Target] = []
            
            // Add tee box as target
            let teeLocation = LatLng(centerLat + latDelta * 0.6, centerLng)
            targets.append(Target(latLng: teeLocation, name: "Tee", yardage: 0))
            
            // Add distance markers based on hole data
            if let tees = course.tees, let maleTees = tees.male, !maleTees.isEmpty {
                let teeBox = maleTees[0]
                
                if let holes = teeBox.holes, holes.count >= holeNumber {
                    let hole = holes[holeNumber - 1]
                    let yardage = hole.yardage
                    
                    // Add markers based on yardage
                    if yardage > 200 {
                        let marker200 = LatLng(centerLat + latDelta * 0.2, centerLng + lngDelta * 0.1)
                        targets.append(Target(latLng: marker200, name: "200", yardage: 200))
                    }
                    
                    if yardage > 150 {
                        let marker150 = LatLng(centerLat, centerLng + lngDelta * 0.15)
                        targets.append(Target(latLng: marker150, name: "150", yardage: 150))
                    }
                    
                    if yardage > 100 {
                        let marker100 = LatLng(centerLat - latDelta * 0.2, centerLng + lngDelta * 0.1)
                        targets.append(Target(latLng: marker100, name: "100", yardage: 100))
                    }
                    
                    // Add pin at green
                    targets.append(Target(latLng: greenLocation, name: "Pin", yardage: yardage))
                }
            }
            
            completion(actualImage, calibration, greenLocation, targets)
        }
    }
    
    // Keep the synchronous version for backward compatibility
    func generateCourseHoleSync(from course: GolfCourse, holeNumber: Int = 1, gpsCoordinates: [[String: Any]]? = nil) -> (UIImage, GeoCalibration, LatLng, [Target]) {
        // Render course based on API data (synchronous fallback)
        let courseImage = CourseRenderer.renderCourse(course, holeNumber: holeNumber, gpsCoordinates: gpsCoordinates)
        
        // Create calibration based on course location
        let centerLat = course.location.latitude
        let centerLng = course.location.longitude
        
        // Estimate course bounds (approximately 1km x 1.5km for a typical hole)
        let latDelta = 0.004 // ~400m
        let lngDelta = 0.005 // ~500m
        
        let topLeft = LatLng(centerLat + latDelta, centerLng - lngDelta)
        let topRight = LatLng(centerLat + latDelta, centerLng + lngDelta)
        let bottomLeft = LatLng(centerLat - latDelta, centerLng - lngDelta)
        
        let calibration = GeoCalibration.fromCorners(
            latLngTopLeft: topLeft,
            latLngTopRight: topRight,
            latLngBottomLeft: bottomLeft,
            imageWidth: courseImage.size.width,
            imageHeight: courseImage.size.height
        )
        
        let greenLocation = LatLng(centerLat - latDelta * 0.6, centerLng)
        
        // Generate targets based on course data
        var targets: [Target] = []
        
        // Add tee box as target
        let teeLocation = LatLng(centerLat + latDelta * 0.6, centerLng)
        targets.append(Target(latLng: teeLocation, name: "Tee", yardage: 0))
        
        // Add distance markers based on hole data
        if let tees = course.tees, let maleTees = tees.male, !maleTees.isEmpty {
            let teeBox = maleTees[0]
            
            if let holes = teeBox.holes, holes.count >= holeNumber {
                let hole = holes[holeNumber - 1]
                let yardage = hole.yardage
                
                // Add markers based on yardage
                if yardage > 200 {
                    let marker200 = LatLng(centerLat + latDelta * 0.2, centerLng + lngDelta * 0.1)
                    targets.append(Target(latLng: marker200, name: "200", yardage: 200))
                }
                
                if yardage > 150 {
                    let marker150 = LatLng(centerLat, centerLng + lngDelta * 0.15)
                    targets.append(Target(latLng: marker150, name: "150", yardage: 150))
                }
                
                if yardage > 100 {
                    let marker100 = LatLng(centerLat - latDelta * 0.2, centerLng + lngDelta * 0.1)
                    targets.append(Target(latLng: marker100, name: "100", yardage: 100))
                }
                
                // Add pin at green
                targets.append(Target(latLng: greenLocation, name: "Pin", yardage: yardage))
            }
        }
        
        return (courseImage, calibration, greenLocation, targets)
    }
    
    func convertCourseToMapData(_ course: GolfCourse, holeNumber: Int = 1) -> (LatLng, [Target])? {
        let courseCenter = LatLng(course.location.latitude, course.location.longitude)
        
        var targets: [Target] = []
        
        // Add course location as a target
        targets.append(Target(latLng: courseCenter, name: course.courseName, yardage: 0))
        
        // Add tee box information as targets
        if let tees = course.tees {
            if let maleTees = tees.male {
                for (index, tee) in maleTees.enumerated() {
                    let teeLocation = LatLng(
                        courseCenter.latitude + Double(index) * 0.001,
                        courseCenter.longitude + Double(index) * 0.001
                    )
                    targets.append(Target(
                        latLng: teeLocation,
                        name: "\(tee.teeName) Tee",
                        yardage: tee.totalYards
                    ))
                }
            }
        }
        
        return (courseCenter, targets)
    }
    
    private func createSampleFairwayImage() -> UIImage {
        let size = CGSize(width: 800, height: 1200)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        context.setFillColor(UIColor.systemGreen.withAlphaComponent(0.3).cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        context.setFillColor(UIColor.systemGreen.cgColor)
        let fairwayPath = UIBezierPath()
        fairwayPath.move(to: CGPoint(x: size.width * 0.5, y: size.height * 0.9))
        fairwayPath.addQuadCurve(
            to: CGPoint(x: size.width * 0.6, y: size.height * 0.7),
            controlPoint: CGPoint(x: size.width * 0.4, y: size.height * 0.8)
        )
        fairwayPath.addQuadCurve(
            to: CGPoint(x: size.width * 0.5, y: size.height * 0.3),
            controlPoint: CGPoint(x: size.width * 0.7, y: size.height * 0.5)
        )
        fairwayPath.addQuadCurve(
            to: CGPoint(x: size.width * 0.4, y: size.height * 0.1),
            controlPoint: CGPoint(x: size.width * 0.3, y: size.height * 0.2)
        )
        
        fairwayPath.lineWidth = 120
        fairwayPath.stroke()
        
        context.setFillColor(UIColor.systemGreen.withAlphaComponent(0.8).cgColor)
        let green = CGRect(
            x: size.width * 0.35,
            y: size.height * 0.05,
            width: size.width * 0.3,
            height: size.height * 0.15
        )
        context.fillEllipse(in: green)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}

private struct CourseSearchResponse: Codable {
    let courses: [GolfCourse]
}

enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
}


