//
//  DesignClass.swift
//  cv-shots-recruitment
//
//  Created by iMac on 31/05/22.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

@IBDesignable
open class dateSportButton: UIButton {
    
    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable
    public var borderColor : UIColor? {
        didSet {
            self.layer.borderColor = self.borderColor?.cgColor
        }
    }
    
    @IBInspectable
    public var borderWidth : CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
        }
    }
    
    @IBInspectable var shadowColor: UIColor?{
         set {
            guard let uiColor = newValue else { return }
            layer.shadowColor = uiColor.cgColor
        }
        get{
            guard let color = layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
    @IBInspectable var shadowOpacity: Float{
        set {
            layer.shadowOpacity = newValue
        }
        get{
            return layer.shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGSize{
        set {
            layer.shadowOffset = newValue
        }
        get{
            return layer.shadowOffset
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat{
        set {
            layer.shadowRadius = newValue
        }
        get{
            return layer.shadowRadius
        }
    }
    
    @IBInspectable var buttonImage: UIImage? {
        set {
            self.setImage(newValue, for: .normal)
        }
        get {
            return self.image(for: .normal)
        }
    }
}


@IBDesignable
open class dateSportTextView : UITextView {
    
    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable
    public var borderColor : UIColor? {
        didSet {
            self.layer.borderColor = self.borderColor?.cgColor
        }
    }
    
    @IBInspectable
    public var borderWidth : CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
        }
    }
    
 
    
}

@IBDesignable
open class dateSportImageView : UIImageView {
    
    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable 
    public var borderColor : UIColor? {
        didSet {
            self.layer.borderColor = self.borderColor?.cgColor
        }
    }
    
    @IBInspectable
    public var borderWidth : CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
        }
    }
    
    @IBInspectable var shadowColor: UIColor?{
        set {
            guard let uiColor = newValue else { return }
            layer.shadowColor = uiColor.cgColor
        }
        get{
            guard let color = layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
    @IBInspectable var shadowOpacity: Float{
        set {
            layer.shadowOpacity = newValue
        }
        get{
            return layer.shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGSize{
        set {
            layer.shadowOffset = newValue
        }
        get{
            return layer.shadowOffset
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat{
        set {
            layer.shadowRadius = newValue
        }
        get{
            return layer.shadowRadius
        }
    }
    
}

@IBDesignable
open class dateSportView : UIView {
    
    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
            self.clipsToBounds = cornerRadius == self.frame.size.width/2
        }
    }
    
    @IBInspectable
    public var borderColor : UIColor? {
        didSet {
            self.layer.borderColor = self.borderColor?.cgColor
        }
    }
    
    @IBInspectable
    public var borderWidth : CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
        }
    }
    
    @IBInspectable var shadowColor: UIColor?{
         set {
            guard let uiColor = newValue else { return }
            layer.shadowColor = uiColor.cgColor
        }
        get{
            guard let color = layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
    @IBInspectable var shadowOpacity: Float{
        set {
            layer.shadowOpacity = newValue
        }
        get{
            return layer.shadowOpacity
        }
    }
    
    @IBInspectable var shadowOffset: CGSize{
        set {
            layer.shadowOffset = newValue
        }
        get{
            return layer.shadowOffset
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat{
        set {
            layer.shadowRadius = newValue
        }
        get{
            return layer.shadowRadius
        }
    }
 
}

@IBDesignable
open class dateSportLabel : UILabel {
    
    // Define available font styles for Poppins
    enum FontStyle: Int, CaseIterable {
        case thin
        case extraLight
        case light
        case regular
        case medium
        case semiBold
        case bold
        case extraBold
        case black
        
        var fontName: String {
            switch self {
            case .thin:
                return "Outfit-Thin"
            case .extraLight:
                return "Outfit-ExtraLight"
            case .light:
                return "Outfit-Light"
            case .regular:
                return "Outfit-Regular"
            case .medium:
                return "Outfit-Medium"
            case .semiBold:
                return "Outfit-SemiBold"
            case .bold:
                return "Outfit-Bold"
            case .extraBold:
                return "Outfit-ExtraBold"
            case .black:
                return "Outfit-Black"
            }
        }
        
        static func fontName(for index: Int) -> String {
            return FontStyle(rawValue: index)?.fontName ?? "Outfit-Regular"
        }
    }
    
    // This property will appear in Interface Builder as a dropdown
    @IBInspectable var fontStyleIndex: Int = 0 {
        didSet {
            let fontName = FontStyle.fontName(for: fontStyleIndex)
            if let font = UIFont(name: fontName, size: fontSize) {
                self.font = font
            } else {
                print("Error: Font '\(fontName)' not found")
            }
        }
    }
    
    // Define your font size
    @IBInspectable var fontSize: CGFloat = 14.0 {
        didSet {
            self.font = self.font?.withSize(fontSize)
        }
    }
    
    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
            self.clipsToBounds = cornerRadius == self.frame.size.width/2
        }
    }
    
    @IBInspectable
    public var borderColor : UIColor? {
        didSet {
            self.layer.borderColor = self.borderColor?.cgColor
        }
    }
    
    @IBInspectable
    public var borderWidth : CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
        }
}
}


@IBDesignable
open class dateSportTextField: UITextField {
    
    // Define available font styles for Poppins
    enum FontStyle: Int, CaseIterable {
        case thin
        case extraLight
        case light
        case regular
        case medium
        case semiBold
        case bold
        case extraBold
        case black
        
        var fontName: String {
            switch self {
            case .thin:
                return "Outfit-Thin"
            case .extraLight:
                return "Outfit-ExtraLight"
            case .light:
                return "Outfit-Light"
            case .regular:
                return "Outfit-Regular"
            case .medium:
                return "Outfit-Medium"
            case .semiBold:
                return "Outfit-SemiBold"
            case .bold:
                return "Outfit-Bold"
            case .extraBold:
                return "Outfit-ExtraBold"
            case .black:
                return "Outfit-Black"
            }
        }
        
        static func fontName(for index: Int) -> String {
            return FontStyle(rawValue: index)?.fontName ?? "Outfit-Regular"
        }
    }
    
    // This property will appear in Interface Builder as a dropdown
    @IBInspectable var fontStyleIndex: Int = 0 {
        didSet {
            let fontName = FontStyle.fontName(for: fontStyleIndex)
            if let font = UIFont(name: fontName, size: fontSize) {
                self.font = font
            } else {
                print("Error: Font '\(fontName)' not found")
            }
        }
    }
    
    // Define your font size
    @IBInspectable var fontSize: CGFloat = 14.0 {
        didSet {
            self.font = self.font?.withSize(fontSize)
        }
    }
    
    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable
    public var borderColor : UIColor? {
        didSet {
            self.layer.borderColor = self.borderColor?.cgColor
        }
    }
    
    @IBInspectable
    public var borderWidth : CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
        }
    }
  
       @IBInspectable var placeHolderColor: UIColor? {
            get {
                return self.placeHolderColor
            }
            set {
                self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
            }
        }
    
    var padding = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)

        @IBInspectable var left: CGFloat = 0 {
            didSet {
                adjustPadding()
            }
        }

        @IBInspectable var right: CGFloat = 0 {
            didSet {
                adjustPadding()
            }
        }

        @IBInspectable var top: CGFloat = 0 {
            didSet {
                adjustPadding()
            }
        }

        @IBInspectable var bottom: CGFloat = 0 {
            didSet {
                adjustPadding()
            }
        }

        func adjustPadding() {
             padding = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)

        }

    open override func prepareForInterfaceBuilder() {
            super.prepareForInterfaceBuilder()
        }

    open override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
        }

    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
        }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
             return bounds.inset(by: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
        }
}

@IBDesignable
open class CustomDashedView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var dashWidth: CGFloat = 0
    @IBInspectable var dashColor: UIColor = .clear
    @IBInspectable var dashLength: CGFloat = 0
    @IBInspectable var betweenDashesSpace: CGFloat = 0
    
    var dashBorder: CAShapeLayer?
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        dashBorder?.removeFromSuperlayer()
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = dashWidth
        dashBorder.strokeColor = dashColor.cgColor
        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        if cornerRadius > 0 {
            dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        } else {
            dashBorder.path = UIBezierPath(rect: bounds).cgPath
        }
        layer.addSublayer(dashBorder)
        self.dashBorder = dashBorder
    }
}

//@IBDesignable
//class DashedLineView: UIView {
//
//    @IBInspectable var dashColor: UIColor = .black {
//        didSet { setNeedsLayout() }
//    }
//
//    @IBInspectable var dashLength: CGFloat = 6 {
//        didSet { setNeedsLayout() }
//    }
//
//    @IBInspectable var gapLength: CGFloat = 3 {
//        didSet { setNeedsLayout() }
//    }
//
//    @IBInspectable var lineWidth: CGFloat = 1 {
//        didSet { setNeedsLayout() }
//    }
//
//    @IBInspectable var isVertical: Bool = false {
//        didSet { setNeedsLayout() }
//    }
//
//    private var dashLayer: CAShapeLayer?
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        dashLayer?.removeFromSuperlayer()
//
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.strokeColor = dashColor.cgColor
//        shapeLayer.lineWidth = lineWidth
//        shapeLayer.lineDashPattern = [NSNumber(value: Float(dashLength)),
//                                      NSNumber(value: Float(gapLength))]
//
//        let path = CGMutablePath()
//        if isVertical {
//            path.addLines(between: [
//                CGPoint(x: bounds.midX, y: 0),
//                CGPoint(x: bounds.midX, y: bounds.height)
//            ])
//        } else {
//            path.addLines(between: [
//                CGPoint(x: 0, y: bounds.midY),
//                CGPoint(x: bounds.width, y: bounds.midY)
//            ])
//        }
//
//        shapeLayer.path = path
//        shapeLayer.frame = bounds
//
//        layer.addSublayer(shapeLayer)
//        dashLayer = shapeLayer
//    }
//}

@IBDesignable class GradientView: UIView {
    @IBInspectable var topColor: UIColor = UIColor.white
    @IBInspectable var bottomColor: UIColor = UIColor.black
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
    }
}


@IBDesignable
class GradientView2: UIView {
    
    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var isHorizontal: Bool = true {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [firstColor, secondColor].map {$0.cgColor}
        if (isHorizontal) {
            layer.startPoint = CGPoint(x: 0, y: 0.5)
            layer.endPoint = CGPoint (x: 1, y: 0.5)
        } else {
            layer.startPoint = CGPoint(x: 0.5, y: 0)
            layer.endPoint = CGPoint (x: 0.5, y: 1)
        }
    }
    
}

@IBDesignable
class DashedLineView : UIView {
    @IBInspectable var perDashLength: CGFloat = 2.0
    @IBInspectable var spaceBetweenDash: CGFloat = 2.0
    
    @IBInspectable var dashColor: UIColor = UIColor { trait in
        trait.userInterfaceStyle == .dark ? .white : .lightGray
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let  path = UIBezierPath()
        if height > width {
            let  p0 = CGPoint(x: self.bounds.midX, y: self.bounds.minY)
            path.move(to: p0)
            
            let  p1 = CGPoint(x: self.bounds.midX, y: self.bounds.maxY)
            path.addLine(to: p1)
            path.lineWidth = width
            
        } else {
            let  p0 = CGPoint(x: self.bounds.minX, y: self.bounds.midY)
            path.move(to: p0)
            
            let  p1 = CGPoint(x: self.bounds.maxX, y: self.bounds.midY)
            path.addLine(to: p1)
            path.lineWidth = height
        }
        
        let  dashes: [ CGFloat ] = [ perDashLength, spaceBetweenDash ]
        path.setLineDash(dashes, count: dashes.count, phase: 0.0)
        
        path.lineCapStyle = .butt
        dashColor.set()
        path.stroke()
    }
    
    private var width : CGFloat {
        return self.bounds.width
    }
    
    private var height : CGFloat {
        return self.bounds.height
    }
}
@IBDesignable class ShadowView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 8.0
    @IBInspectable var shadowOpacity: Float = 0.2
    @IBInspectable var shadowRadius: CGFloat = 2.0
    @IBInspectable var shadowColor: UIColor = UIColor.lightGray

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // corner radius
        self.layer.cornerRadius = cornerRadius

        // border
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.lightGray.cgColor

        // shadow
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 3)
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
    }
}
@IBDesignable class CustomTextField: UITextField {
    @IBInspectable var leftPadding: CGFloat = 8.0
    @IBInspectable var rightPadding: CGFloat = 8.0
    @IBInspectable var topPadding: CGFloat = 8.0
    @IBInspectable var bottomPadding: CGFloat = 8.0
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding))
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding))
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding))
    }
}

@IBDesignable class ViewBottomShadow: UIView {
    @IBInspectable var opacity :CGFloat = 0.5
    @IBInspectable var shadowColor :UIColor = #colorLiteral(red: 0.8, green: 0.9607843137, blue: 0.9568627451, alpha: 0.5)

  required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
    backgroundColor = .white
    layer.masksToBounds = false
    layer.shadowRadius = 5
    layer.shadowOpacity = Float(opacity)
    layer.shadowColor = shadowColor.cgColor
    layer.shadowOffset = CGSize(width: 2 , height:5)
  }

}
@IBDesignable class CustomImageView:UIImageView {
    @IBInspectable var tintedColor: UIColor{
        get{
            return tintColor
        }
        set{
            image = image?.withRenderingMode(.alwaysTemplate)
            tintColor = newValue
        }
    }
}
class ShadowNewView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // corner radius
        self.layer.cornerRadius = 14

        // border
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.black.cgColor

        // shadow
        self.layer.shadowColor = #colorLiteral(red: 0.81765908, green: 0.8176783919, blue: 0.8176679015, alpha: 1)
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 4.0
    }

}
@IBDesignable class VerticalGradientView: UIView {
    @IBInspectable var firstColor: UIColor = #colorLiteral(red: 0, green: 0.8666666667, blue: 0.6, alpha: 1)
    @IBInspectable var secondColor: UIColor = #colorLiteral(red: 0.01176470588, green: 0.6705882353, blue: 0.9098039216, alpha: 1)

    @IBInspectable var vertical: Bool = false

    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [firstColor.cgColor, secondColor.cgColor]
        layer.startPoint = CGPoint.zero
        return layer
    }()

    //MARK: -

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        applyGradient()
    }
 
    override init(frame: CGRect) {
        super.init(frame: frame)

        applyGradient()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        applyGradient()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }

    //MARK: -

    func applyGradient() {
        updateGradientDirection()
        layer.sublayers = [gradientLayer]
    }

    func updateGradientFrame() {
        gradientLayer.frame = bounds
    }

    func updateGradientDirection() {
        gradientLayer.endPoint = vertical ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0)
    }
}

@IBDesignable class ThreeColorsGradientView: UIView {
    @IBInspectable var firstColor: UIColor = UIColor.clear
    @IBInspectable var secondColor: UIColor = #colorLiteral(red: 0.1450980392, green: 0.1450980392, blue: 0.1450980392, alpha: 1)
    @IBInspectable var thirdColor: UIColor = UIColor.clear

    @IBInspectable var vertical: Bool = true {
        didSet {
            updateGradientDirection()
        }
    }

    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [firstColor.cgColor, secondColor.cgColor, thirdColor.cgColor]
        layer.startPoint = CGPoint.zero
        return layer
    }()

    //MARK: -

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        applyGradient()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        applyGradient()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        applyGradient()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }

    //MARK: -

    func applyGradient() {
        updateGradientDirection()
        layer.sublayers = [gradientLayer]
    }

    func updateGradientFrame() {
        gradientLayer.frame = bounds
    }

    func updateGradientDirection() {
        gradientLayer.endPoint = vertical ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0)
    }
}

@IBDesignable class RadialGradientView: UIView {

    @IBInspectable var outsideColor: UIColor = UIColor.red
    @IBInspectable var insideColor: UIColor = UIColor.green

    override func awakeFromNib() {
        super.awakeFromNib()

        applyGradient()
    }

    func applyGradient() {
        let colors = [insideColor.cgColor, outsideColor.cgColor] as CFArray
        let endRadius = sqrt(pow(frame.width/2, 2) + pow(frame.height/2, 2))
        let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: nil)
        let context = UIGraphicsGetCurrentContext()

        context?.drawRadialGradient(gradient!, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: endRadius, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        applyGradient()
    }
}
@IBDesignable class BottomShadowView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        self.layer.shadowColor = #colorLiteral(red: 0.9725490196, green: 0.9960784314, blue: 0.9882352941, alpha: 1)
//        self.layer.shadowOffset = CGSize(width: 5, height: 10)
//        self.layer.shadowRadius = 8
//        self.layer.shadowOpacity = 1.0
        
        self.layer.shadowColor = #colorLiteral(red: 0.2274509804, green: 0.2235294118, blue: 0.2274509804, alpha: 0.08)
        self.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 5.0
        self.layer.masksToBounds = false

    }
}

private var __maxLengths = [UITextField: Int]()
extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
               return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix(textField: UITextField) {
        let t = textField.text
        textField.text = t?.prefix(maxLength) as? String
    }
}


@IBDesignable class ApplyTopGradientView: UIView {
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateLocations()
        updateColors()
    }

}

@IBDesignable class ApplyBottomGradientView: UIView {
    @IBInspectable var firstColor: UIColor = UIColor.white.withAlphaComponent(0.0)
    @IBInspectable var secondColor: UIColor = UIColor.white.withAlphaComponent(1.0)

    @IBInspectable var vertical: Bool = true

    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [firstColor.cgColor, secondColor.cgColor]
        layer.startPoint = CGPoint.zero
        return layer
    }()

    //MARK: -

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        applyGradient()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        applyGradient()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        applyGradient()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }

    //MARK: -

    func applyGradient() {
        updateGradientDirection()
        layer.sublayers = [gradientLayer]
    }

    func updateGradientFrame() {
        gradientLayer.frame = bounds
    }

    func updateGradientDirection() {
        gradientLayer.endPoint = vertical ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0)
    }
}





@IBDesignable
class DesignableButton: UIButton {
    
    @IBInspectable var topLeftRadius: CGFloat = 0 {
        didSet {
            updateCorners()
        }
    }
    
    @IBInspectable var topRightRadius: CGFloat = 0 {
        didSet {
            updateCorners()
        }
    }
    
    @IBInspectable var bottomLeftRadius: CGFloat = 0 {
        didSet {
            updateCorners()
        }
    }
    
    @IBInspectable var bottomRightRadius: CGFloat = 0 {
        didSet {
            updateCorners()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCorners()
    }
    
    private func updateCorners() {
        let maskPath = UIBezierPath()
        
        maskPath.move(to: CGPoint(x: topLeftRadius, y: 0))
        maskPath.addLine(to: CGPoint(x: bounds.width - topRightRadius, y: 0))
        maskPath.addArc(withCenter: CGPoint(x: bounds.width - topRightRadius, y: topRightRadius),
                        radius: topRightRadius,
                        startAngle: CGFloat(3 * Double.pi / 2),
                        endAngle: 0,
                        clockwise: true)
        maskPath.addLine(to: CGPoint(x: bounds.width, y: bounds.height - bottomRightRadius))
        maskPath.addArc(withCenter: CGPoint(x: bounds.width - bottomRightRadius, y: bounds.height - bottomRightRadius),
                        radius: bottomRightRadius,
                        startAngle: 0,
                        endAngle: CGFloat(Double.pi / 2),
                        clockwise: true)
        maskPath.addLine(to: CGPoint(x: bottomLeftRadius, y: bounds.height))
        maskPath.addArc(withCenter: CGPoint(x: bottomLeftRadius, y: bounds.height - bottomLeftRadius),
                        radius: bottomLeftRadius,
                        startAngle: CGFloat(Double.pi / 2),
                        endAngle: CGFloat(Double.pi),
                        clockwise: true)
        maskPath.addLine(to: CGPoint(x: 0, y: topLeftRadius))
        maskPath.addArc(withCenter: CGPoint(x: topLeftRadius, y: topLeftRadius),
                        radius: topLeftRadius,
                        startAngle: CGFloat(Double.pi),
                        endAngle: CGFloat(3 * Double.pi / 2),
                        clockwise: true)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        
        layer.mask = maskLayer
    }
}


class AudioTrimmerView: UIView {

    var audioPlayer: AVAudioPlayer?
        var trimStart: TimeInterval = 0.0
        var trimEnd: TimeInterval = 0.0

        override func draw(_ rect: CGRect) {
            super.draw(rect)

            guard let audioPlayer = audioPlayer else { return }

            // Draw audio waveform here based on the audio file
            // You may use a library like EZAudioPlot to simplify waveform drawing

            // Example: Drawing a simple rectangle for demonstration
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(UIColor.blue.cgColor)

            let totalDuration = audioPlayer.duration
            let startX = CGFloat(trimStart / totalDuration) * rect.width
            let endX = CGFloat(trimEnd / totalDuration) * rect.width
            let trimRect = CGRect(x: startX, y: 0, width: endX - startX, height: rect.height)
            context?.fill(trimRect)
        }

        // Handle user interaction to update the trim range
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }

            let touchLocation = touch.location(in: self)
            let normalizedX = max(0, min(touchLocation.x, bounds.width))
            let totalDuration = audioPlayer?.duration ?? 0

            trimEnd = TimeInterval((normalizedX / bounds.width) * totalDuration)
            setNeedsDisplay()
        }
}

protocol AudioTrimmerDelegate: AnyObject {
    func audioTrimmerDidFinishTrimming(trimmedAudioURL: URL)
    func audioTrimmerDidCancel()
}

@IBDesignable
class AudioTrimmerViewDefault : UIView {

    private var audioPlayer: AVAudioPlayer?
    private var audioURL: URL?

    // Set maximum duration for trimming
    private let maximumTrimDuration: TimeInterval = 7.0

    // MARK: - Public properties

    var backgroundImageView: UIImageView?

    // MARK: - Public methods

    func loadAudio(from url: URL) {
        self.audioURL = url
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
        } catch {
            print("Error loading audio: \(error.localizedDescription)")
        }
    }

    func trimAudio(start: TimeInterval, duration: TimeInterval, completion: @escaping (URL?) -> Void) {
        guard let audioURL = audioURL else {
            completion(nil)
            return
        }

        let asset = AVAsset(url: audioURL)
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)

        guard let session = exportSession else {
            completion(nil)
            return
        }

        let trimmedOutputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("trimmedAudio.m4a")

        session.outputFileType = .m4a
        session.outputURL = trimmedOutputURL

        let startTime = CMTime(seconds: start, preferredTimescale: 1000)
        let endTime = CMTime(seconds: start + duration, preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)

        session.timeRange = timeRange

        session.exportAsynchronously {
            switch session.status {
            case .completed:
                completion(trimmedOutputURL)
            case .failed, .cancelled:
                completion(nil)
            default:
                completion(nil)
            }
        }
    }

    // MARK: - Designable Properties

    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    // MARK: - Override Methods

    override func draw(_ rect: CGRect) {
        if let backgroundImageView = backgroundImageView {
            backgroundImageView.frame = bounds
            sendSubviewToBack(backgroundImageView)
        }
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackgroundImageView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBackgroundImageView()
    }

    private func setupBackgroundImageView() {
        let imageView = UIImageView(frame: bounds)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        sendSubviewToBack(imageView)
        backgroundImageView = imageView
    }
}

@IBDesignable
class UIViewX: UIView {
    
    // MARK: - Gradient
    
    @IBInspectable var firstColor: UIColor = UIColor.white {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var secondColor: UIColor = UIColor.white {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var horizontalGradient: Bool = false {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [ firstColor.cgColor, secondColor.cgColor ]
        
        if (horizontalGradient) {
            layer.startPoint = CGPoint(x: 0.0, y: 0.5)
            layer.endPoint = CGPoint(x: 1.0, y: 0.5)
        } else {
            layer.startPoint = CGPoint(x: 0, y: 0)
            layer.endPoint = CGPoint(x: 0, y: 1)
        }
    }
    
    // MARK: - Border
    
    @IBInspectable public var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable public var shadowOffsetY: CGFloat = 0 {
        didSet {
            layer.shadowOffset.height = shadowOffsetY
        }
    }
}


private var __customFonts = [UITextField: FontStyle]()

extension UITextField {
    // IBInspectable property for setting the font name
    @IBInspectable var customFontName: Int {
        get {
            return __customFonts[self]?.rawValue ?? FontStyle.regular.rawValue
        }
        set {
            if let fontStyle = FontStyle(rawValue: newValue) {
                __customFonts[self] = fontStyle
                applyCustomFont()
            } else {
                print("Invalid font style index: \(newValue)")
            }
        }
    }
    
    // IBInspectable property for setting the font size
    @IBInspectable var customFontSize: CGFloat {
        get {
            return self.font?.pointSize ?? 17 // Default font size
        }
        set {
            applyCustomFont(size: newValue)
        }
    }
    
    // Method to apply the custom font
    private func applyCustomFont(size: CGFloat? = nil) {
        guard let fontStyle = __customFonts[self] else {
            return
        }
        
        // Determine the font size to use
        let fontSize = size ?? self.font?.pointSize ?? 17 // Default font size if not set
        
        // Check if the font is available
        let fontName = fontStyle.fontName
        if UIFont.familyNames.contains(where: { UIFont.fontNames(forFamilyName: $0).contains(fontName) }) {
            self.font = UIFont(name: fontName, size: fontSize)
        } else {
            print("Font \(fontName) is not available.")
        }
    }
}

private var __buttonCustomFonts = [UIButton: FontStyle]()

extension UIButton {
    @IBInspectable var customFontName: Int {
        get {
            return __buttonCustomFonts[self]?.rawValue ?? FontStyle.regular.rawValue
        }
        set {
            if let fontStyle = FontStyle(rawValue: newValue) {
                __buttonCustomFonts[self] = fontStyle
                applyCustomFont()
            } else {
                print("Invalid font style index: \(newValue)")
            }
        }
    }
    
    @IBInspectable var customFontSize: CGFloat {
        get {
            return self.titleLabel?.font.pointSize ?? 17 // Default font size
        }
        set {
            applyCustomFont(size: newValue)
        }
    }
    
    private func applyCustomFont(size: CGFloat? = nil) {
        guard let fontStyle = __buttonCustomFonts[self] else {
            return
        }
        
        let fontSize = size ?? self.titleLabel?.font.pointSize ?? 17 // Default font size
        let fontName = fontStyle.fontName
        
        if let font = UIFont(name: fontName, size: fontSize) {
            self.titleLabel?.font = font
        } else {
            print("Font \(fontName) is not available.")
        }
    }
}

private var __labelCustomFonts = [UILabel: FontStyle]()

extension UILabel {
    @IBInspectable var customFontName: Int {
        get {
            return __labelCustomFonts[self]?.rawValue ?? FontStyle.regular.rawValue
        }
        set {
            if let fontStyle = FontStyle(rawValue: newValue) {
                __labelCustomFonts[self] = fontStyle
                applyCustomFont()
            } else {
                print("Invalid font style index: \(newValue)")
            }
        }
    }
    
    @IBInspectable var customFontSize: CGFloat {
        get {
            return self.font?.pointSize ?? 17 // Default font size
        }
        set {
            applyCustomFont(size: newValue)
        }
    }
    
    private func applyCustomFont(size: CGFloat? = nil) {
        guard let fontStyle = __labelCustomFonts[self] else {
            return
        }
        
        let fontSize = size ?? self.font?.pointSize ?? 17 // Default font size
        let fontName = fontStyle.fontName
        
        if let font = UIFont(name: fontName, size: fontSize) {
            self.font = font
        } else {
            print("Font \(fontName) is not available.")
        }
    }
}

// Enum for Font Styles
enum FontStyle: Int, CaseIterable {
    case thin
    case extraLight
    case light
    case regular
    case medium
    case semiBold
    case bold
    case extraBold
    case black
    case dMSerifDisplayRegular
    case dMSerifDisplayitalic
    
    var fontName: String {
        switch self {
        case .thin:
            return "Outfit-Thin"
        case .extraLight:
            return "Outfit-ExtraLight"
        case .light:
            return "Outfit-Light"
        case .regular:
            return "Outfit-Regular"
        case .medium:
            return "Outfit-Medium"
        case .semiBold:
            return "Outfit-SemiBold"
        case .bold:
            return "Outfit-Bold"
        case .extraBold:
            return "Outfit-ExtraBold"
        case .black:
            return "Outfit-Black"
        case .dMSerifDisplayRegular:        // 9
            return "DMSerifDisplay-Regular"
        case .dMSerifDisplayitalic:         // 10
            return "DMSerifDisplay-Italic"
        }
    }
    
    static func fontName(for index: Int) -> String {
        return FontStyle(rawValue: index)?.fontName ?? "Outfit-Regular"
    }
}

class GradientCustomView: UIView {
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        backgroundColor = .clear // Ensures the view itself is transparent
        
        gradientLayer.colors = [
            UIColor.clear.cgColor,  // Fully transparent at the top
            UIColor.black.withAlphaComponent(0.3).cgColor, // Faded middle
            UIColor.black.cgColor  // Dark at the bottom
        ]
        gradientLayer.locations = [0.0, 0.6, 1.0] // Adjust for smooth transition
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.cornerRadius = 20 // Rounded corners for gradient
        layer.insertSublayer(gradientLayer, at: 0)
        
        // Apply rounded corners to the view
        layer.cornerRadius = 20
        layer.masksToBounds = true // Ensures gradient follows corner radius
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
