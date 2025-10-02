import UIKit
import CoreGraphics

protocol FairwayMapViewDelegate: AnyObject {
    func fairwayMapView(_ mapView: FairwayMapView, didSelectTarget target: Target)
    func fairwayMapView(_ mapView: FairwayMapView, didMovePinTo location: LatLng)
}

class FairwayMapView: UIView {
    
    weak var delegate: FairwayMapViewDelegate?
    
    var fairwayImage: UIImage?
    var geoCalibration: GeoCalibration?
    private var orientationDegrees: CGFloat = 0.0
    var targets: [Target] = []
    private var greenLocation: LatLng?
    
    private var playerLocation: LatLng?
    var pinLocation: LatLng?
    private var activeTarget: Target?
    
    var imageFitTransform: CGAffineTransform = .identity
    var userTransform: CGAffineTransform = .identity
    var rotationTransform: CGAffineTransform = .identity
    
    var minZoom: CGFloat = 0.1
    var maxZoom: CGFloat = 5.0
    
    var isPinChangeEnabled = false
    var areOverlaysEnabled = true
    var isDraggingPin = false
    
    private var panGesture: UIPanGestureRecognizer!
    private var pinchGesture: UIPinchGestureRecognizer!
    private var tapGesture: UITapGestureRecognizer!
    private var doubleTapGesture: UITapGestureRecognizer!
    
    private let playerIcon = UIImage(systemName: "person.circle.fill")
    private let pinIcon = UIImage(systemName: "mappin")
    private let targetIcon = UIImage(systemName: "target")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestures()
        backgroundColor = UIColor.systemBackground
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestures()
        backgroundColor = UIColor.systemBackground
    }
    
    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        
        doubleTapGesture.numberOfTapsRequired = 2
        tapGesture.require(toFail: doubleTapGesture)
        
        panGesture.delegate = self
        
        addGestureRecognizer(panGesture)
        addGestureRecognizer(pinchGesture)
        addGestureRecognizer(tapGesture)
        addGestureRecognizer(doubleTapGesture)
    }
    
    func setData(
        fairwayBitmap: UIImage,
        calibration: GeoCalibration,
        green: LatLng,
        orientationDegrees: CGFloat?,
        targets: [Target]
    ) {
        self.fairwayImage = fairwayBitmap
        self.geoCalibration = calibration
        self.greenLocation = green
        self.orientationDegrees = orientationDegrees ?? 0.0
        self.targets = targets
        
        updateImageFitTransform()
        setNeedsDisplay()
    }
    
    func setPinChangeEnabled(_ enabled: Bool) {
        isPinChangeEnabled = enabled
    }
    
    func setZoomToGreenCenter(zoomFactor: CGFloat = 1.0) {
        guard let green = greenLocation else { return }
        centerOn(green, animate: true)
        
        let scaleTransform = CGAffineTransform(scaleX: zoomFactor, y: zoomFactor)
        UIView.animate(withDuration: 0.3) {
            self.userTransform = self.userTransform.concatenating(scaleTransform)
            self.setNeedsDisplay()
        }
    }
    
    func screenToLatLng(_ point: CGPoint) -> LatLng? {
        guard let calibration = geoCalibration else { return nil }
        
        let drawTransform = getDrawTransform()
        guard let inverseTransform = drawTransform.inverted() as CGAffineTransform? else { return nil }
        
        let imagePoint = point.applying(inverseTransform)
        return calibration.imageToLatLng(imagePoint)
    }
    
    func latLngToScreen(_ latLng: LatLng) -> CGPoint? {
        guard let calibration = geoCalibration else { return nil }
        
        let imagePoint = calibration.latLngToImage(latLng)
        let drawTransform = getDrawTransform()
        return imagePoint.applying(drawTransform)
    }
    
    func centerOn(_ latLng: LatLng, animate: Bool = false) {
        guard let screenPoint = latLngToScreen(latLng) else { return }
        
        let centerOffset = CGPoint(
            x: bounds.midX - screenPoint.x,
            y: bounds.midY - screenPoint.y
        )
        
        let newTransform = userTransform.translatedBy(x: centerOffset.x, y: centerOffset.y)
        
        if animate {
            UIView.animate(withDuration: 0.3) {
                self.userTransform = newTransform
                self.setNeedsDisplay()
            }
        } else {
            userTransform = newTransform
            setNeedsDisplay()
        }
    }
    
    func setPlayerLocation(_ location: LatLng) {
        playerLocation = location
        setNeedsDisplay()
    }
    
    func setPinLocation(_ location: LatLng) {
        pinLocation = location
        setNeedsDisplay()
    }
    
    func setActiveTarget(_ target: Target?) {
        activeTarget = target
        setNeedsDisplay()
    }
    
    func setOverlaysEnabled(_ enabled: Bool) {
        areOverlaysEnabled = enabled
        setNeedsDisplay()
    }
    
    private func updateImageFitTransform() {
        guard let image = fairwayImage else { return }
        
        let imageSize = image.size
        let viewSize = bounds.size
        
        guard viewSize.width > 0 && viewSize.height > 0 && imageSize.width > 0 && imageSize.height > 0 else { return }
        
        let scaleX = viewSize.width / imageSize.width
        let scaleY = viewSize.height / imageSize.height
        let scale = min(scaleX, scaleY)
        
        let scaledSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let centerX = (viewSize.width - scaledSize.width) / 2
        let centerY = (viewSize.height - scaledSize.height) / 2
        
        imageFitTransform = CGAffineTransform(scaleX: scale, y: scale)
            .translatedBy(x: centerX / scale, y: centerY / scale)
        
        rotationTransform = CGAffineTransform(rotationAngle: orientationDegrees * .pi / 180)
        
        setNeedsDisplay()
    }
    
    private func getDrawTransform() -> CGAffineTransform {
        return imageFitTransform.concatenating(rotationTransform).concatenating(userTransform)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateImageFitTransform()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext(),
              let image = fairwayImage else { return }
        
        context.saveGState()
        
        let drawTransform = getDrawTransform()
        context.concatenate(drawTransform)
        
        context.draw(image.cgImage!, in: CGRect(origin: .zero, size: image.size))
        
        context.restoreGState()
        
        if areOverlaysEnabled {
            drawOverlays(in: context)
        }
    }
    
    private func drawOverlays(in context: CGContext) {
        drawPlayer(in: context)
        drawPin(in: context)
        drawTargets(in: context)
        drawDistanceLines(in: context)
    }
    
    private func drawPlayer(in context: CGContext) {
        guard let playerLoc = playerLocation,
              let screenPoint = latLngToScreen(playerLoc),
              let icon = playerIcon else { return }
        
        let iconSize: CGFloat = 24
        let rect = CGRect(
            x: screenPoint.x - iconSize/2,
            y: screenPoint.y - iconSize/2,
            width: iconSize,
            height: iconSize
        )
        
        context.saveGState()
        context.setFillColor(UIColor.blue.cgColor)
        context.fillEllipse(in: rect)
        context.restoreGState()
    }
    
    private func drawPin(in context: CGContext) {
        guard let pinLoc = pinLocation,
              let screenPoint = latLngToScreen(pinLoc) else { return }
        
        let iconSize: CGFloat = 20
        let rect = CGRect(
            x: screenPoint.x - iconSize/2,
            y: screenPoint.y - iconSize,
            width: iconSize,
            height: iconSize
        )
        
        context.saveGState()
        context.setFillColor(UIColor.red.cgColor)
        context.fillEllipse(in: CGRect(x: screenPoint.x - 3, y: screenPoint.y - 3, width: 6, height: 6))
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(2.0)
        context.move(to: CGPoint(x: screenPoint.x, y: screenPoint.y))
        context.addLine(to: CGPoint(x: screenPoint.x, y: screenPoint.y - 20))
        context.strokePath()
        context.restoreGState()
    }
    
    private func drawTargets(in context: CGContext) {
        for target in targets where target.enabled {
            guard let screenPoint = latLngToScreen(target.latLng) else { continue }
            
            let iconSize: CGFloat = 16
            let rect = CGRect(
                x: screenPoint.x - iconSize/2,
                y: screenPoint.y - iconSize/2,
                width: iconSize,
                height: iconSize
            )
            
            context.saveGState()
            
            let isActive = activeTarget?.name == target.name
            let color = isActive ? UIColor.orange.cgColor : UIColor.green.cgColor
            context.setFillColor(color)
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(1.0)
            
            context.fillEllipse(in: rect)
            context.strokeEllipse(in: rect)
            
            drawYardageText(target.name, yardage: target.yardage, at: screenPoint, in: context)
            
            context.restoreGState()
        }
    }
    
    private func drawDistanceLines(in context: CGContext) {
        guard let playerLoc = playerLocation,
              let playerScreen = latLngToScreen(playerLoc) else { return }
        
        let destinations: [(LatLng, UIColor)] = [
            (pinLocation, UIColor.red),
            (activeTarget?.latLng, UIColor.orange)
        ].compactMap { location, color in
            guard let loc = location else { return nil }
            return (loc, color)
        }
        
        for (destination, color) in destinations {
            guard let destScreen = latLngToScreen(destination) else { continue }
            
            context.saveGState()
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(2.0)
            context.setLineDash(phase: 0, lengths: [5, 3])
            context.move(to: playerScreen)
            context.addLine(to: destScreen)
            context.strokePath()
            context.restoreGState()
            
            let distance = Int(playerLoc.yardsBetween(destination))
            let midPoint = CGPoint(
                x: (playerScreen.x + destScreen.x) / 2,
                y: (playerScreen.y + destScreen.y) / 2
            )
            drawYardageText("\(distance)y", yardage: distance, at: midPoint, in: context)
        }
    }
    
    private func drawYardageText(_ text: String, yardage: Int, at point: CGPoint, in context: CGContext) {
        let font = UIFont.systemFont(ofSize: 12, weight: .medium)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()
        
        let padding: CGFloat = 4
        let backgroundRect = CGRect(
            x: point.x - textSize.width/2 - padding,
            y: point.y - textSize.height - padding,
            width: textSize.width + 2*padding,
            height: textSize.height + 2*padding
        )
        
        context.saveGState()
        context.setFillColor(UIColor.black.withAlphaComponent(0.8).cgColor)
        context.fill(backgroundRect)
        
        let textRect = CGRect(
            x: point.x - textSize.width/2,
            y: point.y - textSize.height,
            width: textSize.width,
            height: textSize.height
        )
        
        attributedString.draw(in: textRect)
        context.restoreGState()
    }
}

extension FairwayMapView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == panGesture || gestureRecognizer == pinchGesture
    }
}