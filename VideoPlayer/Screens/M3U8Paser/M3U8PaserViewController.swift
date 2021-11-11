//
//  M3U8PaserViewController.swift
//  VideoPlayer
//
//  Created by Yousef on 9/30/21.
//

import UIKit



class M3U8PaserViewController: UIViewController {
    
    lazy var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        
        collection.register(ResolutionViewCell.self, forCellWithReuseIdentifier: ResolutionViewCell.identifire)
        
        collection.delegate = self
        collection.dataSource = self
        
        return collection
    }()
    
    private var resolutions = [VPResolution]()

    lazy var excuteButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .systemGreen
        btn.setTitle("Excute", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 16
        btn.addTarget(self, action: #selector(excuteTapped(_:)), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "M3U8 Paser"
        
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(excuteButton)
        excuteButton.setConstraints(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.safeAreaLayoutGuide.leadingAnchor,
            trailing: view.safeAreaLayoutGuide.trailingAnchor,
            bottom: nil,
            padding: UIEdgeInsets(top: 20, left: 50, bottom: 0, right: 50),
            size: CGSize(width: 0, height: 50)
        )
        
        view.addSubview(collection)
        collection.setConstraints(
            top: excuteButton.bottomAnchor,
            leading: view.safeAreaLayoutGuide.leadingAnchor,
            trailing: view.safeAreaLayoutGuide.trailingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            padding: UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        )
        
        
    }
    
    @objc private func excuteTapped(_ sender: UIButton) {
        
        let urlString = "https://cdn01.scopesky.iq/share/uploads/movies/file/25831__e6c79a308e2590cb5dee39054a5b2334d371ccf65f37d936654484bc2ebaf16e_1632645366/25831__e6c79a308e2590cb5dee39054a5b2334d371ccf65f37d936654484bc2ebaf16e_1632645366.m3u8"
        
        let url = URL(string: urlString)!
//        M3u8Parser.getAppleResolutions(url: url) { [weak self] returned in
//            switch returned {
//
//            case .success(let data):
//                self?.resolutions = data
//                self?.collection.reloadData()
//            case .failure(_):
//                break
//            }
//
//        }
        
        resolutions = M3u8Parser.getAppleResolutions(url: url)
        collection.reloadData()
    }

}



extension M3U8PaserViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     
        return resolutions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ResolutionViewCell.identifire, for: indexPath) as! ResolutionViewCell
        cell.resolution = resolutions[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = ResolutionViewCell.height(for: resolutions[indexPath.row], width: collection.frame.size.width)
        return CGSize(width: collection.frame.size.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // launch video player
//        guard let window = view.window else { return }
//        CodersVideoPlayer.shared.play(window: window, media: [videos[indexPath.row]])
    }
    
    
    
}
