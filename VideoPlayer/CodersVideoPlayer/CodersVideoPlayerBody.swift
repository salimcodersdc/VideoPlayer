//
//  CodersVideoPlayerBody.swift
//  autolayoutTransation
//
//  Created by Yousef on 2/4/21.
//

import UIKit
import Combine

class CodersVideoPlayerBody: UIView {
    
//    private let backwardImage: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemYellow
//        return view
//    }()
    
    private let loggerLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let backwardImage: VPShimmerImage = {
        let img = VPShimmerImage()
        img.backgroundColor = .clear
        let image = UIImage(systemName: "forward.fill")
        img.image = image
        img.darkColor = UIColor.init(white: 0.1, alpha: 0.5)
        img.duration = 1
        img.lightColor = .white
        return img
    }()
    
    private var cancellables = Set<AnyCancellable>()
    private var logger = VideoLogger.shared
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        addSubripers()
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeSubcribers() {
        cancellables.forEach({$0.cancel()})
    }
    
    private func addSubripers() {
        logger.text
            .sink { [unowned self] value in
                DispatchQueue.main.async {
                    loggerLabel.text = value
                    loggerLabel.sizeToFit()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupViews() {
        backgroundColor = .white
        addSubview(loggerLabel)

        loggerLabel.setConstraints(top: topAnchor,
                                   leading: leadingAnchor,
                                   trailing: nil,
                                   bottom: nil,
                                   padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 0)
        )
    }
    
}
