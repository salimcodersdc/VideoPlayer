//
//  ViewController.swift
//  VideoPlayer
//
//  Created by Yousef on 9/29/21.
//

import UIKit
import AVKit

class ViewController: UIViewController, CodersVideoPlayerContainer {
    
    lazy var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        
        collection.register(VideoCollectionCell.self, forCellWithReuseIdentifier: VideoCollectionCell.identifire)
        
        collection.delegate = self
        collection.dataSource = self
        
        return collection
    }()
    
    lazy var seriesCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        
        collection.register(SeriesCollectionCell.self, forCellWithReuseIdentifier: SeriesCollectionCell.identifire)
        
        collection.delegate = self
        collection.dataSource = self
        
        return collection
    }()
    
    let moviesLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.numberOfLines = 0
        lbl.font = .boldSystemFont(ofSize: 20)
        lbl.text = "Movies"
        return lbl
    }()
    
    let seriesLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.numberOfLines = 0
        lbl.font = .boldSystemFont(ofSize: 20)
        lbl.text = "Series"
        return lbl
    }()
    
    private var videos = [M3u8Media]()
    private var series = [SerieMedia]()
    var player: CodersVideoPlayer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        title = "Videos List"
        
        addNavBarButtons()
        addCollection()
        fetchData()
    }
    
    private func fetchData() {
        VideoProvider.allVideos { [weak self] returned in
            self?.videos = returned
            self?.collection.reloadData()
            
//            self?.series.append(SerieMedi)
            let serieMedia = SerieMedia(
                title: "Channels",
                details: "Tv Channel List",
                thumbnail: "tv",
                movies: returned
            )
            self?.series.append(serieMedia)
        }
    }
    
    private func addNavBarButtons() {
        let btn = UIBarButtonItem(title: "Parser", style: .plain, target: self, action: #selector(m3u8ParserTapped(_:)))
        
        navigationItem.rightBarButtonItem = btn
    }

    private func addCollection() {
        
        view.addSubview(seriesLabel)
        seriesLabel.setConstraints(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.safeAreaLayoutGuide.leadingAnchor,
            trailing: view.safeAreaLayoutGuide.trailingAnchor,
            bottom: nil,
            padding: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10),
            size: CGSize(width: 0, height: 20))
        
        view.addSubview(seriesCollection)
        seriesCollection.setConstraints(
            top: seriesLabel.bottomAnchor,
            leading: view.safeAreaLayoutGuide.leadingAnchor,
            trailing: view.safeAreaLayoutGuide.trailingAnchor,
            bottom: nil,
            padding: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10),
            size: CGSize(width: 0, height: UIScreen.main.bounds.height * 0.25))
        
        view.addSubview(moviesLabel)
        moviesLabel.setConstraints(
            top: seriesCollection.bottomAnchor,
            leading: view.safeAreaLayoutGuide.leadingAnchor,
            trailing: view.safeAreaLayoutGuide.trailingAnchor,
            bottom: nil,
            padding: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10),
            size: CGSize(width: 0, height: 20)
        )
        
        view.addSubview(collection)
        collection.setConstraints(
            top: (moviesLabel).bottomAnchor,
            leading: view.safeAreaLayoutGuide.leadingAnchor,
            trailing: view.safeAreaLayoutGuide.trailingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        )
    }

    @objc private func m3u8ParserTapped(_ sender: UIBarButtonItem) {
        let vc = M3U8PaserViewController()
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collection {
            return videos.count
        } else {
            return series.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionCell.identifire, for: indexPath) as! VideoCollectionCell
            cell.video = videos[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeriesCollectionCell.identifire, for: indexPath) as! SeriesCollectionCell
            cell.video = series[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = VideoCollectionCell.height(for: videos[indexPath.row], width: collection.frame.size.width)
        return CGSize(width: collection.frame.size.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // launch video player
        guard let _ = view.window else { return }
        
        if player == nil {
            let player = VideoPlayer.CodersVideoPlayer(container: self)
            self.player = player
            self.player?.delegate = self
        }
        
        if collectionView == collection {
            let mov = videos[indexPath.row]
            let array = [mov]
            
            player?.play(media: array)
        } else {
            player?.play(media: series[indexPath.row].movies)
        }
    }
    
    
    
}

extension ViewController: CodersVideoPlayerDelegate {
    
    func CodersVideoPlayer(reportMovie movieId: Int) {
        print("Video to report \(movieId)")
    }
    
    func CodersVideoPlayer(mediaPlayed movieId: Int, time: CMTime) {
        print("Video has been player for \(time.String)")
    }
    
    func CodersVideoPlayerDidClosed() {
        self.player = nil
    }
    
}
