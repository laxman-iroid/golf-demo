import UIKit

extension FairwayMapView {
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            if isPinChangeEnabled, let pinLoc = pinLocation, let pinScreen = latLngToScreen(pinLoc) {
                let distance = sqrt(pow(location.x - pinScreen.x, 2) + pow(location.y - pinScreen.y, 2))
                if distance < 30 {
                    isDraggingPin = true
                    return
                }
            }
            
        case .changed:
            if isDraggingPin {
                if let newLatLng = screenToLatLng(location) {
                    setPinLocation(newLatLng)
                }
            } else {
                let newTransform = userTransform.translatedBy(x: translation.x, y: translation.y)
                userTransform = constrainTransform(newTransform)
                setNeedsDisplay()
                gesture.setTranslation(.zero, in: self)
            }
            
        case .ended, .cancelled:
            if isDraggingPin {
                if let newLatLng = screenToLatLng(location) {
                    delegate?.fairwayMapView(self, didMovePinTo: newLatLng)
                }
                isDraggingPin = false
            }
            
        default:
            break
        }
    }
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard !isDraggingPin else { return }
        
        switch gesture.state {
        case .began, .changed:
            let scale = gesture.scale
            let location = gesture.location(in: self)
            
            let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
            let translateToOrigin = CGAffineTransform(translationX: -location.x, y: -location.y)
            let translateBack = CGAffineTransform(translationX: location.x, y: location.y)
            
            let combinedTransform = translateToOrigin
                .concatenating(scaleTransform)
                .concatenating(translateBack)
            
            let newTransform = userTransform.concatenating(combinedTransform)
            userTransform = constrainTransform(newTransform)
            
            setNeedsDisplay()
            gesture.scale = 1.0
            
        default:
            break
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        
        for target in targets where target.enabled {
            guard let targetScreen = latLngToScreen(target.latLng) else { continue }
            
            let distance = sqrt(pow(location.x - targetScreen.x, 2) + pow(location.y - targetScreen.y, 2))
            if distance < 30 {
                setActiveTarget(target)
                delegate?.fairwayMapView(self, didSelectTarget: target)
                return
            }
        }
        
        if isPinChangeEnabled, let newLatLng = screenToLatLng(location) {
            setPinLocation(newLatLng)
            delegate?.fairwayMapView(self, didMovePinTo: newLatLng)
        }
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        
        let zoomScale: CGFloat = 2.0
        let scaleTransform = CGAffineTransform(scaleX: zoomScale, y: zoomScale)
        let translateToOrigin = CGAffineTransform(translationX: -location.x, y: -location.y)
        let translateBack = CGAffineTransform(translationX: location.x, y: location.y)
        
        let combinedTransform = translateToOrigin
            .concatenating(scaleTransform)
            .concatenating(translateBack)
        
        let newTransform = userTransform.concatenating(combinedTransform)
        
        UIView.animate(withDuration: 0.3) {
            self.userTransform = self.constrainTransform(newTransform)
            self.setNeedsDisplay()
        }
    }
    
    private func constrainTransform(_ transform: CGAffineTransform) -> CGAffineTransform {
        guard let image = fairwayImage else { return transform }
        
        let scaleX = sqrt(transform.a * transform.a + transform.c * transform.c)
        let scaleY = sqrt(transform.b * transform.b + transform.d * transform.d)
        
        let clampedScaleX = max(minZoom, min(maxZoom, scaleX))
        let clampedScaleY = max(minZoom, min(maxZoom, scaleY))
        
        let angle = atan2(transform.b, transform.a)
        
        var constrainedTransform = CGAffineTransform(scaleX: clampedScaleX, y: clampedScaleY)
        constrainedTransform = constrainedTransform.rotated(by: angle)
        
        let imageSize = image.size
        let drawTransform = imageFitTransform.concatenating(rotationTransform).concatenating(constrainedTransform)
        
        let imageCorners = [
            CGPoint.zero,
            CGPoint(x: imageSize.width, y: 0),
            CGPoint(x: 0, y: imageSize.height),
            CGPoint(x: imageSize.width, y: imageSize.height)
        ]
        
        let transformedCorners = imageCorners.map { $0.applying(drawTransform) }
        
        let minX = transformedCorners.map { $0.x }.min() ?? 0
        let maxX = transformedCorners.map { $0.x }.max() ?? bounds.width
        let minY = transformedCorners.map { $0.y }.min() ?? 0
        let maxY = transformedCorners.map { $0.y }.max() ?? bounds.height
        
        var tx = transform.tx
        var ty = transform.ty
        
        if maxX - minX < bounds.width {
            tx = (bounds.width - (maxX - minX)) / 2 - minX
        } else {
            if minX > 0 { tx -= minX }
            if maxX < bounds.width { tx += bounds.width - maxX }
        }
        
        if maxY - minY < bounds.height {
            ty = (bounds.height - (maxY - minY)) / 2 - minY
        } else {
            if minY > 0 { ty -= minY }
            if maxY < bounds.height { ty += bounds.height - maxY }
        }
        
        constrainedTransform.tx = tx
        constrainedTransform.ty = ty
        
        return constrainedTransform
    }
}