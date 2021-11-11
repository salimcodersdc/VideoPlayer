//
//  Extensions.swift
//  autolayoutTransation
//
//  Created by Yousef on 2/4/21.
//

import UIKit
import AVFoundation

//MARK: - UIView

extension UIView {
    public func setConstraints(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, trailing: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize = CGSize(width: 0, height: 0)) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        if  let top = top  {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if  let leading = leading  {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if  let trailing = trailing  {
            trailingAnchor.constraint(equalTo: trailing, constant: padding.right * -1).isActive = true
        }
        
        if  let bottom = bottom  {
            bottomAnchor.constraint(equalTo: bottom, constant: padding.bottom * -1).isActive = true
        }
        
        if size.width > 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height > 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        
    }
    
    public func centerPosition(centerX: NSLayoutXAxisAnchor, centerY: NSLayoutYAxisAnchor, xOffest: CGFloat = 0, yOffset: CGFloat = 0, size: CGSize = CGSize(width: 0, height: 0)) {
        self.translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: centerX, constant: xOffest).isActive = true
        centerYAnchor.constraint(equalTo: centerY, constant: yOffset).isActive = true
        
        if size.width > 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height > 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    public func pinToViewSafeArea(view: UIView, padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding.top).isActive = true
        leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding.left).isActive = true
        trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: padding.right * -1).isActive = true
        bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: padding.bottom * -1).isActive = true
    }
    
    public var heightConstraint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .height && $0.relation == .equal
            })
        }
        set { setNeedsLayout() }
    }
    
    public var widthConstraint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .width && $0.relation == .equal
            })
        }
        set { setNeedsLayout() }

    }
    
}


//MARK:- CMTime

extension CMTime {
    var String: String {
        let secondsPlay = self.seconds
        if !secondsPlay.isNaN {
            let hours = Int(secondsPlay / 3600)
            let restTime = secondsPlay.truncatingRemainder(dividingBy: 3600)
            let minutes = Int(restTime / 60)
            let second = Int(restTime.truncatingRemainder(dividingBy: 60))
            if hours > 0 {
                return Swift.String(format: "%02d:%02d:%02d", arguments: [hours, minutes, second])
            } else {
                return Swift.String(format: "%02d:%02d", arguments: [minutes, second])
            }
        } else {
            return "00:00"
        }
        
        
    }
}

//MARK:- UIButton

extension UIButton {
    func fixGradiant() {
        // Add gradient layer
        let gradientLayer = CAGradientLayer()
        
        let color = UIColor(white: 0.2, alpha: 0.5)
        gradientLayer.colors = [UIColor.clear.cgColor, color.cgColor]
        gradientLayer.locations = [0.7, 1.2]
        gradientLayer.frame = CGRect(x: 8, y: 5, width: self.frame.size.width - 8, height: self.frame.size.height - 10)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

//MARK:- UIColor

extension UIColor {
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
}


// MARK: - UIImageView
extension UIImageView {
    
    public func fromURL(url: String) {
        
        self.image = nil
        
        guard let realUrl = URL(string: url) else {
            return
        }
        URLSession.shared.dataTask(with: realUrl) { (data, response, error) in
            
            
            if let error = error {
                print("error getting image: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    self.image = image
                }
            }
        }.resume()
    }
}
