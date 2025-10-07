//
//  UIImage+Extension.swift
//  Car-rent-ios-app
//
//  Created by Nikunj Vaghela on 01/09/22.
//

import Foundation
import UIKit

struct ImageCompressor {
    static func compress(image: UIImage, maxByte: Int,
                         completion: @escaping (UIImage?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let currentImageSize = image.jpegData(compressionQuality: 1.0)?.count else {
                return completion(nil)
            }
        
            var iterationImage: UIImage? = image
            var iterationImageSize = currentImageSize
            var iterationCompression: CGFloat = 1.0
        
            while iterationImageSize > maxByte && iterationCompression > 0.01 {
                let percantageDecrease = getPercantageToDecreaseTo(forDataCount: iterationImageSize)
            
                let canvasSize = CGSize(width: image.size.width * iterationCompression,
                                        height: image.size.height * iterationCompression)
                UIGraphicsBeginImageContextWithOptions(canvasSize, false, image.scale)
                defer { UIGraphicsEndImageContext() }
                image.draw(in: CGRect(origin: .zero, size: canvasSize))
                iterationImage = UIGraphicsGetImageFromCurrentImageContext()
            
                guard let newImageSize = iterationImage?.jpegData(compressionQuality: 1.0)?.count else {
                    return completion(nil)
                }
                iterationImageSize = newImageSize
                iterationCompression -= percantageDecrease
            }
            completion(iterationImage)
        }
    }

    private static func getPercantageToDecreaseTo(forDataCount dataCount: Int) -> CGFloat {
        switch dataCount {
        case 0..<3000000: return 0.05
        case 3000000..<10000000: return 0.1
        default: return 0.2
        }
    }
}
extension UIImageView {
    
    func setImageTintColor(_ color: UIColor) {
        let tintedImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = tintedImage
        self.tintColor = color
    }
}
import UIKit
import ImageIO

extension UIImage {
    public class func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("Image data is not valid.")
            return nil
        }
        return UIImage.animatedImageWithSource(source)
    }

    public class func gif(name: String) -> UIImage? {
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else {
            print("GIF file \(name) not found")
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("Image data not valid")
            return nil
        }
        return gif(data: imageData)
    }

    private class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [UIImage]()
        var duration: TimeInterval = 0

        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: image))
                let frameDuration = UIImage.delayForImageAtIndex(i, source: source)
                duration += frameDuration
            }
        }

        return UIImage.animatedImage(with: images, duration: duration)
    }

    private class func delayForImageAtIndex(_ index: Int, source: CGImageSource) -> TimeInterval {
        var delay = 0.1

        if let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
           let gifProperties = cfProperties[kCGImagePropertyGIFDictionary] as? [CFString: Any] {
            
            if let gifDelay = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? Double {
                delay = gifDelay
            } else if let gifDelay = gifProperties[kCGImagePropertyGIFDelayTime] as? Double {
                delay = gifDelay
            }
        }

        return delay
    }
}
