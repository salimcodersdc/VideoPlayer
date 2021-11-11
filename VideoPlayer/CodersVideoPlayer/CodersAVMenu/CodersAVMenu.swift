//
//  CodersAVMenu.swift
//  autolayoutTransation
//
//  Created by Yousef on 2/7/21.
//

import UIKit


public protocol CodersAVMenuDelegate {
    func showPopupMenu()
    func hidePopupMenu()
    func itemSelected(_ item: CodersAVMenuItem)
    
    func qualityChanged(value: VPResolution, index: Int)
    func subtitleChanged(value: OnOff)
    func subtitleFontChanged(value: FontSize)
    func autoNextChanged(value: OnOff)
    func continueWatchingChanged(value: OnOff)
    func needReportVideo()
}

public class CodersAVMenu: UIView {
    
    private var parentView: UIWindow?
    
    public var color: UIColor = UIColor.white {
        didSet {
            tblSettings.backgroundColor = color
            bkView.backgroundColor = color
        }
    }
    
    public var underLineColor: UIColor = .black {
        didSet {
            tblSettings.reloadData()
        }
    }
    
    public var hasSeparator: Bool = true {
        didSet {
            tblSettings.reloadData()
        }
    }
    
    public var separatorColor: UIColor = .gray {
        didSet {
            tblSettings.reloadData()
        }
    }
    
    public var separatorHeight: CGFloat = 1 {
        didSet {
            tblSettings.reloadData()
        }
    }
    
    override public var tintColor: UIColor! {
        didSet {
            tblSettings.reloadData()
        }
    }
    
    public var foregroundColor: UIColor = UIColor.white {
        didSet {
            tblSettings.reloadData()
        }
    }
    
    public var titleFont: UIFont = .systemFont(ofSize: 14) {
        didSet {
            tblSettings.reloadData()
        }
    }
    
    public var optionsFont: UIFont = .systemFont(ofSize: 14) {
        didSet {
            tblSettings.reloadData()
        }
    }
    
    public var items: [CodersAVMenuItem] = [] {
        didSet {
            tblSettings.reloadData()
            modifyHeight()
        }
    }
    
    public var itemHieght: CGFloat = 60 {
        didSet {
            reArrange()
        }
    }
    
    
    
    let bkView: UIView = {
        let frm = UIView()
        frm.backgroundColor = .link
        frm.layer.shadowColor = UIColor.lightGray.cgColor
        frm.layer.shadowOpacity = 1
        frm.layer.shadowOffset = CGSize(width: 0, height: -3)
        frm.layer.shadowRadius = 3
        return frm
    }()
    
    let otherView: UIView = {
        let frm = UIView()
        frm.backgroundColor = .clear
        return frm
    }()
    
    private lazy var tblSettings: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let tbl = UICollectionView(frame: .zero, collectionViewLayout: layout)
        tbl.showsVerticalScrollIndicator = false
        tbl.showsHorizontalScrollIndicator = false
        tbl.backgroundColor = .white
        
        tbl.register(CodersAVMenuOneOptionsCell.self, forCellWithReuseIdentifier: CodersAVMenuOneOptionsCell.identifire)
        tbl.register(CodersAVMenuTowOptionsCell.self, forCellWithReuseIdentifier: CodersAVMenuTowOptionsCell.identifire)
        tbl.register(CodersAVMenuThreeOptionsCell.self, forCellWithReuseIdentifier: CodersAVMenuThreeOptionsCell.identifire)
        tbl.register(CodersAVMenuFourOptionsCell.self, forCellWithReuseIdentifier: CodersAVMenuFourOptionsCell.identifire)
        tbl.register(CodersAVMenuQualityOptionsCell.self, forCellWithReuseIdentifier: CodersAVMenuQualityOptionsCell.identifire)
        
        tbl.isUserInteractionEnabled = true
        tbl.delegate = self
        tbl.dataSource = self
        return tbl
    }()
    
//    var blurView: UIView?
    
    public var delegate: CodersAVMenuDelegate?
    
    public init(window: UIWindow) {
        self.parentView = window
        super.init(frame: window.frame)
        setupBackGround()
        setupViews()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupBackGround()
        setupViews()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    private func modifyHeight() {
        let height = CGFloat(items.count) * itemHieght
        tblSettings.heightConstraint?.constant = height
    }
    
    private func setupBackGround() {
        
        /*
         let scene = UIApplication.shared.connectedScenes.first
         guard let sd = (scene?.delegate as? SceneDelegate),
               let window = sd.window else { return }
         */
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(animateMenu(_:)))
        tapGesture.cancelsTouchesInView = false
        otherView.addGestureRecognizer(tapGesture)
        
        
//        if let parentView = parentView {
//            self.frame = parentView.frame
//            alpha = 0
//            backgroundColor = .clear //UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(animateMenu(_:)))
//            tapGesture.cancelsTouchesInView = false
//            addGestureRecognizer(tapGesture)
//
//            let bkViewGuesture = UITapGestureRecognizer(target: self, action: #selector(didTableTapped))
//            bkView.addGestureRecognizer(bkViewGuesture)
//            tapGesture.require(toFail: bkViewGuesture)
//        }
        
    }
    
    @objc func didTableTapped() {
        print("table tapped")
    }
    private func reArrange() {
        modifyHeight()
        tblSettings.reloadData()
    }
    
    @objc private func handleBlur() {
//        blurView = UIView()
//        let blurEffect = UIBlurEffect(style: .light)
//        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
//        blurredEffectView.frame = bounds
//        blurredEffectView.alpha = 0.8
//        blurView?.addSubview(blurredEffectView)
//        blurView?.frame = bounds
//        addSubview(blurView!)
    }
    
    
    
    public func showSelf() {
//        tblSettings.heightConstraint?.constant = 0
//        let height = CGFloat(items.count) * itemHieght
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 1
        }) { (res) in
//            if res {
//                UIView.animate(withDuration: 0.8, delay: 0, options: .transitionCurlUp, animations: {
//                    self.tblSettings.heightConstraint?.constant = height
//                })
//            }
        }
    }
    
    private func setupViews() {
        handleBlur()
        addSubview(bkView)
        addSubview(tblSettings)
        addSubview(otherView)
        
        tblSettings.setConstraints(top: nil,
                                   leading: safeAreaLayoutGuide.leadingAnchor,
                                   trailing: safeAreaLayoutGuide.trailingAnchor,
                                   bottom: safeAreaLayoutGuide.bottomAnchor,
                                   size: CGSize(width: 0, height: 50))
        
        bkView.setConstraints(top: tblSettings.topAnchor,
                              leading: leadingAnchor,
                              trailing: trailingAnchor,
                              bottom: bottomAnchor)
        
        otherView.setConstraints(top: self.topAnchor,
                                 leading: self.leadingAnchor,
                                 trailing: self.trailingAnchor,
                                 bottom: bkView.topAnchor)
        
        bringSubviewToFront(tblSettings)
        
        window?.addSubview(self)
    }
    
    @objc private func animateMenu(_ guesture: UITapGestureRecognizer) {
        
       
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.tblSettings.heightConstraint?.constant = 0
        }) { (res) in
            if res {
                UIView.animate(withDuration: 0.8, delay: 0, options: .transitionCurlUp, animations: {
                    self.alpha = 0
                }) { (_) in
                    self.delegate?.hidePopupMenu()
                }
            }
        }
        
    }
    
}

extension CodersAVMenu: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = items[indexPath.row]
        switch item {
        
        case .towOptions(model: let model):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CodersAVMenuTowOptionsCell.identifire, for: indexPath) as! CodersAVMenuTowOptionsCell
            cell.item = model
            cell.color = foregroundColor
            cell.tintColor = tintColor
            cell.titleFont = titleFont
            cell.optionsFont = optionsFont
            cell.isUnderLine = true
            cell.underLineHeight = 1
            cell.underLineColor = underLineColor
            cell.delegate = self
            return cell
        case .threeOptions(model: let model):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CodersAVMenuThreeOptionsCell.identifire, for: indexPath) as! CodersAVMenuThreeOptionsCell
            cell.item = model
            cell.color = foregroundColor
            cell.tintColor = tintColor
            cell.titleFont = titleFont
            cell.optionsFont = optionsFont
            cell.isUnderLine = true
            cell.underLineHeight = 1
            cell.underLineColor = underLineColor
            cell.delegate = self
            return cell
        case .oneOption(model: let model):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CodersAVMenuOneOptionsCell.identifire, for: indexPath) as! CodersAVMenuOneOptionsCell
            cell.item = model
            cell.color = foregroundColor
            cell.tintColor = tintColor
            cell.titleFont = titleFont
            cell.optionsFont = optionsFont
            cell.isUnderLine = true
            cell.underLineHeight = 1
            cell.underLineColor = underLineColor
            return cell
        case .fourOptions(model: let model):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CodersAVMenuFourOptionsCell.identifire, for: indexPath) as! CodersAVMenuFourOptionsCell
            cell.item = model
            cell.color = foregroundColor
            cell.tintColor = tintColor
            cell.titleFont = titleFont
            cell.optionsFont = optionsFont
            cell.isUnderLine = true
            cell.underLineHeight = 1
            cell.underLineColor = underLineColor
            cell.delegate = self
            return cell
        case .quality(model: let model):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CodersAVMenuQualityOptionsCell.identifire, for: indexPath) as! CodersAVMenuQualityOptionsCell
//            print("model: \(model)")
            cell.item = model
            cell.color = foregroundColor
            cell.tintColor = tintColor
            cell.titleFont = titleFont
            cell.optionsFont = optionsFont
            cell.isUnderLine = true
            cell.underLineHeight = 1
            cell.underLineColor = underLineColor
            cell.delegate = self
            return cell
        }
        
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: itemHieght)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        switch items[indexPath.row] {
        case .oneOption(model: _):
            delegate?.needReportVideo()
        default:
            break
        }
    }
    
}

extension CodersAVMenu: CodersAVMenuFourOptionsCellDelegate,
                        CodersAVMenuThreeOptionsCellDelegate,
                        CodersAVMenuTowOptionsCellDelegate,
                        CodersAVMenuQualityOptionsCellDelegate {
    func qualityChanged(value: VPResolution, index: Int) {
        delegate?.qualityChanged(value: value, index: index)
    }
    
    
    // CodersAVMenuFourOptionsCellDelegate
    func qualityChanged(key: CodersAVMenuFourOptionsItemKey, value: Double) {
        switch key {
        
        case .quality:
//            delegate?.qualityChanged(value: value)
            break
        }
    }
    
    // CodersAVMenuThreeOptionsCellDelegate
    func fontSizeChanged(key: CodersAVMenuThreeOptionsItemKey, value: FontSize) {
        switch key {
        
        case .subtitleFont:
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.subtitleFontChanged(value: value)
            }
        }
    }
    
    // CodersAVMenuTowOptionsCellDelegate
    func keyHasChanged(key: CodersAVMenuTowOptionsItemKey, value: OnOff) {
        switch key {
        case .subtitle:
            delegate?.subtitleChanged(value: value)
        case .autoNext:
            delegate?.autoNextChanged(value: value)
        case .continueWatching:
            delegate?.continueWatchingChanged(value: value)
        }
    }
    
    
}
