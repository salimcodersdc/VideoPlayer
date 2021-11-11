//
//  SeriesCollectionCell.swift
//  VideoPlayer
//
//  Created by Yousef on 11/10/21.
//

import UIKit

class SeriesCollectionCell: UICollectionViewCell {
    static let identifire = "SeriesCollectionCell"
    
    let lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.numberOfLines = 0
        lbl.font = .boldSystemFont(ofSize: 20)
        lbl.sizeToFit()
        lbl.tag = 555
        return lbl
    }()
    
    let lblDiscreption: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = .black
        lbl.numberOfLines = 0
        lbl.sizeToFit()
        lbl.tag = 444
        return lbl
    }()
    
    let logo: UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        img.tintColor = .black
        
        return img
    }()
    
    var video: SerieMedia? {
        didSet {
            configure()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        
        backgroundColor = .white
        let padding: CGFloat = 16
        
        let container = UIView()
        container.backgroundColor = .lightGray
        container.layer.cornerRadius = 16
        
        contentView.addSubview(container)
        container.setConstraints(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            bottom: contentView.bottomAnchor,
            padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        )
        
        container.addSubview(lblTitle)
        container.addSubview(logo)
        container.addSubview(lblDiscreption)
        
        logo.setConstraints(top: container.topAnchor,
                            leading: container.leadingAnchor,
                            trailing: nil,
                            bottom: container.bottomAnchor,
                            padding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: 0),
                            size: CGSize(width: 100, height: 0))
        
        lblTitle.setConstraints(top: container.topAnchor,
                                leading: logo.trailingAnchor,
                                trailing: container.trailingAnchor,
                                bottom: nil,
                                padding: UIEdgeInsets(top: padding, left: padding, bottom: 0, right: padding),
                                size: CGSize(width: 0, height: 44))
        
        lblDiscreption.setConstraints(top: lblTitle.bottomAnchor,
                                      leading: logo.trailingAnchor,
                                      trailing: container.trailingAnchor,
                                      bottom: container.bottomAnchor,
                                      padding: UIEdgeInsets(top: 0, left: padding, bottom: padding, right: padding))
                                
    }
    
    func imageFrame() -> CGRect {
        return .zero
    }
    
    private func configure() {
        guard let clip = video else { return }
        
        lblTitle.text = clip.title
        lblDiscreption.text = clip.details
//        lblTitle.sizeToFit()
//        lblDiscreption.sizeToFit()
        logo.image = UIImage(systemName: clip.thumbnail)
    }
    
    class func height(for viewModel: M3u8Media, width: CGFloat) -> CGFloat {
        
        let padding: CGFloat = 16
        
        let label = UILabel()
        label.numberOfLines = 0
        
//        label.font = .boldSystemFont(ofSize: 20)
//        label.text = viewModel.title
//        let titleHeight = label.sizeThatFits(CGSize(width: width - (2 * padding), height: .infinity)).height
        
        
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.text = viewModel.details
        let subtitleHeight = label.sizeThatFits(CGSize(width: width - 200, height: .infinity)).height
      
        let result = padding + 44 + padding + subtitleHeight + padding
        return result
    }
    
    override func prepareForReuse() {
        lblTitle.text = ""
        lblDiscreption.text = ""
        logo.image = nil
    }
}
