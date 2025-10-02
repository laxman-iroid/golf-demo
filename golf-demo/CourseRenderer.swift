import UIKit
import CoreGraphics

class CourseRenderer {

    static func renderCourse(_ course: GolfCourse, holeNumber: Int = 1, gpsCoordinates: [[String: Any]]? = nil) -> UIImage {
        let canvasSize = CGSize(width: 1200, height: 1600)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        // Background - course terrain
        drawBackground(context: context, size: canvasSize)
        
        // Draw course layout based on API data
        if let tees = course.tees, let maleTees = tees.male, !maleTees.isEmpty {
            let teeBox = maleTees[0] // Use first tee box for now

            if let holes = teeBox.holes, holes.count >= holeNumber {
                let hole = holes[holeNumber - 1]

                // Use GPS coordinates if provided
                if let gpsCoords = gpsCoordinates, !gpsCoords.isEmpty {
                    drawHoleWithGPS(context: context, hole: hole, gpsCoordinates: gpsCoords, canvasSize: canvasSize, course: course)
                } else {
                    drawHole(context: context, hole: hole, canvasSize: canvasSize, course: course)
                }
            } else {
                // Draw generic hole layout if no specific hole data
                drawGenericHole(context: context, canvasSize: canvasSize, teeBox: teeBox)
            }
        } else {
            // Draw basic course outline if no tee data available
            drawBasicCourse(context: context, canvasSize: canvasSize)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
    private static func drawBackground(context: CGContext, size: CGSize) {
        // Base terrain color
        context.setFillColor(UIColor(red: 0.2, green: 0.4, blue: 0.1, alpha: 1.0).cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Add some texture/variation to the ground
        for _ in 0..<50 {
            let x = CGFloat.random(in: 0...size.width)
            let y = CGFloat.random(in: 0...size.height)
            let radius = CGFloat.random(in: 5...20)
            
            context.setFillColor(UIColor(red: 0.15, green: 0.35, blue: 0.08, alpha: 0.3).cgColor)
            context.fillEllipse(in: CGRect(x: x, y: y, width: radius, height: radius))
        }
    }
    
    private static func drawHole(context: CGContext, hole: Hole, canvasSize: CGSize, course: GolfCourse) {
        let par = hole.par
        let yardage = hole.yardage
        
        // Calculate hole layout based on par and yardage
        let holeLength = min(CGFloat(yardage) / 500.0 * canvasSize.height * 0.8, canvasSize.height * 0.9)
        
        switch par {
        case 3:
            drawPar3Layout(context: context, canvasSize: canvasSize, yardage: yardage, length: holeLength)
        case 4:
            drawPar4Layout(context: context, canvasSize: canvasSize, yardage: yardage, length: holeLength)
        case 5:
            drawPar5Layout(context: context, canvasSize: canvasSize, yardage: yardage, length: holeLength)
        default:
            drawGenericLayout(context: context, canvasSize: canvasSize, length: holeLength)
        }
        
        // Draw course info overlay
        drawCourseInfo(context: context, course: course, hole: hole, canvasSize: canvasSize)
    }
    
    private static func drawGenericHole(context: CGContext, canvasSize: CGSize, teeBox: TeeBox) {
        let totalYards = teeBox.totalYards
        
        // Estimate average hole length
        let avgHoleLength = CGFloat(totalYards) / CGFloat(teeBox.numberOfHoles) / 500.0 * canvasSize.height * 0.8
        
        drawGenericLayout(context: context, canvasSize: canvasSize, length: avgHoleLength)
        drawTeeBoxInfo(context: context, teeBox: teeBox, canvasSize: canvasSize)
    }
    
    private static func drawBasicCourse(context: CGContext, canvasSize: CGSize) {
        // Draw a basic 18-hole course outline
        let centerX = canvasSize.width / 2
        let centerY = canvasSize.height / 2
        let radius = min(canvasSize.width, canvasSize.height) * 0.4
        
        // Draw circular course layout
        context.setStrokeColor(UIColor(red: 0.1, green: 0.6, blue: 0.1, alpha: 1.0).cgColor)
        context.setLineWidth(8.0)
        context.strokeEllipse(in: CGRect(
            x: centerX - radius,
            y: centerY - radius,
            width: radius * 2,
            height: radius * 2
        ))
        
        // Add some fairway paths
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let startX = centerX + cos(angle) * radius * 0.8
            let startY = centerY + sin(angle) * radius * 0.8
            let endX = centerX + cos(angle) * radius * 0.3
            let endY = centerY + sin(angle) * radius * 0.3
            
            context.setStrokeColor(UIColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0).cgColor)
            context.setLineWidth(20.0)
            context.move(to: CGPoint(x: startX, y: startY))
            context.addLine(to: CGPoint(x: endX, y: endY))
            context.strokePath()
        }
    }
    
    private static func drawPar3Layout(context: CGContext, canvasSize: CGSize, yardage: Int, length: CGFloat) {
        let startY = canvasSize.height * 0.9
        let endY = startY - length
        let centerX = canvasSize.width / 2
        
        // Tee box
        drawTeeBox(context: context, center: CGPoint(x: centerX, y: startY), size: CGSize(width: 40, height: 20))
        
        // Straight fairway (Par 3 is typically straight)
        drawFairway(context: context, 
                   path: [
                    CGPoint(x: centerX, y: startY),
                    CGPoint(x: centerX, y: endY)
                   ],
                   width: 60)
        
        // Green
        drawGreen(context: context, center: CGPoint(x: centerX, y: endY), radius: 25)
        
        // Distance markers
        let markerY = startY - length * 0.5
        drawDistanceMarker(context: context, center: CGPoint(x: centerX - 40, y: markerY), distance: yardage / 2)
    }
    
    private static func drawPar4Layout(context: CGContext, canvasSize: CGSize, yardage: Int, length: CGFloat) {
        let startY = canvasSize.height * 0.9
        let endY = startY - length
        let centerX = canvasSize.width / 2
        
        // Create a slight dogleg for Par 4
        let doglegs = [
            CGPoint(x: centerX, y: startY),
            CGPoint(x: centerX + 50, y: startY - length * 0.4),
            CGPoint(x: centerX + 20, y: startY - length * 0.7),
            CGPoint(x: centerX, y: endY)
        ]
        
        // Tee box
        drawTeeBox(context: context, center: CGPoint(x: centerX, y: startY), size: CGSize(width: 50, height: 25))
        
        // Fairway with dogleg
        drawFairway(context: context, path: doglegs, width: 80)
        
        // Rough areas
        drawRough(context: context, fairwayPath: doglegs, roughWidth: 40)
        
        // Green
        drawGreen(context: context, center: CGPoint(x: centerX, y: endY), radius: 30)
        
        // Sand bunkers
        drawBunker(context: context, center: CGPoint(x: centerX + 60, y: endY + 40), radius: 15)
        drawBunker(context: context, center: CGPoint(x: centerX - 40, y: endY + 20), radius: 12)
        
        // Distance markers
        let marker150Y = startY - length * 0.4
        let marker100Y = startY - length * 0.7
        drawDistanceMarker(context: context, center: CGPoint(x: centerX + 60, y: marker150Y), distance: 150)
        drawDistanceMarker(context: context, center: CGPoint(x: centerX + 30, y: marker100Y), distance: 100)
    }
    
    private static func drawPar5Layout(context: CGContext, canvasSize: CGSize, yardage: Int, length: CGFloat) {
        let startY = canvasSize.height * 0.95
        let endY = startY - length
        let centerX = canvasSize.width / 2
        
        // Create an S-curve for Par 5
        let path = [
            CGPoint(x: centerX, y: startY),
            CGPoint(x: centerX - 80, y: startY - length * 0.3),
            CGPoint(x: centerX + 60, y: startY - length * 0.6),
            CGPoint(x: centerX - 20, y: startY - length * 0.85),
            CGPoint(x: centerX, y: endY)
        ]
        
        // Tee box
        drawTeeBox(context: context, center: CGPoint(x: centerX, y: startY), size: CGSize(width: 60, height: 30))
        
        // Wide fairway for Par 5
        drawFairway(context: context, path: path, width: 100)
        
        // Rough areas
        drawRough(context: context, fairwayPath: path, roughWidth: 50)
        
        // Green complex
        drawGreen(context: context, center: CGPoint(x: centerX, y: endY), radius: 35)
        
        // Multiple bunkers
        drawBunker(context: context, center: CGPoint(x: centerX - 90, y: startY - length * 0.3), radius: 20)
        drawBunker(context: context, center: CGPoint(x: centerX + 70, y: startY - length * 0.6), radius: 18)
        drawBunker(context: context, center: CGPoint(x: centerX + 50, y: endY + 30), radius: 15)
        drawBunker(context: context, center: CGPoint(x: centerX - 60, y: endY + 25), radius: 12)
        
        // Distance markers
        let marker250Y = startY - length * 0.3
        let marker150Y = startY - length * 0.6
        let marker100Y = startY - length * 0.85
        drawDistanceMarker(context: context, center: CGPoint(x: centerX - 90, y: marker250Y), distance: 250)
        drawDistanceMarker(context: context, center: CGPoint(x: centerX + 70, y: marker150Y), distance: 150)
        drawDistanceMarker(context: context, center: CGPoint(x: centerX - 30, y: marker100Y), distance: 100)
    }
    
    private static func drawGenericLayout(context: CGContext, canvasSize: CGSize, length: CGFloat) {
        let startY = canvasSize.height * 0.9
        let endY = startY - length
        let centerX = canvasSize.width / 2
        
        // Simple straight layout
        drawTeeBox(context: context, center: CGPoint(x: centerX, y: startY), size: CGSize(width: 45, height: 25))
        drawFairway(context: context, 
                   path: [
                    CGPoint(x: centerX, y: startY),
                    CGPoint(x: centerX, y: endY)
                   ],
                   width: 80)
        drawGreen(context: context, center: CGPoint(x: centerX, y: endY), radius: 28)
    }
    
    private static func drawTeeBox(context: CGContext, center: CGPoint, size: CGSize) {
        let rect = CGRect(
            x: center.x - size.width/2,
            y: center.y - size.height/2,
            width: size.width,
            height: size.height
        )
        
        context.setFillColor(UIColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 1.0).cgColor)
        context.fillEllipse(in: rect)
        
        context.setStrokeColor(UIColor.brown.cgColor)
        context.setLineWidth(2.0)
        context.strokeEllipse(in: rect)
    }
    
    private static func drawFairway(context: CGContext, path: [CGPoint], width: CGFloat) {
        guard path.count >= 2 else { return }
        
        context.setStrokeColor(UIColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1.0).cgColor)
        context.setLineWidth(width)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        context.move(to: path[0])
        for i in 1..<path.count {
            context.addLine(to: path[i])
        }
        context.strokePath()
    }
    
    private static func drawRough(context: CGContext, fairwayPath: [CGPoint], roughWidth: CGFloat) {
        guard fairwayPath.count >= 2 else { return }
        
        // Draw rough on both sides of fairway
        context.setStrokeColor(UIColor(red: 0.25, green: 0.5, blue: 0.25, alpha: 0.6).cgColor)
        context.setLineWidth(roughWidth)
        context.setLineCap(.round)
        
        // Left rough
        context.move(to: CGPoint(x: fairwayPath[0].x - roughWidth/2, y: fairwayPath[0].y))
        for i in 1..<fairwayPath.count {
            context.addLine(to: CGPoint(x: fairwayPath[i].x - roughWidth/2, y: fairwayPath[i].y))
        }
        context.strokePath()
        
        // Right rough
        context.move(to: CGPoint(x: fairwayPath[0].x + roughWidth/2, y: fairwayPath[0].y))
        for i in 1..<fairwayPath.count {
            context.addLine(to: CGPoint(x: fairwayPath[i].x + roughWidth/2, y: fairwayPath[i].y))
        }
        context.strokePath()
    }
    
    private static func drawGreen(context: CGContext, center: CGPoint, radius: CGFloat) {
        let rect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )
        
        // Green fill
        context.setFillColor(UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0).cgColor)
        context.fillEllipse(in: rect)
        
        // Green outline
        context.setStrokeColor(UIColor(red: 0.1, green: 0.6, blue: 0.1, alpha: 1.0).cgColor)
        context.setLineWidth(3.0)
        context.strokeEllipse(in: rect)
        
        // Flag pin
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(2.0)
        context.move(to: center)
        context.addLine(to: CGPoint(x: center.x, y: center.y - 25))
        context.strokePath()
        
        // Flag
        let flagPath = UIBezierPath()
        flagPath.move(to: CGPoint(x: center.x, y: center.y - 25))
        flagPath.addLine(to: CGPoint(x: center.x + 15, y: center.y - 20))
        flagPath.addLine(to: CGPoint(x: center.x, y: center.y - 15))
        flagPath.close()
        
        context.setFillColor(UIColor.red.cgColor)
        context.addPath(flagPath.cgPath)
        context.fillPath()
    }
    
    private static func drawBunker(context: CGContext, center: CGPoint, radius: CGFloat) {
        let rect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )
        
        context.setFillColor(UIColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 1.0).cgColor)
        context.fillEllipse(in: rect)
        
        context.setStrokeColor(UIColor(red: 0.7, green: 0.6, blue: 0.4, alpha: 1.0).cgColor)
        context.setLineWidth(2.0)
        context.strokeEllipse(in: rect)
    }
    
    private static func drawDistanceMarker(context: CGContext, center: CGPoint, distance: Int) {
        let markerSize: CGFloat = 20
        let rect = CGRect(
            x: center.x - markerSize/2,
            y: center.y - markerSize/2,
            width: markerSize,
            height: markerSize
        )
        
        // Marker background
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: rect)
        
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(1.0)
        context.strokeEllipse(in: rect)
        
        // Distance text
        let text = "\(distance)"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()
        let textRect = CGRect(
            x: center.x - textSize.width/2,
            y: center.y - textSize.height/2,
            width: textSize.width,
            height: textSize.height
        )
        
        attributedString.draw(in: textRect)
    }
    
    private static func drawCourseInfo(context: CGContext, course: GolfCourse, hole: Hole, canvasSize: CGSize) {
        let infoText = """
        \(course.courseName)
        Hole: Par \(hole.par) - \(hole.yardage) yards
        \(course.location.city), \(course.location.state)
        """
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.white
        ]
        
        let attributedString = NSAttributedString(string: infoText, attributes: attributes)
        let textSize = attributedString.size()
        
        let padding: CGFloat = 12
        let backgroundRect = CGRect(
            x: 20,
            y: 20,
            width: textSize.width + 2*padding,
            height: textSize.height + 2*padding
        )
        
        // Background
        context.setFillColor(UIColor.black.withAlphaComponent(0.7).cgColor)
        context.fill(backgroundRect)
        
        // Text
        let textRect = CGRect(
            x: 20 + padding,
            y: 20 + padding,
            width: textSize.width,
            height: textSize.height
        )
        
        attributedString.draw(in: textRect)
    }
    
    private static func drawTeeBoxInfo(context: CGContext, teeBox: TeeBox, canvasSize: CGSize) {
        let infoText = """
        \(teeBox.teeName) Tees
        \(teeBox.numberOfHoles) holes - Par \(teeBox.parTotal)
        \(teeBox.totalYards) yards total
        Rating: \(teeBox.courseRating) / Slope: \(teeBox.slopeRating)
        """
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.white
        ]
        
        let attributedString = NSAttributedString(string: infoText, attributes: attributes)
        let textSize = attributedString.size()
        
        let padding: CGFloat = 10
        let backgroundRect = CGRect(
            x: 20,
            y: 20,
            width: textSize.width + 2*padding,
            height: textSize.height + 2*padding
        )
        
        // Background
        context.setFillColor(UIColor.black.withAlphaComponent(0.7).cgColor)
        context.fill(backgroundRect)
        
        // Text
        let textRect = CGRect(
            x: 20 + padding,
            y: 20 + padding,
            width: textSize.width,
            height: textSize.height
        )
        
        attributedString.draw(in: textRect)
    }

    // MARK: - GPS-Based Rendering

    private static func drawHoleWithGPS(context: CGContext, hole: Hole, gpsCoordinates: [[String: Any]], canvasSize: CGSize, course: GolfCourse) {
        print("🗺️ Drawing hole with \(gpsCoordinates.count) GPS points")

        // Parse GPS coordinates
        var allPoints: [(poi: String, lat: Double, lng: Double, location: String)] = []

        for coord in gpsCoordinates {
            if let poi = coord["poi"] as? String,
               let lat = coord["latitude"] as? Double,
               let lng = coord["longitude"] as? Double {
                let location = coord["location"] as? String ?? "0"
                allPoints.append((poi, lat, lng, location))
            }
        }

        guard !allPoints.isEmpty else {
            print("❌ No valid GPS points found")
            drawHole(context: context, hole: hole, canvasSize: canvasSize, course: course)
            return
        }

        // Find min/max for coordinate normalization
        let lats = allPoints.map { $0.lat }
        let lngs = allPoints.map { $0.lng }

        let minLat = lats.min() ?? 0
        let maxLat = lats.max() ?? 0
        let minLng = lngs.min() ?? 0
        let maxLng = lngs.max() ?? 0

        let latRange = maxLat - minLat
        let lngRange = maxLng - minLng

        // Add padding to canvas
        let padding: CGFloat = 100
        let drawableWidth = canvasSize.width - 2 * padding
        let drawableHeight = canvasSize.height - 2 * padding

        // Convert GPS to screen coordinates
        func gpsToScreen(lat: Double, lng: Double) -> CGPoint {
            let normalizedX = (lng - minLng) / lngRange
            let normalizedY = (lat - minLat) / latRange

            let x = padding + CGFloat(normalizedX) * drawableWidth
            let y = canvasSize.height - padding - CGFloat(normalizedY) * drawableHeight // Flip Y

            return CGPoint(x: x, y: y)
        }

        // Group points by POI type
        var teePoints: [CGPoint] = []
        var fairwayPoints: [CGPoint] = []
        var greenPoints: [CGPoint] = []
        var hazardPoints: [CGPoint] = []

        for point in allPoints {
            let screenPoint = gpsToScreen(lat: point.lat, lng: point.lng)

            switch point.poi {
            case "1":
                teePoints.append(screenPoint)
            case "2", "3", "4", "5", "6":
                fairwayPoints.append(screenPoint)
            case "9":
                hazardPoints.append(screenPoint)
            case "11", "12":
                greenPoints.append(screenPoint)
            default:
                break
            }
        }

        // Sort fairway points by POI order for proper path
        var sortedFairwayPoints: [CGPoint] = []
        for poi in ["1", "2", "3", "4", "5", "6", "11", "12"] {
            let poiPoints = allPoints.filter { $0.poi == poi }
            if let centerPoint = poiPoints.first(where: { $0.location == "2" }) ?? poiPoints.first {
                sortedFairwayPoints.append(gpsToScreen(lat: centerPoint.lat, lng: centerPoint.lng))
            }
        }

        print("✅ Converted: \(teePoints.count) tee, \(sortedFairwayPoints.count) fairway, \(greenPoints.count) green points")

        // Draw the hole using real GPS path
        if !sortedFairwayPoints.isEmpty {
            // Draw fairway with real GPS path
            drawFairway(context: context, path: sortedFairwayPoints, width: 100)

            // Draw rough around fairway
            drawRough(context: context, fairwayPath: sortedFairwayPoints, roughWidth: 50)

            // Draw tee box at first point
            if let teePoint = sortedFairwayPoints.first {
                drawTeeBox(context: context, center: teePoint, size: CGSize(width: 60, height: 30))
            }

            // Draw green at last point
            if let greenPoint = sortedFairwayPoints.last {
                drawGreen(context: context, center: greenPoint, radius: 35)
            }

            // Draw hazards/bunkers at marked locations
            for hazardPoint in hazardPoints {
                drawBunker(context: context, center: hazardPoint, radius: 18)
            }

            // Add distance markers along the path
            if sortedFairwayPoints.count >= 3 {
                let marker1Idx = sortedFairwayPoints.count / 3
                let marker2Idx = 2 * sortedFairwayPoints.count / 3

                drawDistanceMarker(context: context, center: sortedFairwayPoints[marker1Idx], distance: 250)
                drawDistanceMarker(context: context, center: sortedFairwayPoints[marker2Idx], distance: 150)
            }
        }

        // Draw course info
        drawCourseInfo(context: context, course: course, hole: hole, canvasSize: canvasSize)
    }
}