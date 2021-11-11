//
//  CodersAVMenuQualityOptionsCell.swift
//  autolayoutTransation
//
//  Created by Yousef on 2/7/21.
//

import UIKit

//MARK: - CodersAVMenuFourOptionsCell

protocol CodersAVMenuQualityOptionsCellDelegate {
    func qualityChanged(value: VPResolution, index: Int)
}

class CodersAVMenuQualityOptionsCell : CodersBaseAVMenuOptionsCell {
    
    var delegate: CodersAVMenuQualityOptionsCellDelegate?
    
    var item: CodersAVMenuQualityOptionsItem? {
        didSet {
            configure()
        }
    }
    
    private lazy var options: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let table = UICollectionView(frame: .zero, collectionViewLayout: layout)
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.translatesAutoresizingMaskIntoConstraints = false
        
        table.register(CodersAVMenuQualityOptionsItemCell.self, forCellWithReuseIdentifier: CodersAVMenuQualityOptionsItemCell.identifire)
        
        table.delegate = self
        table.dataSource = self
        
        return table
    }()
     
    
    override func configure() {
        guard let item = item else { return }
        lblTitle.text = item.title
        imgLogo.image = UIImage(named: item.imageName)
        options.reloadData()
        let indexPath = IndexPath(row: item.selectedOption, section: 0)
        options.selectItem(at: indexPath, animated: false, scrollPosition: .right)
//        print("item.selectedOption: \(item.selectedOption)")
//        options.cellForItem(at: indexPath)?.isSelected = true
    }
    
    override func additionalUIItem() {
        contentView.addSubview(options)
        
        NSLayoutConstraint.activate([
            options.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            options.leadingAnchor.constraint(equalTo: lblTitle.trailingAnchor, constant: 0),
            options.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            options.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
    }
    
    @objc func didChoose(_ button: UIButton) {
        
        
//        guard var item = item else { return }
//
//        firstOption.isChoosen = false
//        secondOption.isChoosen = false
//        ThirdOption.isChoosen = false
//        fourthOption.isChoosen = false
//
//        if button.tag == 1 {
//            item.selectedOption = 1
//            firstOption.isChoosen = true
//            delegate?.qualityChanged(value: item.resolutions[button.tag - 1])
//        } else if button.tag == 2 {
//            item.selectedOption = 2
//            secondOption.isChoosen = true
//            delegate?.qualityChanged(value: item.resolutions[button.tag - 1])
//        } else if button.tag == 3 {
//            item.selectedOption = 3
//            ThirdOption.isChoosen = true
//            delegate?.qualityChanged(value: item.resolutions[button.tag - 1])
//        } else if button.tag == 4 {
//            item.selectedOption = 4
//            fourthOption.isChoosen = true
//            delegate?.qualityChanged(value: item.resolutions[button.tag - 1])
//        }
    }
    
    override func updateFonts() {
        guard let item = item else {
            return
        }
        lblTitle.font = titleFont
        options.reloadData()
        let indexPath = IndexPath(row: item.selectedOption, section: 0)
        options.selectItem(at: indexPath, animated: false, scrollPosition: .right)
//        print("item.selectedOption: \(item.selectedOption)")
//        options.cellForItem(at: indexPath)?.isSelected = true
    }
    
}

extension CodersAVMenuQualityOptionsCell: UICollectionViewDataSource,
                                          UICollectionViewDelegate,
                                          UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let item = item {
            return item.resolutions.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let item = item {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CodersAVMenuQualityOptionsItemCell.identifire,
                                                          for: indexPath) as! CodersAVMenuQualityOptionsItemCell
            cell.item = item.resolutions[indexPath.row]
            cell.tintColor = tintColor
            cell.font = optionsFont
            cell.highLightedColor = .darkGray
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 46, height: contentView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = item else {
            return
        }
        delegate?.qualityChanged(value: item.resolutions[indexPath.row], index: indexPath.row)
    }
    
    
}


class CodersAVMenuQualityOptionsItemCell: UICollectionViewCell {
    static let identifire = "CodersAVMenuQualityOptionsItem"
    
    override var isSelected: Bool {
        didSet {
            updateUI()
        }
    }
    
    var font: UIFont = .systemFont(ofSize: 12) {
        didSet {
            titleLable.font = font
        }
    }
    
    var highLightedColor: UIColor = .gray {
        didSet {
            updateUI()
        }
    }
    
    var borderColor: UIColor = .gray {
        didSet {
            updateUI()
        }
    }
    
    var borderWidth: CGFloat = 1 {
        didSet {
            updateUI()
        }
    }
    
    var borderRadius: CGFloat = 10 {
        didSet {
            updateUI()
        }
    }
    
    var item: VPResolution? {
        didSet {
            configure()
        }
    }
    
    lazy var titleLable: UILabel = {
        let lbl = UILabel()
        lbl.font = self.font
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.backgroundColor = .purple
        lbl.textColor = .black
        lbl.clipsToBounds = true
        
        
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        contentView.addSubview(titleLable)
        
        NSLayoutConstraint.activate([
            titleLable.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            titleLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            titleLable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1),
            titleLable.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func configure() {
        guard let item = item else { return }
        titleLable.text = item.title
    }
    
    
    
    private func updateUI() {
        if isSelected {
            // set background color borders & border radius
            titleLable.backgroundColor = highLightedColor
            titleLable.layer.borderColor = borderColor.cgColor
            titleLable.layer.borderWidth = borderWidth
            titleLable.layer.cornerRadius = borderRadius
        } else {
            // clear background color borders & border radius
            titleLable.backgroundColor = .clear
            titleLable.layer.borderColor = UIColor.clear.cgColor
            titleLable.layer.borderWidth = 0
            titleLable.layer.cornerRadius = 0
        }
    }
}

