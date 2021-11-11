//
//  ResolutionViewCell.swift
//  VideoPlayer
//
//  Created by Yousef on 9/30/21.
//

import UIKit

class ResolutionViewCell: UICollectionViewCell {
    static let identifire = "ResolutionViewCell"
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = .black
        lbl.textAlignment = .left
        return lbl
    }()
    
    let uriLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.font = .systemFont(ofSize: 14, weight: .thin)
        lbl.textColor = .gray
        lbl.textAlignment = .left
        return lbl
    }()
    
    let container: UIView = {
        let view = UIView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    var resolution: VPResolution? {
        didSet {
            configure()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(container)
        container.setConstraints(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            bottom: contentView.bottomAnchor,
            padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        )
        
        container.addSubview(titleLabel)
        titleLabel.setConstraints(
            top: container.topAnchor,
            leading: container.leadingAnchor,
            trailing: nil,
            bottom: nil,
            padding: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0),
            size: CGSize(width: 75, height: 0)
        )
        
        container.addSubview(uriLabel)
        uriLabel.setConstraints(
            top: container.topAnchor,
            leading: titleLabel.trailingAnchor,
            trailing: container.trailingAnchor,
            bottom: container.bottomAnchor,
            padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        )
        
    }
    
    private func configure() {
        guard let resolution = resolution else { return }
        titleLabel.text = resolution.title
        uriLabel.text = resolution.URI
    }
    
    class func height(for viewModel: VPResolution, width: CGFloat) -> CGFloat {
        
        let padding: CGFloat = 16
        
        let label = UILabel()
        label.numberOfLines = 0
        
        
        
        
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.text = viewModel.URI
        let subtitleHeight = label.sizeThatFits(CGSize(width: width - 170, height: .infinity)).height
      
        let result = padding + subtitleHeight + padding
        return result
    }
    
    override func prepareForReuse() {
        titleLabel.text = ""
        uriLabel.text = ""
    }
    
}
