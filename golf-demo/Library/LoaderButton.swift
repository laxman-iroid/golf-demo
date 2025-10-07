//
//  LoaderButton.swift
//  KarenSpottedApp
//
//  Created by Nikunj Vaghela on 12/04/23.
//

import Foundation
import UIKit
import Lottie

class LoaderButton: UIButton {
    // 2
    var spinner = UIActivityIndicatorView()
    
    // Load animation to AnimationView
    let animationView = LottieAnimationView(animation: LottieAnimation.named("loader"))
    
    var isLoading = false {
        didSet {
            // whenever `isLoading` state is changed, update the view
            updateView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 4
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        // 5
//        spinner.hidesWhenStopped = true
//        // to change spinner color
//        spinner.color = .white
//        // default style
//        spinner.style = .medium
        
        // 6
        // add as button subview
        self.animationView.frame = CGRect(x: (self.bounds.width / 2) - ((self.bounds.height / 2) - 10), y: 5, width: self.bounds.height - 10, height: self.bounds.height - 10)

        
        addSubview(self.animationView)
        
        self.animationView.transform = CGAffineTransformMakeScale(1.5, 1.5)
        self.animationView.contentMode = .scaleAspectFill
        self.animationView.alpha = 0
        self.animationView.loopMode = .loop

        // set constraints to always in the middle of button
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.animationView.frame = CGRect(x: (self.bounds.width / 2) - ((self.bounds.height - 10) / 2), y: 5, width: self.bounds.height - 10, height: self.bounds.height - 10)
    }
    
    // 7
    func updateView() {
        if isLoading {
            if Thread.isMainThread{
                self.animationView.alpha = 1
                self.animationView.play()
                self.titleLabel?.alpha = 0
                self.imageView?.alpha = 0
                // to prevent multiple click while in process
                self.isEnabled = false
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.animationView.alpha = 1
                    self?.animationView.play()
                    self?.titleLabel?.alpha = 0
                    self?.imageView?.alpha = 0
                    // to prevent multiple click while in process
                    self?.isEnabled = false
                }
            }
            appDelegate.window?.isUserInteractionEnabled = false
        } else {
            if Thread.isMainThread{
                self.animationView.alpha = 0
                self.animationView.pause()
                self.titleLabel?.alpha = 1
                self.imageView?.alpha = 0
                self.isEnabled = true
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.animationView.alpha = 0
                    self?.animationView.pause()
                    self?.titleLabel?.alpha = 1
                    self?.imageView?.alpha = 0
                    self?.isEnabled = true
                }
            }
            appDelegate.window?.isUserInteractionEnabled = true
        }
    }
}
extension UIButton {
    func imageWith(color: UIColor) {
        let image = self.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
        let colorizedImage = image?.tint(with: color)
        self.setImage(colorizedImage, for: state)
    }
}
