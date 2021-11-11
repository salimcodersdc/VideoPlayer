//
//  CodersAVMenuOtherCells.swift
//  autolayoutTransation
//
//  Created by Yousef on 2/7/21.
//

import UIKit

//MARK: - CodersAVMenuOneOptionsCell
class CodersAVMenuOneOptionsCell : CodersBaseAVMenuOptionsCell {
    
    
    var item: CodersAVMenuOneOptionsItem? {
        didSet {
            configure()
        }
    }
    
    override func configure() {
        guard let item = item else { return }
        lblTitle.text = item.key.title
        imgLogo.image = UIImage(named: item.key.imageName)
    }
}

//MARK: - CodersAVMenuTowOptionsCellDelegate
protocol CodersAVMenuTowOptionsCellDelegate {
    func keyHasChanged(key: CodersAVMenuTowOptionsItemKey, value: OnOff)
}


//MARK: - CodersAVMenuTowOptionsCell

class CodersAVMenuTowOptionsCell : CodersBaseAVMenuOptionsCell {
    
    var delegate: CodersAVMenuTowOptionsCellDelegate?
    
    var item: CodersAVMenuTowOptionsItem? {
        didSet {
            configure()
        }
    }
    
    private lazy var firstOption: CodersOnOffOption = {
        let lbl = CodersOnOffOption()
        lbl.backgroundColor = .clear
        lbl.tag = 1
        lbl.setTitleColor(.black, for: .normal)
        lbl.titleLabel?.textAlignment = .center
        lbl.addTarget(self, action: #selector(didChoose(_:)), for: .touchUpInside)
        return lbl
    }()
    
    private lazy var secondOption: CodersOnOffOption = {
        let lbl = CodersOnOffOption()
        lbl.backgroundColor = .clear
        lbl.tag = 2
        lbl.setTitleColor(.black, for: .normal)
        lbl.titleLabel?.textAlignment = .center
        lbl.addTarget(self, action: #selector(didChoose(_:)), for: .touchUpInside)
        return lbl
    }()
    
    override func configure() {
        guard let item = item else { return }
        lblTitle.text = item.key.title
        imgLogo.image = UIImage(named: item.key.imageName)
        firstOption.setTitle(item.firstOption, for: .normal)
        secondOption.setTitle(item.secondOption, for: .normal)
        if item.selectedOption == 1 {
            firstOption.isChoosen = true
        } else if item.selectedOption == 2 {
            secondOption.isChoosen = true
        }
    }
    
    override func additionalUIItem() {
        contentView.addSubview(firstOption)
        contentView.addSubview(secondOption)
        
//        firstOption.setConstraints(top: contentView.topAnchor,
//                                   leading: lblTitle.trailingAnchor,
//                                   trailing: nil,
//                                   bottom: contentView.bottomAnchor,
//                                   padding: UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0),
//                                   size: CGSize(width: 40, height: 0))
//
//        secondOption.setConstraints(top: contentView.topAnchor,
//                                    leading: firstOption.trailingAnchor,
//                                    trailing: nil,
//                                    bottom: contentView.bottomAnchor,
//                                    padding: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 0),
//                                    size: CGSize(width: 40, height: 0))
        
        firstOption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firstOption.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            firstOption.leadingAnchor.constraint(equalTo: lblTitle.trailingAnchor, constant: 0),
            firstOption.heightAnchor.constraint(equalToConstant: buttonHeight),
            firstOption.widthAnchor.constraint(equalToConstant: buttonWidth)
        ])
        firstOption.borderRadius = buttonHeight / 2
        
        secondOption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secondOption.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            secondOption.leadingAnchor.constraint(equalTo: firstOption.trailingAnchor, constant: padding),
            secondOption.heightAnchor.constraint(equalToConstant: buttonHeight),
            secondOption.widthAnchor.constraint(equalToConstant: buttonWidth)
        ])
        secondOption.borderRadius = buttonHeight / 2
        
    }
    
    @objc func didChoose(_ button: UIButton) {
        guard var item = item else { return }
        firstOption.isChoosen = false
        secondOption.isChoosen = false
        
        if button.tag == 1 {
            item.selectedOption = 1
            firstOption.isChoosen = true
            delegate?.keyHasChanged(key: item.key, value: .on)
        } else if button.tag == 2 {
            item.selectedOption = 2
            secondOption.isChoosen = true
            delegate?.keyHasChanged(key: item.key, value: .off)
        }
        
//        refreshButtons()
    }
    
    private func refreshButtons() {
        guard let item = item else { return }
        firstOption.isChoosen = false
        secondOption.isChoosen = false
        
        
        if item.selectedOption == 1 {
            firstOption.isChoosen = true
        } else if item.selectedOption == 2 {
            secondOption.isChoosen = true
        }
    }
    
    override func updateFonts() {
        lblTitle.font = titleFont
        firstOption.titleLabel?.font = optionsFont
        secondOption.titleLabel?.font = optionsFont
    }
    
}

//MARK: - CodersAVMenuThreeOptionsCellDelegate
protocol CodersAVMenuThreeOptionsCellDelegate {
    func fontSizeChanged(key: CodersAVMenuThreeOptionsItemKey, value: FontSize)
}

//MARK: - CodersAVMenuThreeOptionsCell

class CodersAVMenuThreeOptionsCell : CodersBaseAVMenuOptionsCell {
    
    var delegate: CodersAVMenuThreeOptionsCellDelegate?
    
    var item: CodersAVMenuThreeOptionsItem? {
        didSet {
            configure()
        }
    }
    
    private lazy var firstOption: CodersOnOffOption = {
        let lbl = CodersOnOffOption()
        lbl.backgroundColor = .clear
        lbl.tag = 1
        lbl.setTitleColor(.black, for: .normal)
        lbl.titleLabel?.textAlignment = .center
        lbl.addTarget(self, action: #selector(didChoose(_:)), for: .touchUpInside)
        return lbl
    }()
    
    private lazy var secondOption: CodersOnOffOption = {
        let lbl = CodersOnOffOption()
        lbl.backgroundColor = .clear
        lbl.tag = 2
        lbl.setTitleColor(.black, for: .normal)
        lbl.titleLabel?.textAlignment = .center
        lbl.addTarget(self, action: #selector(didChoose(_:)), for: .touchUpInside)
        return lbl
    }()
    
    private lazy var ThirdOption: CodersOnOffOption = {
        let lbl = CodersOnOffOption()
        lbl.backgroundColor = .clear
        lbl.tag = 3
        lbl.setTitleColor(.black, for: .normal)
        lbl.titleLabel?.textAlignment = .center
        lbl.addTarget(self, action: #selector(didChoose(_:)), for: .touchUpInside)
        return lbl
    }()
    
    override func configure() {
        guard let item = item else { return }
        lblTitle.text = item.key.title
        imgLogo.image = UIImage(named: item.key.imageName)
        firstOption.setTitle(item.firstOption, for: .normal)
        secondOption.setTitle(item.secondOption, for: .normal)
        ThirdOption.setTitle(item.thirdOption, for: .normal)
        if item.selectedOption == 1 {
            firstOption.isChoosen = true
        } else if item.selectedOption == 2 {
            secondOption.isChoosen = true
        } else if item.selectedOption == 3 {
            ThirdOption.isChoosen = true
        }
    }
    
    override func additionalUIItem() {
        contentView.addSubview(firstOption)
        contentView.addSubview(secondOption)
        contentView.addSubview(ThirdOption)
        
//        firstOption.setConstraints(top: contentView.topAnchor,
//                                   leading: lblTitle.trailingAnchor,
//                                   trailing: nil,
//                                   bottom: contentView.bottomAnchor,
//                                   padding: UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0),
//                                   size: CGSize(width: 40, height: 0))
//
//        secondOption.setConstraints(top: contentView.topAnchor,
//                                    leading: firstOption.trailingAnchor,
//                                    trailing: nil,
//                                    bottom: contentView.bottomAnchor,
//                                    padding: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 0),
//                                    size: CGSize(width: 60, height: 0))
//
//        ThirdOption.setConstraints(top: contentView.topAnchor,
//                                   leading: secondOption.trailingAnchor,
//                                   trailing: nil,
//                                   bottom: contentView.bottomAnchor,
//                                   padding: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 0),
//                                   size: CGSize(width: 40, height: 0))
        firstOption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firstOption.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            firstOption.leadingAnchor.constraint(equalTo: lblTitle.trailingAnchor, constant: 0),
            firstOption.heightAnchor.constraint(equalToConstant: buttonHeight),
            firstOption.widthAnchor.constraint(equalToConstant: buttonWidth)
        ])
        firstOption.borderRadius = buttonHeight / 2
        
        secondOption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secondOption.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            secondOption.leadingAnchor.constraint(equalTo: firstOption.trailingAnchor, constant: padding),
            secondOption.heightAnchor.constraint(equalToConstant: buttonHeight),
            secondOption.widthAnchor.constraint(equalToConstant: buttonWidth)
        ])
        secondOption.borderRadius = buttonHeight / 2
        
        ThirdOption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ThirdOption.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            ThirdOption.leadingAnchor.constraint(equalTo: secondOption.trailingAnchor, constant: padding),
            ThirdOption.heightAnchor.constraint(equalToConstant: buttonHeight),
            ThirdOption.widthAnchor.constraint(equalToConstant: buttonWidth)
        ])
        ThirdOption.borderRadius = buttonHeight / 2
        
    }
    
    @objc func didChoose(_ button: UIButton) {
        guard var item = item else { return }
        firstOption.isChoosen = false
        secondOption.isChoosen = false
        ThirdOption.isChoosen = false
        
        if button.tag == 1 {
            item.selectedOption = 1
            firstOption.isChoosen = true
            delegate?.fontSizeChanged(key: item.key, value: .small)
        } else if button.tag == 2 {
            item.selectedOption = 2
            secondOption.isChoosen = true
            delegate?.fontSizeChanged(key: item.key, value: .medium)
        } else if button.tag == 3 {
            item.selectedOption = 3
            ThirdOption.isChoosen = true
            delegate?.fontSizeChanged(key: item.key, value: .larg)
        }
//        refreshButtons()
        
    }
    
    private func refreshButtons() {
        guard let item = item else { return }
        firstOption.isChoosen = false
        secondOption.isChoosen = false
        ThirdOption.isChoosen = false
        
        
        if item.selectedOption == 1 {
            firstOption.isChoosen = true
        } else if item.selectedOption == 2 {
            secondOption.isChoosen = true
        } else if item.selectedOption == 3 {
            ThirdOption.isChoosen = true
        }
    }
    
    override func updateFonts() {
        lblTitle.font = titleFont
        firstOption.titleLabel?.font = optionsFont
        secondOption.titleLabel?.font = optionsFont
        ThirdOption.titleLabel?.font = optionsFont
    }
    
}

//MARK: - CodersAVMenuFourOptionsCellDelegate

protocol CodersAVMenuFourOptionsCellDelegate {
    func qualityChanged(key: CodersAVMenuFourOptionsItemKey, value: Double)
}

//MARK: - CodersAVMenuFourOptionsCell

class CodersAVMenuFourOptionsCell : CodersBaseAVMenuOptionsCell {
    
    var delegate: CodersAVMenuFourOptionsCellDelegate?
    
    var item: CodersAVMenuFourOptionsItem? {
        didSet {
            configure()
        }
    }
    
    private lazy var firstOption: CodersOnOffOption = {
        let lbl = CodersOnOffOption()
        lbl.backgroundColor = .clear
        lbl.tag = 1
        lbl.setTitleColor(.black, for: .normal)
        lbl.titleLabel?.textAlignment = .center
        lbl.addTarget(self, action: #selector(didChoose(_:)), for: .touchUpInside)
        return lbl
    }()
    
    private lazy var secondOption: CodersOnOffOption = {
        let lbl = CodersOnOffOption()
        lbl.backgroundColor = .clear
        lbl.tag = 2
        lbl.setTitleColor(.black, for: .normal)
        lbl.titleLabel?.textAlignment = .center
        lbl.addTarget(self, action: #selector(didChoose(_:)), for: .touchUpInside)
        return lbl
    }()
    
    private lazy var ThirdOption: CodersOnOffOption = {
        let lbl = CodersOnOffOption()
        lbl.backgroundColor = .clear
        lbl.tag = 3
        lbl.setTitleColor(.black, for: .normal)
        lbl.titleLabel?.textAlignment = .center
        lbl.addTarget(self, action: #selector(didChoose(_:)), for: .touchUpInside)
        return lbl
    }()
    
    private lazy var fourthOption: CodersOnOffOption = {
        let lbl = CodersOnOffOption()
        lbl.backgroundColor = .clear
        lbl.tag = 4
        lbl.setTitleColor(.black, for: .normal)
        lbl.titleLabel?.textAlignment = .center
        lbl.addTarget(self, action: #selector(didChoose(_:)), for: .touchUpInside)
        return lbl
    }()
    
    
    
    override func configure() {
        guard let item = item else { return }
        lblTitle.text = item.key.title
        imgLogo.image = UIImage(named: item.key.imageName)
        firstOption.setTitle(item.firstOption, for: .normal)
        secondOption.setTitle(item.secondOption, for: .normal)
        ThirdOption.setTitle(item.thirdOption, for: .normal)
        fourthOption.setTitle(item.fourthOption, for: .normal)
        
        refreshButtons()
    }
    
    private func refreshButtons() {
        guard let item = item else { return }
        firstOption.isChoosen = false
        secondOption.isChoosen = false
        ThirdOption.isChoosen = false
        fourthOption.isChoosen = false
        
        
        if item.selectedOption == 1 {
            firstOption.isChoosen = true
        } else if item.selectedOption == 2 {
            secondOption.isChoosen = true
        } else if item.selectedOption == 3 {
            ThirdOption.isChoosen = true
        } else if item.selectedOption == 4 {
            fourthOption.isChoosen = true
        }
    }
    
    override func additionalUIItem() {
        contentView.addSubview(firstOption)
        contentView.addSubview(secondOption)
        contentView.addSubview(ThirdOption)
        contentView.addSubview(fourthOption)
        
//        firstOption.setConstraints(top: contentView.topAnchor,
//                                   leading: lblTitle.trailingAnchor,
//                                   trailing: nil,
//                                   bottom: contentView.bottomAnchor,
//                                   padding: UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0),
//                                   size: CGSize(width: 46, height: 0))
        firstOption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firstOption.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            firstOption.leadingAnchor.constraint(equalTo: lblTitle.trailingAnchor, constant: 0),
            firstOption.heightAnchor.constraint(equalToConstant: buttonHeight),
            firstOption.widthAnchor.constraint(equalToConstant: buttonWidth)
        ])
        firstOption.borderRadius = buttonHeight / 2
        
        
//        secondOption.setConstraints(top: contentView.topAnchor,
//                                    leading: firstOption.trailingAnchor,
//                                    trailing: nil,
//                                    bottom: contentView.bottomAnchor,
//                                    padding: UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 0),
//                                    size: CGSize(width: 46, height: 0))
        
        secondOption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secondOption.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            secondOption.leadingAnchor.constraint(equalTo: firstOption.trailingAnchor, constant: 0),
            secondOption.heightAnchor.constraint(equalToConstant: buttonHeight),
            secondOption.widthAnchor.constraint(equalToConstant: buttonWidth)
        ])
        secondOption.borderRadius = buttonHeight / 2
        
//        ThirdOption.setConstraints(top: contentView.topAnchor,
//                                   leading: secondOption.trailingAnchor,
//                                   trailing: nil,
//                                   bottom: contentView.bottomAnchor,
//                                   padding: UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 0),
//                                   size: CGSize(width: 46, height: 0))
        
        ThirdOption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ThirdOption.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            ThirdOption.leadingAnchor.constraint(equalTo: secondOption.trailingAnchor, constant: 0),
            ThirdOption.heightAnchor.constraint(equalToConstant: buttonHeight),
            ThirdOption.widthAnchor.constraint(equalToConstant: buttonWidth)
        ])
        ThirdOption.borderRadius = buttonHeight / 2
        
//        FourthOption.setConstraints(top: contentView.topAnchor,
//                                   leading: ThirdOption.trailingAnchor,
//                                   trailing: nil,
//                                   bottom: contentView.bottomAnchor,
//                                   padding: UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 0),
//                                   size: CGSize(width: 46, height: 0))
        
        fourthOption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fourthOption.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            fourthOption.leadingAnchor.constraint(equalTo: ThirdOption.trailingAnchor, constant: 0),
            fourthOption.heightAnchor.constraint(equalToConstant: buttonHeight),
            fourthOption.widthAnchor.constraint(equalToConstant: buttonWidth)
        ])
        fourthOption.borderRadius = buttonHeight / 2
    }
    
    @objc func didChoose(_ button: UIButton) {
        guard var item = item else { return }
        
        firstOption.isChoosen = false
        secondOption.isChoosen = false
        ThirdOption.isChoosen = false
        fourthOption.isChoosen = false
        
        if button.tag == 1 {
            item.selectedOption = 1
            firstOption.isChoosen = true
            delegate?.qualityChanged(key: item.key, value: 0)
        } else if button.tag == 2 {
            item.selectedOption = 2
            secondOption.isChoosen = true
            delegate?.qualityChanged(key: item.key, value: 0)
        } else if button.tag == 3 {
            item.selectedOption = 3
            ThirdOption.isChoosen = true
            delegate?.qualityChanged(key: item.key, value: 0)
        } else if button.tag == 4 {
            item.selectedOption = 4
            fourthOption.isChoosen = true
            delegate?.qualityChanged(key: item.key, value: 0)
        }
    }
    
    override func updateFonts() {
        lblTitle.font = titleFont
        firstOption.titleLabel?.font = optionsFont
        secondOption.titleLabel?.font = optionsFont
        ThirdOption.titleLabel?.font = optionsFont
        fourthOption.titleLabel?.font = optionsFont
    }
    
}

