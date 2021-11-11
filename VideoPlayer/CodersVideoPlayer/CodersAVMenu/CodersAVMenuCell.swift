//
//  CodersAVMenuCell.swift
//  autolayoutTransation
//
//  Created by Yousef on 2/7/21.
//

import UIKit

/*
 
 open class BaseCell: UICollectionViewCell {
     
     public override init(frame: CGRect) {
         super.init(frame: frame)
         
         setupViews()
     }
     
     open override var isSelected: Bool {
         didSet {
             configureSelection()
         }
     }
     
     required public init?(coder: NSCoder) {
         super.init(coder: coder)
         
         setupViews()
     }
     
     open func setupViews() {
         
     }
     
     open func configureSelection() {
         
     }
     
 }

 */

public class CodersBaseAVMenuOptionsCell: UICollectionViewCell {
    
    
    public var titleFont: UIFont = .systemFont(ofSize: 15) {
        didSet {
            updateFonts()
        }
    }
    
    public var optionsFont: UIFont = .systemFont(ofSize: 12) {
        didSet {
            updateFonts()
        }
    }
    
    public var isUnderLine: Bool = true {
        didSet {
            addUnderLine()
        }
    }
    
    public var underLineColor: UIColor = .gray {
        didSet {
            underLine.backgroundColor = underLineColor
        }
    }
    
    public var underLineHeight: CGFloat = 1 {
        didSet {
            underLine.heightConstraint?.constant = underLineHeight
        }
    }
    
    public var color: UIColor = .black {
        didSet {
            lblTitle.textColor = color
        }
    }
    
    public var imageWidth: CGFloat = 24 {
        didSet {

        }
    }
    
    override public var tintColor: UIColor! {
        didSet {
            imgLogo.tintColor = self.tintColor
        }
    }
    
    public static var identifire: String {
        return NSStringFromClass(self)
    }
    
    let padding: CGFloat = 12
    let buttonHeight: CGFloat = 20
    let buttonWidth: CGFloat = 46
    
    internal let lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "item cell"
        return lbl
    }()
    
    internal let imgLogo: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    private let underLine: UIView = {
        let frm = UIView()
        frm.backgroundColor = .gray
        return frm
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    open override var isSelected: Bool {
        didSet {
            configureSelection()
        }
    }
    
    private func configureSelection() {
        
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupViews()
    }
    
    private func addUnderLine() {
        if isUnderLine {
            self.addSubview(underLine)
            underLine.setConstraints(top: nil,
                                     leading: contentView.leadingAnchor,
                                     trailing: contentView.trailingAnchor,
                                     bottom: contentView.bottomAnchor,
                                     padding: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12),
                                     size: CGSize(width: 0, height: underLineHeight))
        } else {
            underLine.removeFromSuperview()
        }
    }
    
    func configure() {
       
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let tmp: CGFloat = (self.frame.size.width / 2) - (padding * 2) - imageWidth
        if tmp > 50 {
            lblTitle.widthConstraint?.constant = tmp
        }
    }
    
    private func setupViews() {
//        backgroundColor = .purple
        contentView.addSubview(lblTitle)
        contentView.addSubview(imgLogo)
        
//        imgLogo.setConstraints(top: contentView.topAnchor,
//                               leading: contentView.leadingAnchor,
//                               trailing: nil,
//                               bottom: contentView.bottomAnchor,
//                               padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0),
//                               size: CGSize(width: 40, height: 0))
        
        imgLogo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imgLogo.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            imgLogo.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            imgLogo.widthAnchor.constraint(equalToConstant: imageWidth),
            imgLogo.heightAnchor.constraint(equalToConstant: imageWidth)
        ])
        
        lblTitle.setConstraints(top: contentView.topAnchor,
                                leading: imgLogo.trailingAnchor,
                                trailing: nil,
                                bottom: contentView.bottomAnchor,
                                padding: UIEdgeInsets(top: 0, left: padding, bottom: 0, right: 0),
                                size: CGSize(width: 40, height: 0))
        addUnderLine()
        additionalUIItem()
    }
    
    func additionalUIItem() { }
    
    func updateFonts() {
        lblTitle.font = titleFont
    }
    
}

