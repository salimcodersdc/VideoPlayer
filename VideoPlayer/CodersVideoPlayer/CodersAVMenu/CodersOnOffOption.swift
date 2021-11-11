//
//  CodersOnOffOption.swift
//  autolayoutTransation
//
//  Created by Yousef on 2/7/21.
//

import UIKit

class CodersOnOffOption: UIButton {
    
    /// UIColor setto background when this option selected
    var highLightedColor: UIColor = .darkGray {
        didSet {
            configure()
        }
    }
    
    /// UIColor setto background when this option selected
    var borderColor: UIColor = .darkGray {
        didSet {
            configure()
        }
    }
    
    /// indicator tells when the label is selected or not
    var isChoosen: Bool = false {
        didSet {
            configure()
        }
    }
    
    var borderWidth: CGFloat = 1 {
        didSet {
            configure()
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            
        }
    }
    
    var borderRadius: CGFloat = 10 {
        didSet {
            configure()
        }
    }
    
    //MARK: - initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        layer.masksToBounds = true
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        if isChoosen {
//            layer.cornerRadius = frame.height / 2
//        }
    }
    
    private func configure() {
        if isChoosen {
            // set background color borders & border radius
            backgroundColor = highLightedColor
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = borderWidth
            layer.cornerRadius = borderRadius
        } else {
            // clear background color borders & border radius
            backgroundColor = .clear
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
            layer.cornerRadius = 0
        }
    }
    
}
