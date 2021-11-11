//
//  VPShimmerImage.swift
//  CodersVOD
//
//  Created by Yousef on 2/11/21.
//

import UIKit

public class VPShimmerImage: UIView {
    // = UIImage(systemName: "house") 
    public var image: UIImage? {
        didSet {
            configure()
        }
    }
    
    public var text: String = "Shimmer" {
        didSet {
            configure()
        }
    }
    
    public var font: UIFont = .systemFont(ofSize: 14) {
        didSet {
            configure()
        }
    }
    
    public var textAlignment: NSTextAlignment = .center {
        didSet {
            configure()
        }
    }
    
    public var lightColor: UIColor = .white {
        didSet {
            configure()
        }
    }
    
    public var darkColor: UIColor = .black {
        didSet {
            configure()
        }
    }
    
    public var duration: CFTimeInterval = 3.0 {
        didSet {
//            updateGradiant()
        }
    }
    
    let darkImage: UIImageView = {
        let lbl = UIImageView()
        lbl.tintColor = .black
        lbl.contentMode = .scaleAspectFit
        lbl.image = UIImage(systemName: "person")
        return lbl
    }()
    
    let shinyImage: UIImageView = {
        let lbl = UIImageView()
        lbl.tintColor = .white
        lbl.contentMode = .scaleAspectFit
        lbl.image = UIImage(systemName: "person")
        return lbl
    }()
    
    var gradientLayer: CAGradientLayer?
    
    let keyPath = "position"
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(darkImage)
        addSubview(shinyImage)
        backgroundColor = .purple
        
        
    }
    
    var fromValue: CGPoint = CGPoint(x: -50, y: 25)
    var toValue: CGPoint = CGPoint(x: 50, y: 25)
    
//    var fromValue: CGPoint = CGPoint(x: -100, y: 0)
//    var toValue: CGPoint = CGPoint(x: 100, y: 0)
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        darkImage.frame = bounds
        shinyImage.frame = bounds
        
        shinyImage.layer.mask = nil
        
        fromValue = CGPoint(x: (frame.width / 2) - 50, y: 25)
        toValue = CGPoint(x: (frame.width / 2) + 50, y: 25)
        
        // Create Gradient Layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        let gradientColorOne :  CGColor = UIColor.clear.cgColor
        let gradientColorTwo : CGColor = UIColor.white.cgColor
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorTwo,   gradientColorOne]
        gradientLayer.locations = [0.0, 0.4, 0.6, 1.0]
        
        // Solid background no gradient
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = self.bounds
//        gradientLayer.backgroundColor = UIColor.green.cgColor
        
        
        // gradientLayer rotation
        let angle = -60 * CGFloat.pi / 180
        gradientLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        
        
        // gradientLayer animation
        let animation: CABasicAnimation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.repeatCount = .infinity
        animation.duration = duration
        gradientLayer.add(animation, forKey: animation.keyPath)
       
        shinyImage.layer.mask = gradientLayer
//        layer.addSublayer(gradientLayer)
        self.gradientLayer = gradientLayer
        
        
    }
    
    
    
    private func configure() {
        darkImage.image =  image
        shinyImage.image = image
        
        darkImage.tintColor = darkColor
        
        shinyImage.tintColor = lightColor
        
        gradientLayer?.colors = [UIColor.clear.cgColor, lightColor.cgColor, UIColor.clear.cgColor]
        
    }
    
    
//    private func updateGradiant() {
//        if let gradientLayer = self.gradientLayer {
//            if let animation = gradientLayer.animation(forKey: keyPath) {
//                animation.duration = duration
//            }
//        }
//    }
    
   
}
