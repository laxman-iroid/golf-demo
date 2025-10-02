import Foundation
import CoreLocation

struct LatLng: Codable {
    let latitude: Double
    let longitude: Double
    
    init(_ latitude: Double, _ longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}

struct Target {
    let latLng: LatLng
    let name: String
    let yardage: Int
    let enabled: Bool
    
    init(latLng: LatLng, name: String, yardage: Int, enabled: Bool = true) {
        self.latLng = latLng
        self.name = name
        self.yardage = yardage
        self.enabled = enabled
    }
}

struct Shot {
    let latLng: LatLng
    let clubId: Int
    let distanceToTarget: Double
    let sequence: Int
}

class GeoCalibration {
    private let forwardTransform: CGAffineTransform
    private let inverseTransform: CGAffineTransform
    
    private init(forward: CGAffineTransform, inverse: CGAffineTransform) {
        self.forwardTransform = forward
        self.inverseTransform = inverse
    }
    
    static func fromCorners(
        latLngTopLeft: LatLng,
        latLngTopRight: LatLng,
        latLngBottomLeft: LatLng,
        imageWidth: CGFloat,
        imageHeight: CGFloat
    ) -> GeoCalibration {
        let topRight = latLngTopRight
        let bottomLeft = latLngBottomLeft
        let topLeft = latLngTopLeft
        
        let deltaLon = topRight.longitude - topLeft.longitude
        let deltaLat = bottomLeft.latitude - topLeft.latitude
        
        let scaleX = CGFloat(deltaLon) / imageWidth
        let scaleY = CGFloat(deltaLat) / imageHeight
        
        let forward = CGAffineTransform(
            a: scaleX, b: 0,
            c: 0, d: scaleY,
            tx: CGFloat(topLeft.longitude), ty: CGFloat(topLeft.latitude)
        )
        
        let inverse = forward.inverted()
        
        return GeoCalibration(forward: forward, inverse: inverse)
    }
    
    static func fromAffineCoefficients(
        a11: CGFloat, a12: CGFloat, a13: CGFloat,
        a21: CGFloat, a22: CGFloat, a23: CGFloat
    ) -> GeoCalibration {
        let forward = CGAffineTransform(
            a: a11, b: a12,
            c: a21, d: a22,
            tx: a13, ty: a23
        )
        
        let inverse = forward.inverted()
        
        return GeoCalibration(forward: forward, inverse: inverse)
    }
    
    func imageToLatLng(_ point: CGPoint) -> LatLng {
        let transformed = point.applying(forwardTransform)
        return LatLng(Double(transformed.y), Double(transformed.x))
    }
    
    func latLngToImage(_ latLng: LatLng) -> CGPoint {
        let point = CGPoint(x: latLng.longitude, y: latLng.latitude)
        return point.applying(inverseTransform)
    }
}

extension CLLocation {
    func yardsBetween(_ other: CLLocation) -> Double {
        let distanceMeters = distance(from: other)
        return distanceMeters * 1.09361
    }
}

extension LatLng {
    func yardsBetween(_ other: LatLng) -> Double {
        let location1 = CLLocation(latitude: latitude, longitude: longitude)
        let location2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return location1.yardsBetween(location2)
    }
}