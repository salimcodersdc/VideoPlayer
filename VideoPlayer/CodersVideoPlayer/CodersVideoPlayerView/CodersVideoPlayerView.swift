//
//  CodersVideoPlayerView.swift
//  autolayoutTransation
//
//  Created by Yousef on 2/4/21.
//

import UIKit
import AVFoundation
import AVKit

class CodersVideoPlayerView: UIView {
    //MARK: Types
    enum VPDisplayPhase {
        case clear
        case controls
        case buffering
        case bufferingWithControls
        case readyToPlay
    }
    
    //MARK: - Constants
    enum ObservableKeys: String {
        case loadedTimeRange = "currentItem.loadedTimeRanges"
        case timeControlStatus = "timeControlStatus"
        case status = "status"
        case currentItemStatus = "currentItem.status"
        case playbackLikelyToKeepUp = "currentItem.playbackLikelyToKeepUp"
        case playbackBufferFull = "currentItem.playbackBufferFull"
        case playbackBufferEmpty = "currentItem.playbackBufferEmpty"
    }
    
    //MARK: - private properties
    
    
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var mediaList: [CodersMedia] = []
    var currentIndex: Int = 0
    var hasObserversAdded: Bool = false
    
    private var defaults: AVPlayerDefaults = AVPlayerDefaults()
    
    /// hold the player time observe to be destroyed befor closing
    private var timeObserver: Any?
    
    /// an indicator becomes true only when the player done playing item
    private var hasVideoEnded: Bool = false
    
    /// an indicator if the player is playing video right now should be modified later to track rate or player status
    private var isPlaying: Bool = false {
        didSet {
            print("isPlaying: \(isPlaying)")
            if isPlaying {
                let image = UIImage(named: IconsNames.pauseCircle.rawValue, in: Bundle(for: CodersVideoPlayerView.self), with: nil)
                playPauseButton.setImage(image, for: .normal)
            } else {
                let image = UIImage(named: IconsNames.playCircle.rawValue, in: Bundle(for: CodersVideoPlayerView.self), with: nil)
                playPauseButton.setImage(image, for: .normal)
            }
        }
    }
    
    var currentMedia: CodersVideoPlayerMedia?
    
    /// the menu which will be showed when press setting button
    private var menu: CodersAVMenu?
    
    ///
    private var displayPhase: VPDisplayPhase = .controls {
        didSet {
            updateDisplay()
        }
    }
    
    private var progressBarSliding: Bool = false
    
    /// an indicator tells if the containers are visible or not
    private var controlsIsVisible: Bool = false {
        didSet {
            updateUI()
        }
    }
    
    /// the anount of time player will go forward or backward when double tapped
    private let seekDuration: Float64 = 5
    
    /// an indicator to if the view is minimized or not
    var isShrinked: Bool = false
    
    //MARK: - Subtitles Properties
    var subtitlesColor: UIColor = .systemYellow {
        didSet {
            initSubtitleStyle()
        }
    }
    
    var subtitlesBKColor: UIColor = UIColor(white: 0.9, alpha: 0.7) {
        didSet {
            initSubtitleStyle()
        }
    }
    
    var subtitlesFontSize: FontSize = .small {
        didSet {
            initSubtitleStyle()
        }
    }
    
    private var subtitleOptions: [LegibleMediaCharacteristic] = [LegibleMediaCharacteristic]()
    
    private var audioOptions: [AudioMediaCharacteristic] = [AudioMediaCharacteristic]()
    
    //MARK: - UI Items
    
    //MARK: Base view
    /// the upper  section of the total view
    private lazy var baseView: UIView = {
        let temp = UIView(frame: self.frame)
        temp.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        temp.isHidden = false
        return temp
    }()
    
    //MARK: - Subtitles Overlay
    /// the view which hold the subtitles label
    private lazy var subtitlesOverlay: UIView = {
        let temp = UIView(frame: self.frame)
        temp.backgroundColor = .clear
        temp.isHidden = false
        return temp
    }()
    
    ///Subtitles Label
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        label.text = "Subtitles By Saleem"
        label.font = label.font.withSize(16)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 4, height: 4)
        label.layer.masksToBounds = false
        label.isHidden = true
        return label
    }()
    
    //MARK: - activityIndicator
    
    /// the upper  section of the total view
    private lazy var activityContainer: UIView = {
        let temp = UIView(frame: self.frame)
        temp.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        temp.translatesAutoresizingMaskIntoConstraints = false
        temp.isHidden = true
        return temp
    }()
    
    /// Spinner
    fileprivate let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.backgroundColor = .clear
        ai.color = .white
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.isHidden = true
        return ai
    }()
    
    //MARK: - Upper containers items
    /// the upper  section of the total view
    lazy var upperContainer: UIView = {
        let temp = UIView(frame: self.frame)
        temp.backgroundColor = .clear
        temp.isHidden = false
        temp.translatesAutoresizingMaskIntoConstraints  = false
        temp.tag = 111
        return temp
    }()
    
    var upperContainerTopAnchor: NSLayoutConstraint?
    var bottomContainerBottomAnchor: NSLayoutConstraint?
    var upperContainerTopAnchorHidden: NSLayoutConstraint?
    var bottomContainerBottomAnchorHidden: NSLayoutConstraint?
    
    /// the button which responsible for minimize the view to go in picture-in-picture mode
    private lazy var pipButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        let image = UIImage(named: "ic_pip", in: Bundle(for: CodersVideoPlayerView.self), with: nil)
        btn.setImage(image, for: .normal)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
//        btn.fixGradiant()
        btn.addTarget(self, action: #selector(handlePIP), for: .touchUpInside)
        return btn
    }()
    
    /// the button which responsible for mazimize the view to go in full screen mode
    private lazy var fullScreenButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = UIImage(named: "ic_fullscreen", in: Bundle(for: CodersVideoPlayerView.self), with: nil)
        btn.setImage(image, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(handleFullScreen), for: .touchUpInside)
        return btn
    }()
    
    /// the button which responsible for searching for casting devices not active yet
    private lazy var closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//        let image = UIImage(named: "ic_airplay", in: Bundle(for: CodersVideoPlayerView.self), with: nil)
        let image = UIImage(systemName: "xmark.circle.fill")
        btn.setImage(image, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = .red
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(handleAirplay), for: .touchUpInside)
        return btn
    }()
    
    /// the button which responsible for showing settings menu
    private lazy var settingButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        let image = UIImage(named: "ic_settings", in: Bundle(for: CodersVideoPlayerView.self), with: nil)
        btn.setImage(image, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
//        btn.fixGradiant()
        btn.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        return btn
    }()
    
    //MARK: - bottom containers items
    
    /// the bottom section of the total view
    lazy var bottomContainer: UIView = {
        let temp = UIView(frame: self.frame)
        temp.backgroundColor = .clear
        temp.isHidden = false
        temp.isUserInteractionEnabled = true
        temp.translatesAutoresizingMaskIntoConstraints = false
        
        return temp
    }()
    
    /// label show the amount of time was passed from the video till now
    private let passedTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.textAlignment = .left
        lbl.text = "00:00"
        lbl.font = .boldSystemFont(ofSize: 12)
        return lbl
    }()
    
    /// label show the duration or the toatal time of video
    private let totalTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.textAlignment = .right
        lbl.text = "00:00"
        lbl.font = .boldSystemFont(ofSize: 12)
        return lbl
    }()
    
    /// slider show how much progress was in time of video
    private lazy var progressBar: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .red
        slider.maximumTrackTintColor = .white
        slider.isUserInteractionEnabled = true
        slider.addTarget(self, action: #selector(handleProgressBar(_:event:)), for: .valueChanged)
        return slider
    }()
    
    //MARK: - Controls container Items
    /// first container
    /// container layout above the middel container to show backward or foreward images when double tapped the view
    private lazy var controlsContainer: UIView = {
        let view = UIView(frame: self.bounds)
        view.backgroundColor = .clear
        view.isHidden = false
        return view
    }()
    
    /// the button which play and pause the video
    private lazy var playPauseButton: UIButton = {
        let btn = UIButton(type: .system)
        let image = UIImage(named: IconsNames.playCircle.rawValue, in: Bundle(for: CodersVideoPlayerView.self), with: nil)
        btn.setImage(image, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(togglePlay), for: .touchUpInside)
        btn.isHidden = false
        return btn
    }()
    
    /// the button which goes to previous video
    private lazy var previousButton: UIButton = {
        let btn = UIButton(type: .system) // "ic_previous"
        let image = UIImage(named: IconsNames.previous.rawValue, in: Bundle(for: CodersVideoPlayerView.self), with: nil)
        btn.setImage(image, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(goPreviousVideo), for: .touchUpInside)
        btn.isHidden = false
        return btn
    }()
    
    /// the button which goes to next video
    private lazy var nextButton: UIButton = {
        let btn = UIButton(type: .system) // "ic_next"
        let image = UIImage(named: IconsNames.next.rawValue, in: Bundle(for: CodersVideoPlayerView.self), with: nil)
        btn.setImage(image, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(goNextVideo), for: .touchUpInside)
        btn.isHidden = false
        return btn
    }()
    
    //MARK: - backwardForwardContainer
    
    /// container layout above the middel container to show backward or foreward images when double tapped the view
    private lazy var fastwardContainer: UIView = {
        let view = UIView(frame: self.bounds)
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    /// an image showen when double tapped the view to go foreward
    private let forwardImage: VPShimmerImage = {
        
        let img = VPShimmerImage()
        img.backgroundColor = .clear
        img.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "forward.fill")
//        let image = UIImage(named: "ic_fast_forward", in: Bundle(for: CodersVideoPlayerView.self), with: nil)
        img.image = image
        img.darkColor = UIColor.init(white: 0.1, alpha: 0.5)
        img.duration = 1
        img.lightColor = .white
        img.fromValue = CGPoint(x: -100, y: 25)
        img.toValue = CGPoint(x: 100, y: 25)
        return img
    }()
    
    /// an image showen when double tapped the view to go backward
    private let backwardImage: VPShimmerImage = {
        let img = VPShimmerImage()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.backgroundColor = .clear // backward.fill
        let image = UIImage(systemName: "backward.fill")
//        let image = UIImage(named: "ic_fast_backward", in: Bundle(for: CodersVideoPlayerView.self), with: nil)
        img.image = image
        img.darkColor = UIColor.init(white: 0.1, alpha: 0.5)
        img.duration = 1
        img.lightColor = .white
        img.fromValue = CGPoint(x: 100, y: 25)
        img.toValue = CGPoint(x: -100, y: 25)
        return img
        
    }()
    
    weak var parent: CodersVideoPlayer?
    private var playerTime: CMTime = .zero
    private var shouldSeekTime: Bool = false
    
    //MARK: - initializers
    
    init(parent: CodersVideoPlayer, media: [CodersMedia]) {
        
        super.init(frame: .zero)
        self.parent = parent
        self.mediaList = media
        setupViews()
        addGestureRecognizers()
//        addRotationObserver()
        displayPhase = .buffering
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        if let timeObserver = timeObserver {
//            player?.removeTimeObserver(timeObserver)
//        } else {
//            print("couldn't find timeObserver")
//        }
        
        print(#function, "Every thing is ok")
    }
    
    func play(media: [CodersMedia]) {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        self.mediaList = media
        displayPhase = .buffering
        setSoundForSilentModel()
        createPlayer()
        setupAVPlayer()
    }
    
    func setSoundForSilentModel() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch(let error) {
            print("📣", #function, error.localizedDescription)
        }
    }
    
    /// add observer to monitor the device orientation
    private func addRotationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRotation), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc private func handleRotation() {
//        print("playerLayer?.frame: \(playerLayer?.frame ?? CGRect.zero)")
//        if UIDevice.current.orientation == .portrait {
//            let width = bounds.height * 9 / 16
//            playerLayer?.frame = CGRect(x: 0, y: 0, width:  width, height: width * 9 / 16)
//        } else  if UIDevice.current.orientation == .landscapeRight || UIDevice.current.orientation == .landscapeLeft {
//            playerLayer?.frame = CGRect(x: 0, y: 0, width: bounds.height, height: bounds.width)
//        }
//        print("playerLayer?.frame: \(playerLayer?.frame ?? CGRect.zero)")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer?.frame = bounds
//        subtitlesOverlay.frame = bounds
//        subtitleLabel.sizeToFit()
    }
    
    //MARK: - upper container buttons handlers

    /// objective-c functions  force the view to rotate to landscape orientation
    @objc private func handleFullScreen() {
        
        let temp = UIDevice.current.orientation  // .currentDevice().orientation
        
        switch temp {
        
        case .unknown:
            print(#function, "unknown")
        case .portrait:
            print(#function, "portrait")
        case .portraitUpsideDown:
            print(#function, "portraitUpsideDown")
        case .landscapeLeft:
            print(#function, "landscapeLeft")
        case .landscapeRight:
            print(#function, "landscapeRight")
        case .faceUp:
            print(#function, "faceUp")
        case .faceDown:
            print(#function, "faceDown")
        @unknown default:
            print(#function, "default")
        }
        
        if temp != .portrait {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        } else {
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
    
    @objc fileprivate func handleAirplay() {
        print("Closed Tapped")
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        // remove observers
        removeObservers()
        // player = nil
        mediaList = []
        player?.pause()
        playerLayer = nil
//        let player = AVPlayer()
//        self.player = player
        self.player = nil
        // CodersVideoPlayer.shared.close()
        parent?.close()
        VideoLogger.shared.clear.send(true)
    }
    
    private func getQualityOptions() -> CodersAVMenuItem? {
       
//        if let video = currentMedia as? M3U8Model {
//            return .quality(model: CodersAVMenuQualityOptionsItem(resolutions: video.resolutions, selectedOption: defaults.selectedQuality))
//        } else {
//            return nil
//        }
        guard let video = currentMedia else { return nil }
        return .quality(model: CodersAVMenuQualityOptionsItem(resolutions: video.resolutions, selectedOption: defaults.selectedQuality))
        
    }
    
    /// objective-c functions  show the configuration menu
    @objc fileprivate func handleSettings() {
        
//        guard let window = CodersVideoPlayer.shared.parentWindow else { return }
        guard let window = parent?.parentWindow else { return }
        menu = CodersAVMenu(window: window)
        var items: [CodersAVMenuItem] = []
        if let qualityOption = getQualityOptions() {
            items.append(qualityOption)
        }
        
        
        items.append(.towOptions(model: CodersAVMenuTowOptionsItem(key: .subtitle,
                                                                   firstOption: "On",
                                                                   secondOption: "Off",
                                                                   selectedOption: defaults.selectedSubtitilesOn)))
        items.append(.threeOptions(model: CodersAVMenuThreeOptionsItem(key: .subtitleFont,
                                                                       firstOption: "Small",
                                                                       secondOption: "Medium",
                                                                       thirdOption: "Larg",
                                                                       selectedOption: defaults.selectedFontSize)))
        items.append(.towOptions(model: CodersAVMenuTowOptionsItem(key: .autoNext,
                                                                   firstOption: "On",
                                                                   secondOption: "Off",
                                                                   selectedOption: defaults.selectedAutoNext)))
        items.append(.towOptions(model: CodersAVMenuTowOptionsItem(key: .continueWatching,
                                                                   firstOption: "On",
                                                                   secondOption: "Off",
                                                                   selectedOption: defaults.selectedContinueWatching)))
        items.append(.oneOption(model: CodersAVMenuOneOptionsItem(key: .reportVideo)))
           
        menu?.items = items
        menu?.itemHieght = 40
        menu?.color = .white
        menu?.underLineColor = .black
        menu?.foregroundColor = .darkGray
        menu?.titleFont = .systemFont(ofSize: 14)
        menu?.optionsFont = .systemFont(ofSize: 12)
        menu?.showSelf()
        menu?.delegate = self
        
        if let menu = menu {
            window.addSubview(menu)
        }
    }
    
    /// objective-c functions  shrink the player size or minimize it
    @objc fileprivate func handlePIP() {
        
//        CodersVideoPlayer.shared.minimize()
        parent?.minimize()
 
        isShrinked = true
    }
    
    //MARK: - bottom container handlers
    @objc fileprivate func handleProgressBar(_ sender: UISlider, event: UIEvent) {
        
        if let touchEvent = event.allTouches?.first {
            print(#function, touchEvent.phase.rawValue)
            switch touchEvent.phase {
            case .began:
                // handle drag began
                print(#function, sender.value)
            case .moved:
                // handle drag moved
                handleSliderDrag(sender)
            case .ended:
                // handle drag ended
                moveWithSlider(sender)
            default:
                break
            }
        }
    }
    
    private func handleSliderDrag(_ sender: UISlider) {
        print(sender.value)
    }
    
    private func moveWithSlider(_ sender: UISlider) {
        print(#function)
        guard let player = player, let duration = player.currentItem?.duration else { return }
        progressBarSliding = true
        let seconds = CMTimeGetSeconds(duration)
        let newTime = Float64(sender.value) * seconds
        let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
//        player.seek(to: time2)
        player.seek(to: time2) { [weak self] (ended) in
            if ended {
                self?.progressBarSliding = false
            }
        }
    }
    
    //MARK: - Control container handlers
    
    private func currentItemChanged() {
        
        currentMedia = CodersVideoPlayerMedia(mediaList[currentIndex])
        subtitleLabel.text = ""
        if let playerItem = currentMedia?.playerItem() {
            player?.replaceCurrentItem(with: playerItem)
            player?.play()
            isPlaying = true
            displayPhase = .bufferingWithControls
            print("%%%%%%%%% alright %%%%%%%%%%%%")
        }
    }
    
    @objc fileprivate func goPreviousVideo() {
        if currentIndex > 0 {
            player?.pause()
            isPlaying = false
            currentIndex -= 1
            currentItemChanged()
        }
    }
    
    @objc fileprivate func goNextVideo() {
        if currentIndex < mediaList.count - 1 {
            player?.pause()
            isPlaying = false
            currentIndex += 1
            currentItemChanged()
        }
    }
    
    @objc fileprivate func togglePlay() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            player?.play()
            isPlaying = true
        }
    }
}


//MARK: - UI Stuff
/// extension to handle UI
extension CodersVideoPlayerView {

    ///
    private func setupViews() {
        addBaseView()
        addSubtitlesOverlay()
        addActivityContainer()
        addContrlsContainers()
        addUpperContainer()
        addBottomContainer()
        bringSubviewToFront(bottomContainer)
    }
    
    ///
    private func removeViews() {
        baseView.removeFromSuperview()
//        activityContainer.removeFromSuperview()
        subtitlesOverlay.removeFromSuperview()
        controlsContainer.removeFromSuperview()
        upperContainer.removeFromSuperview()
        bottomContainer.removeFromSuperview()
    }
    
    private func addSubtitlesOverlay() {
        addSubview(subtitlesOverlay)
        subtitlesOverlay.setConstraints(top: topAnchor,
                                        leading: leadingAnchor,
                                        trailing: trailingAnchor,
                                        bottom: bottomAnchor)
        
        subtitlesOverlay.addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subtitleLabel.bottomAnchor.constraint(equalTo: subtitlesOverlay.bottomAnchor, constant: -20),
            subtitleLabel.centerXAnchor.constraint(equalTo: subtitlesOverlay.centerXAnchor, constant: 0)
        ])
    }
    
    private func addBaseView() {
        addSubview(baseView)
        baseView.setConstraints(top: topAnchor,
                                leading: leadingAnchor,
                                trailing: trailingAnchor,
                                bottom: bottomAnchor)
    }
    
    private func addActivityContainer() {
        addSubview(activityContainer)
        NSLayoutConstraint.activate([
            activityContainer.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            activityContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            activityContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            activityContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
        
        activityContainer.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: activityContainer.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: activityContainer.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
    }
    
    /// add the upper container to view
    private func addUpperContainer() {
        
        let buttonHeight: CGFloat = 34
        
        addSubview(upperContainer)
//        upperContainer.setConstraints(top: topAnchor,
//                                      leading: leadingAnchor,
//                                      trailing: trailingAnchor,
//                                      bottom: nil,
//                                      size: CGSize(width: 0, height: buttonHeight + 10))
        
        
        
        NSLayoutConstraint.activate([
            upperContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            upperContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            upperContainer.heightAnchor.constraint(equalToConstant: buttonHeight + 10)
        ])
        
        upperContainerTopAnchor = upperContainer.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0)
        upperContainerTopAnchorHidden = upperContainer.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: -(buttonHeight + 10))
        upperContainerTopAnchor?.isActive = true
        
        upperContainerTopAnchor?.identifier = "upperContainerTopAnchor"
        upperContainerTopAnchorHidden?.identifier = "upperContainerTopAnchorHidden"
        
        // Add close button
        upperContainer.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: upperContainer.topAnchor, constant: 5),
            closeButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 12),
            closeButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            closeButton.widthAnchor.constraint(equalToConstant: buttonHeight)
        ])
        
        // Add minimize button
        upperContainer.addSubview(fullScreenButton)
        NSLayoutConstraint.activate([
            fullScreenButton.topAnchor.constraint(equalTo: upperContainer.topAnchor, constant: 5),
            fullScreenButton.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 8),
            fullScreenButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            fullScreenButton.widthAnchor.constraint(equalToConstant: buttonHeight)
        ])
        
        // add fullScreenButton pipButton
        upperContainer.addSubview(pipButton)
        NSLayoutConstraint.activate([
            pipButton.topAnchor.constraint(equalTo: upperContainer.topAnchor, constant: 5),
            pipButton.leadingAnchor.constraint(equalTo: fullScreenButton.trailingAnchor, constant: 12),
            pipButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            pipButton.widthAnchor.constraint(equalToConstant: buttonHeight)
        ])
        
        // Add settings button
        upperContainer.addSubview(settingButton)
        NSLayoutConstraint.activate([
            settingButton.topAnchor.constraint(equalTo: upperContainer.topAnchor, constant: 5),
            settingButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -12),
            settingButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            settingButton.widthAnchor.constraint(equalToConstant: buttonHeight)
        ])
        
        
    }
    
    /// add the upper container to view
    private func addBottomContainer() {
        
        let containerHeight: CGFloat = 25
        
        addSubview(bottomContainer)
//        bottomContainer.setConstraints(top: nil,
//                                       leading: leadingAnchor,
//                                       trailing: trailingAnchor,
//                                       bottom: bottomAnchor,
//                                       size: CGSize(width: 0, height: containerHeight))
        
        NSLayoutConstraint.activate([
            bottomContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            bottomContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            bottomContainer.heightAnchor.constraint(equalToConstant: containerHeight)
        ])
        
        bottomContainerBottomAnchor = bottomContainer.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        bottomContainerBottomAnchorHidden = bottomContainer.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: containerHeight)
        bottomContainerBottomAnchorHidden?.isActive = false
        bottomContainerBottomAnchor?.isActive = true
        bottomContainerBottomAnchor?.identifier = "BottomAnchor"
        bottomContainerBottomAnchorHidden?.identifier = "BottomAnchorHidden"
        
        bottomContainer.addSubview(passedTimeLabel)
        bottomContainer.addSubview(totalTimeLabel)
        bottomContainer.addSubview(progressBar)
        
        totalTimeLabel.setConstraints(top: nil,
                                   leading: nil,
                                   trailing: safeAreaLayoutGuide.trailingAnchor,
                                   bottom: bottomContainer.bottomAnchor,
                                   padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8),
                                   size: CGSize(width: 60, height: 18))
        
        passedTimeLabel.setConstraints(top: nil,
                                       leading: safeAreaLayoutGuide.leadingAnchor,
                                       trailing: nil,
                                       bottom: bottomContainer.bottomAnchor,
                                       padding: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0),
                                       size: CGSize(width: 60, height: 18))
        
        progressBar.setConstraints(top: nil,
                                   leading: passedTimeLabel.trailingAnchor,
                                   trailing: totalTimeLabel.leadingAnchor,
                                   bottom: bottomContainer.bottomAnchor,
                                   padding: UIEdgeInsets(top: 0, left: 8, bottom: 5, right: 8),
                                   size: CGSize(width: 0, height: 10))
    }
    
    private func addContrlsContainers() {
        
        let buttonWidth: CGFloat = 35
        addSubview(controlsContainer)
        controlsContainer.setConstraints(top: topAnchor,
                                         leading: leadingAnchor,
                                         trailing: trailingAnchor,
                                         bottom: bottomAnchor,
                                         padding: UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0))
        
        
        // Add playPauseButton
        controlsContainer.addSubview(playPauseButton)
        playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        playPauseButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        
        // Add previous button
        controlsContainer.addSubview(previousButton)
        NSLayoutConstraint.activate([
            previousButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            previousButton.rightAnchor.constraint(equalTo: playPauseButton.leftAnchor, constant: -16),
            previousButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            previousButton.heightAnchor.constraint(equalToConstant: buttonWidth)
        ])
        
        // Add next button
        controlsContainer.addSubview(nextButton)
        NSLayoutConstraint.activate([
            nextButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            nextButton.leftAnchor.constraint(equalTo: playPauseButton.rightAnchor, constant: 16),
            nextButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            nextButton.heightAnchor.constraint(equalToConstant: buttonWidth)
        ])
    }
}

//MARK: - UITapGestureRecognizer
extension CodersVideoPlayerView {
    
    
    /// create Gestures and adding them to the main view
    func addGestureRecognizers() {
        
        // create Gestures
        // single tap Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(wasTapped(_:)))
        
        // double tap Gesture
        let doubleTap = UITapGestureRecognizer(target: self,
                                               action: #selector(wasDoubleTapped(sender:)))
        doubleTap.numberOfTapsRequired = 2
        
        // Pan Gesture
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handlePanGesture(_:)))
        panGesture.minimumNumberOfTouches = 1
        
        /// you make the double tap wait to make sure a panGesture isn’t going to happen.
        /// you make the single tap wait to make sure a double tap isn’t going to happen.
        /// If you didn’t do this, the single tap method would always be called immediately.
        doubleTap.require(toFail: panGesture)
        tap.require(toFail: doubleTap)
        
        // adding Gestures to the view
        addGestureRecognizer(tap)
        addGestureRecognizer(doubleTap)
        addGestureRecognizer(panGesture)
    }
    
    /// single tap Gesture handler
    @objc private func wasTapped(_ sender: UITapGestureRecognizer) {
//        print(#function)
        
        if isShrinked {
            toggleSize()
        } else {
            toggleControls()
        }
    }
    
    func toggleSize() {
//        CodersVideoPlayer.shared.maximize()
        parent?.maximize()
        
        isShrinked = false
        
    }
    
    /// Double tap Gesture handler
    @objc private func wasDoubleTapped(sender: UITapGestureRecognizer) {
        
        guard let currentItem = player?.currentItem else { return }
        guard let current = currentMedia?.isLiveStreaming, !current else { return }
        if currentItem.status == .readyToPlay {
            if sender.state == .ended {
                
                let touchLocation: CGPoint = sender.location(in: sender.view)
                
                if touchLocation.x < frame.size.width / 3 {
                    seekPrevious()
                } else if touchLocation.x > 2 * (frame.size.width / 3) {
                    seekNext()
                }
                
            }
        }
        
    }
    
    /// Pan Gesture handler
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        if isShrinked {
            let state = UIPanGestureRecognizer.State(rawValue: gesture.state.rawValue)
            if state == .changed {
//                CodersVideoPlayer.shared.moveWithPanGesture(gesture)
                parent?.moveWithPanGesture(gesture)
            }
        }
    }
    
    private func showBackwardImage() {
        
        let buttonWidth: CGFloat = 50
        
        fastwardContainer.frame = bounds
        addSubview(fastwardContainer)
        
        fastwardContainer.addSubview(backwardImage)
        NSLayoutConstraint.activate([
            backwardImage.centerYAnchor.constraint(equalTo: fastwardContainer.centerYAnchor,
                                                   constant: 0),
            backwardImage.centerXAnchor.constraint(equalTo: fastwardContainer.centerXAnchor,
                                                   constant: -((buttonWidth * 2) + 16 + 16)),
            backwardImage.heightAnchor.constraint(equalToConstant: buttonWidth),
            backwardImage.widthAnchor.constraint(equalToConstant: buttonWidth)
        ])
        
        fastwardContainer.isHidden = false
        backwardImage.isHidden = false
    }
    
    private func showForwardImage() {
        let buttonWidth: CGFloat = 50
        
        fastwardContainer.frame = bounds
        addSubview(fastwardContainer)
        
        fastwardContainer.addSubview(forwardImage)
        NSLayoutConstraint.activate([
            forwardImage.centerYAnchor.constraint(equalTo: fastwardContainer.centerYAnchor,
                                                   constant: 0),
            forwardImage.centerXAnchor.constraint(equalTo: fastwardContainer.centerXAnchor,
                                                   constant: (buttonWidth * 2) + 16 + 16),
            forwardImage.heightAnchor.constraint(equalToConstant: buttonWidth),
            forwardImage.widthAnchor.constraint(equalToConstant: buttonWidth)
        ])
        
        fastwardContainer.isHidden = false
        forwardImage.isHidden = false
    }
    
    private func seekTimeIfNeeded() {
        if shouldSeekTime {
            player?.seek(to: playerTime)
            VideoLogger.shared.append.send("time moved to \(playerTime.String)")
            shouldSeekTime = false
            playerTime = .zero
        }
    }
    
    private func hideWardImages() {
        fastwardContainer.isHidden = true
        forwardImage.isHidden = true
        backwardImage.isHidden = true
        
        fastwardContainer.removeFromSuperview()
        forwardImage.removeFromSuperview()
        backwardImage.removeFromSuperview()
    }
    
    private func seekPrevious() {
        guard let player = player else { return }
        
        
        showBackwardImage()
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
            var newTime = playerCurrentTime - seekDuration

            if newTime < 0 {
                newTime = 0
            }
        let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
//            player.seek(to: time2)
        player.seek(to: time2) { [weak self] (ended) in
            if ended {
                self?.hideWardImages()
            }
        }
    }
    
    private func seekNext() {
        guard let player = player,
              let duration  = player.currentItem?.duration else { return }
        
        
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = playerCurrentTime + seekDuration
        
        showForwardImage()
        if newTime < duration.seconds {
            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            player.seek(to: time2) { [weak self] (ended) in
                if ended {
                    self?.hideWardImages()
                }
            }
        } else {
            player.seek(to: duration) { [weak self] (ended) in
                self?.hideWardImages()
            }
        }
    }
    
    func shrink(rect: CGRect) {
        playerLayer?.frame = bounds
        // removing controles from player
        removeViews()
    }
    
    func expand(rect: CGRect) {
        playerLayer?.frame = bounds
        setupViews()
    }
    
    private func toggleControls() {
        
//        let timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: false)
//        timer.tolerance = TimeInterval(0.5)
//        timer.invalidate()
        
        controlsIsVisible = !controlsIsVisible
    }

    @objc private func handleTimer() {
        
    }
}

//MARK: -  displaying phases
/// extension to handle UI displaying phases
extension CodersVideoPlayerView {
    
    func updateDisplay() {
        switch displayPhase {
        
        case .clear:
            hideContainers()
        case .controls:
            displayControls()
        case .buffering:
            displayBuffering()
        case .bufferingWithControls:
            displayBufferingWithControls()
        case .readyToPlay:
            displayControls()
        }
        arrangeContainers()
    }
    
    private func hideContainers() {
        baseView.isHidden = true
        upperContainer.isHidden = true
//        bottomContainer.isHidden = true
        if progressBarSliding {
//            bottomContainer.isHidden = false
            if let  isLiveStreaming = currentMedia?.isLiveStreaming {
                if !isLiveStreaming {
                    self.bottomContainer.isHidden = false
                }
            }
        } else {
            bottomContainer.isHidden = true
        }
        controlsContainer.isHidden = true
        fastwardContainer.isHidden = true
        activityContainer.isHidden = true
    }
    
    private func displayControls() {
        baseView.isHidden = false
        upperContainer.isHidden = false
        if let  isLiveStreaming = currentMedia?.isLiveStreaming {
            if !isLiveStreaming {
                bottomContainer.isHidden = false
            }
        }
        
        displayControlsContainer()
        fastwardContainer.isHidden = true
        activityContainer.isHidden = true
    }
    
    private func displayBuffering() {
        baseView.isHidden = false
        upperContainer.isHidden = false
//        bottomContainer.isHidden = true
        if progressBarSliding {
            if let  isLiveStreaming = currentMedia?.isLiveStreaming {
                if !isLiveStreaming {
                    self.bottomContainer.isHidden = false
                }
            }
//            bottomContainer.isHidden = false
        } else {
            bottomContainer.isHidden = true
        }
        controlsContainer.isHidden = true
        fastwardContainer.isHidden = true
        activityContainer.isHidden = false
    }
    
    private func displayBufferingWithControls() {
        baseView.isHidden = false
        upperContainer.isHidden = false
        if let  isLiveStreaming = currentMedia?.isLiveStreaming {
            if !isLiveStreaming {
                bottomContainer.isHidden = false
            }
        }
        controlsContainer.isHidden = true
        fastwardContainer.isHidden = true
        activityContainer.isHidden = false
    }
    
    private func displayControlsContainer() {
        controlsContainer.isHidden = false
        print("mediaList.count: \(mediaList.count)")
        if mediaList.count < 2 {
            previousButton.isEnabled = false
            nextButton.isEnabled = false
        } else {
            previousButton.isEnabled = true
            nextButton.isEnabled = true
        }
    }
    
    private func arrangeContainers() {
        bringSubviewToFront(baseView)
        bringSubviewToFront(subtitlesOverlay)
        bringSubviewToFront(activityContainer)
        bringSubviewToFront(controlsContainer)
        bringSubviewToFront(upperContainer)
        bringSubviewToFront(bottomContainer)
        
    }
    
    
    
}

//MARK: - animations
extension CodersVideoPlayerView {
    private func updateUI() {
        
        
        
        if controlsIsVisible {
            // show containers
            baseView.isHidden = !controlsIsVisible
            upperContainer.isHidden = !controlsIsVisible
            
            if let  isLiveStreaming = currentMedia?.isLiveStreaming {
                if !isLiveStreaming {
                    bottomContainer.isHidden = !controlsIsVisible
                }
            }
            
            
            
            controlsContainer.isHidden = !controlsIsVisible
            showUpperBottomContainers()
        } else {
            // hide containers
            hideUpperBottomContainers()
            baseView.isHidden = !controlsIsVisible
            
        }
        
    }
    
    private func showUpperBottomContainers() {

        if displayPhase == .controls {
            controlsContainer.isHidden = false
            controlsContainer.alpha = 0
        }
        
        
        upperContainerTopAnchor?.isActive = false
        upperContainerTopAnchorHidden?.isActive = false
        bottomContainerBottomAnchor?.isActive = false
        bottomContainerBottomAnchorHidden?.isActive = false
        
        
        upperContainerTopAnchor?.isActive = true
        bottomContainerBottomAnchor?.isActive = true
       
        
        

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: .curveEaseIn) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.layoutIfNeeded()
            strongSelf.upperContainer.alpha = 1
            strongSelf.bottomContainer.alpha = 1
            strongSelf.controlsContainer.alpha = 1
        } completion: { [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.bringSubviewToFront(strongSelf.bottomContainer)
            strongSelf.bringSubviewToFront(strongSelf.controlsContainer)
            strongSelf.bringSubviewToFront(strongSelf.upperContainer)
            
            
        }
    }
    
    private func hideUpperBottomContainers() {
  
       

        upperContainerTopAnchor?.isActive = false
        upperContainerTopAnchorHidden?.isActive = true
        bottomContainerBottomAnchor?.isActive = false
        bottomContainerBottomAnchorHidden?.isActive = true
      
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            self.layoutIfNeeded()
            self.upperContainer.alpha = 0
            self.bottomContainer.alpha = 0
            self.controlsContainer.alpha = 0
        } completion: { (_) in
            self.inverseVisibility()
        }
    }
    
    private func inverseVisibility() {
        self.upperContainer.isHidden = !self.controlsIsVisible
        
        if let  isLiveStreaming = currentMedia?.isLiveStreaming {
            if !isLiveStreaming {
                self.bottomContainer.isHidden = !self.controlsIsVisible
            }
        }
        
        self.controlsContainer.isHidden = !self.controlsIsVisible
    }
    
}

//MARK: - Vido Stuff
extension CodersVideoPlayerView {
    
    private func createPlayer() {

        let player = AVPlayer()
        player.appliesMediaSelectionCriteriaAutomatically = true

        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        self.layer.addSublayer(playerLayer)

        

        self.player = player
        self.playerLayer = playerLayer
        
        initSubtitleStyle()
        addObservers()
    }
    
    private func setupAVPlayer() {
       
        guard mediaList.count > 0 else { return }
        
        
        currentIndex = 0
        
        displayPhase = .bufferingWithControls
        
//        if let media = currentMedia as? M3U8ModelWithSubtitle {
//
//            media.getPlayerItem { [weak self] (res) in
//                guard let strongSelf = self else { return }
//                print("playerItem Done")
//                print("***************************************************")
//                switch res {
//
//                case .success(let playerItem):
//                    DispatchQueue.main.async {
//                        print(playerItem)
//                        strongSelf.player?.replaceCurrentItem(with: playerItem)
//
//                        strongSelf.player?.play()
//                        strongSelf.isPlaying = true
//                    }
//
//                case .failure(let error):
//                    DispatchQueue.main.async {
//                        print(error.localizedDescription)
//                        strongSelf.displayPhase = .controls
//                    }
//
//                }
//            }
//
//        } else
        
        // create local structure to hold every thing about video resolutions, subtitles
        currentMedia = CodersVideoPlayerMedia(mediaList[currentIndex])
       
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let item = self?.currentMedia?.playerItem() {
                DispatchQueue.main.async {
                    self?.player?.replaceCurrentItem(with: item)
                    self?.player?.play()
                    self?.isPlaying = true
                }
            } else {
                DispatchQueue.main.async {
                    self?.displayPhase = .controls
                }
            }
        }
        
//        if let playerItem = currentMedia?.playerItem() {
//            player?.replaceCurrentItem(with: playerItem)
//
//            player?.play()
//            isPlaying = true
//        } else {
//            displayPhase = .controls
//        }
    }
    
    private func removeObservers() {
        if hasObserversAdded {
            player?.removeObserver(self, forKeyPath: "currentItem.duration")
            player?.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")
            player?.removeObserver(self, forKeyPath: "currentItem.playbackBufferFull")
            player?.removeObserver(self, forKeyPath: "currentItem.playbackBufferEmpty")
            player?.removeObserver(self, forKeyPath: "timeControlStatus")
            player?.removeObserver(self, forKeyPath: "currentItem.status")
            player?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges")
            player?.removeObserver(self, forKeyPath: "currentItem.presentationSize")
            
            if let timeObserver = timeObserver {
                player?.removeTimeObserver(timeObserver)
            }
            
            hasObserversAdded = false
            print("Observers has been removed")
        }
    }
    
    
    private func addObservers() {
        player?.addObserver(self, forKeyPath: "currentItem.duration",
                            options: .new, context: nil)
        player?.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp",
                            options: .new, context: nil)
        player?.addObserver(self, forKeyPath: "currentItem.playbackBufferFull",
                            options: .new, context: nil)
        player?.addObserver(self, forKeyPath: "currentItem.playbackBufferEmpty",
                            options: .new, context: nil)
        player?.addObserver(self, forKeyPath: "timeControlStatus",
                            options: .new, context: nil)
        player?.addObserver(self, forKeyPath: "currentItem.status",
                            options: .new, context: nil)
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges",
                            options: .new, context: nil)
        player?.addObserver(self, forKeyPath: "currentItem.presentationSize",
                            options: .new, context: nil)
        
        
        addPeriodicObserver()
        hasObserversAdded = true
        
        print("Observers has been added")
    }
    
    func addPeriodicObserver() {
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] (timeProgress) in
            
            guard let strongSelf = self,
                  let player = strongSelf.player,
                  let currentItem = strongSelf.player?.currentItem else { return}
            
            if strongSelf.player?.timeControlStatus == .playing {
                
                // set time passed to lblTimeProgress text
                strongSelf.passedTimeLabel.text = player.currentTime().String
                
                // set the value for progress bar
//                let secondsPlay = CMTimeGetSeconds(player.currentTime())
                let secondsPlay = player.currentTime().seconds
                let totalTime = currentItem.duration.seconds
                let value = Float(secondsPlay) / Float(totalTime)
                
                if strongSelf.progressBar.isTracking == false {
                    strongSelf.progressBar.value = value
                }
                
//                strongSelf.progressBar.value = value
                
                // check if video ended
                if secondsPlay == totalTime {
                    strongSelf.hasVideoEnded = true
                }
                
                // Search && show subtitles
                let temp = Subtitle.searchSubtitles(strongSelf.currentMedia?.subtitles, timeProgress.seconds)
                if strongSelf.subtitleLabel.text != temp {
                    strongSelf.subtitleLabel.text = temp
                    strongSelf.subtitleLabel.sizeToFit()
                }
                
            }
            
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // context == &playbackLikelyToKeepUpContext
//        print("**** keyPath: \(keyPath ?? "No keyPath") ****")
        
        switch keyPath {
        
        case "currentItem.playbackLikelyToKeepUp":
            if let currentItem = player?.currentItem {
                if currentItem.isPlaybackLikelyToKeepUp {
                    displayPhase = .controls
                } else {
                    if currentItem.isPlaybackBufferFull {
//                        print("current item playback: isPlaybackBufferFull")
                    } else if currentItem.isPlaybackBufferEmpty {
                        displayPhase = .buffering
//                        print("current item playback: isPlaybackBufferEmpty")
                    }
                }
            }
            break
            
        case "currentItem.playbackBufferFull":
            break
            
        case "currentItem.presentationSize":
            let size = player?.currentItem?.presentationSize
            VideoLogger.shared.append.send("video size: \(size?.debugDescription ?? "")")
            
        case "currentItem.playbackBufferEmpty":
//            aiContainer.isHidden = false
//            playPauseButton.isHidden = true
//            previousButton.isHidden = true
//            nextButton.isHidden = true
//            activityIndicator.startAnimating()
            displayPhase = .buffering
            break
            
        case "timeControlStatus":
            if let player = player {
                
                
                switch player.timeControlStatus {
                case .paused:
                    isPlaying = false
                    if hasVideoEnded {
                        videoHasEndedPlay()
                    }
                case .playing:
                    isPlaying = true
                    displayPhase = .clear
//                    print("**** observeValue  timeControlStatus playing ****")
                    break
                case .waitingToPlayAtSpecifiedRate:
                    displayPhase = .buffering
//                    print("**** observeValue  timeControlStatus waitingToPlayAtSpecifiedRate ****")
                    break
                default:
                    break
                }
            }
            break
            
        case "currentItem.status":
            guard let player = self.player else { return }
            switch player.status {
            
            case .unknown:
                print("**** observeValue  status unknown ****")
            case .readyToPlay:
                print("**** observeValue  status readyToPlay ****")
                hideWardImages()
                seekTimeIfNeeded()
            case .failed:
                print("**** observeValue  status failed ****")
            default:
                break
            }
            
        case "currentItem.duration":
            setupVideo()
//            print("**** observeValue  currentItem.duration \(player?.currentItem?.duration.String ?? "no duration") ****")
        case "currentItem.loadedTimeRanges":
            let status = player?.timeControlStatus
            switch status {
            case .paused:
                break
            case .playing:
                break
            case .waitingToPlayAtSpecifiedRate:
                displayPhase = .buffering
//                print("timeControlStatus waitingToPlayAtSpecifiedRate")
            default:
                print("timeControlStatus some thing else ")
            
            }
        default:
            break
        }
        
    }
    
    
    private func setupVideo() {
        
        
        totalTimeLabel.text = player?.currentItem?.duration.String
        let asset = player?.currentItem?.asset
        
        if let characteristics = player?.currentItem?.asset.availableMediaCharacteristicsWithMediaSelectionOptions {
            for mediaCharacteristic in characteristics {
                if mediaCharacteristic == .audible {
                    if let visualGroup = asset?.mediaSelectionGroup(forMediaCharacteristic: .audible) {
                        let visualList = visualGroup.options
                        audioOptions = []
                        for band in visualList {
                            var kind: AudioMediaCharacteristicType = .unknown
                            switch band.mediaType.rawValue {
                            case "soun":
                                kind = .sound
                            default:
                                kind = .unknown
                            }
                            let tmp = AudioMediaCharacteristic(language: band.extendedLanguageTag ?? "no langaue",
                                                               mediaType: kind,
                                                               title: band.displayName,
                                                               isDefault: visualGroup.defaultOption == band)
                            audioOptions.append(tmp)
                        }
                    }
                } else if mediaCharacteristic == .legible {
                    if let visualGroup = asset?.mediaSelectionGroup(forMediaCharacteristic: .legible) {
                        let visualList = visualGroup.options
                        subtitleOptions = []
                        for band in visualList {
                            var kind: LegibleMediaCharacteristicType = .unknown
                            switch band.mediaType.rawValue {
                            case "clcp":
                                kind = .closedCaption
                            case "sbtl":
                                kind = .subtitle
                            default:
                                kind = .unknown
                            }
                            let tmp = LegibleMediaCharacteristic(language: band.extendedLanguageTag ?? "no langaue",
                                                                 mediaType: kind,
                                                                 title: band.displayName,
                                                                 isDefault: visualGroup.defaultOption == band,
                                                                 package: band)
                            subtitleOptions.append(tmp)
                        }
                    }
                }
                /*
                 else if mediaCharacteristic == .visual {
                     if let visualGroup = asset?.mediaSelectionGroup(forMediaCharacteristic: .legible) {
                         let visualList = visualGroup.options
                         for band in visualList {
                             print("""
                                     Visual: \(String(describing: band))
                                     mediaType: \(band.mediaType.rawValue)
                                     """)
                         }
                     }
                 }
                 */
                
            }
        }
//        print("?????????????????????????????????????????????????")
//        if let tracks = player?.currentItem?.tracks {
//            if tracks.count == 0 {
//                print("player?.currentItem?.tracks count = 0")
//            }
//            for track in tracks {
//                print("track: \(String(describing: track))")
//            }
//        } else {
//            print("No player?.currentItem?.tracks available")
//        }
//        print("?????????????????????????????????????????????????")
//
//        print("------------------------------------")
//        print("Legible Media Characteristic")
//        for audio in audioOptions {
//            print(audio.description)
//            print("------------------------------------")
//        }
//
//        print("Legible Media Characteristic")
//        for subtitle in subtitleOptions {
//            print(subtitle.description)
//            print("------------------------------------")
//        }
        
        // select subtitle media
//        if let group = asset?.mediaSelectionGroup(forMediaCharacteristic: .legible) {
//            let listCC = group.options
//
//
//            if listCC.count > 1 {
//                let secondCC = listCC[1]
//
//
//                player?.currentItem?.select(secondCC, in: group)
//                defaults.hasSubtitles = true
//                defaults.subtitles = secondCC
//                initSubtitleStyle()
//            }
//        }
        
        
    }
    
    
    
    private func videoHasEndedPlay() {
        /*
        if player?.timeControlStatus == .paused {
            hasVideoEnded = false
            player?.pause()
            player?.seek(to: CMTime.zero)
            isPlaying = false
            progressBar.value = 0
            isPlaying = false
            print("video has ended play")
        }
        */
        
        if defaults.autoNext {
            if currentIndex < mediaList.count - 1 {
                currentIndex += 1
                currentItemChanged()
            }
        }
        
    }
    
    private func activateSubtitles(_ value: Bool) {
//        guard let media = currentMedia else { return }
//        if media is M3U8Model {
//            activateM3U8Subtitles(value)
//        } else if media is MP4Model {
//            activateMP4Subtitles(value)
//        }
        
        guard let _ = currentMedia else { return }
        activateM3U8Subtitles(value)
    }
    
    private func activateMP4Subtitles(_ value: Bool) {
//        if value {
//            if let media = currentMedia as? MP4Model {
//                let playerItem = media.playerItem()
//                player?.replaceCurrentItem(with: playerItem)
//            }
//        } else {
//            if var tracks = player?.currentItem?.asset.tracks(withMediaType: .text) {
//                if let _ = tracks.first {
//                    tracks.remove(at: 0)
//                }
//            }
//        }
        
        if !value {
            if var tracks = player?.currentItem?.asset.tracks(withMediaType: .text) {
                if let _ = tracks.first {
                    tracks.remove(at: 0)
                }
            }
        }
        
    }
    
    private func activateM3U8Subtitles(_ value: Bool) {
        if value {
            // Activate subtitles
            
            if let group = player?.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
                for option in subtitleOptions {
                    if option.mediaType == .subtitle {
                        player?.currentItem?.select(option.package, in: group)
                        defaults.subtitles = option.package
                        defaults.isSubtitilesOn = true
                        defaults.hasSubtitles = true
                        initSubtitleStyle()
                        break
                    }
                }
            }
            
        } else {
            // deActivate subtitles
            if let group = player?.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
                player?.currentItem?.select(nil, in: group)
                defaults.subtitles = nil
                defaults.isSubtitilesOn = false
                defaults.hasSubtitles = false
            }
        }
    }
    
    
    func initSubtitleStyle() {
        
        guard let currentItem = player?.currentItem else { return }
        
        if defaults.hasSubtitles {
            
            let backgroundColor = AVTextStyleRule(textMarkupAttributes: [
                kCMTextMarkupAttribute_CharacterBackgroundColorARGB as String: [subtitlesBKColor.alphaValue, subtitlesBKColor.redValue, subtitlesBKColor.greenValue, subtitlesBKColor.blueValue]
            ])!
            
            
            let foregroundColor = AVTextStyleRule(textMarkupAttributes: [
                kCMTextMarkupAttribute_ForegroundColorARGB as String: [subtitlesColor.alphaValue, subtitlesColor.redValue, subtitlesColor.greenValue, subtitlesColor.blueValue]
            ])!
            
            let fontStyle = AVTextStyleRule(textMarkupAttributes: [
                kCMTextMarkupAttribute_BaseFontSizePercentageRelativeToVideoHeight as String: subtitlesFontSize.rawValue,
                kCMTextMarkupAttribute_CharacterEdgeStyle as String: kCMTextMarkupCharacterEdgeStyle_Raised as String,
                kCMTextMarkupAttribute_GenericFontFamilyName as String : kCMTextMarkupGenericFontName_Fantasy as String
            ])!
            
            currentItem.textStyleRules = [backgroundColor, foregroundColor, fontStyle]
        }
    }
   
     
}

//MARK: - CodersAVMenuDelegate
extension CodersVideoPlayerView: CodersAVMenuDelegate {
    
    
    func qualityChanged(value: VPResolution, index: Int) {
        if value.title != defaults.quality?.title {
            print(#function, "You have choose \(value.title)")
            VideoLogger.shared.append.send("You have choose \(value.title)")
            defaults.quality = value
            defaults.selectedQuality = index
            DispatchQueue.global(qos: .default).async { [weak self] in
                self?.selectResolution(value)
            }
        }
    }
    
    private func selectResolution(_ resolution: VPResolution) {
        
        guard let media = currentMedia else { return }
        if resolution.title == "Auto" {
            let item = media.playerItem()
            let time = player?.currentItem?.currentTime() ?? CMTime.zero
            DispatchQueue.main.async { [weak self] in
                self?.player?.replaceCurrentItem(with: item)
                self?.playerTime = time
                VideoLogger.shared.append.send("time moved to \(time.String)")
                self?.shouldSeekTime = true
            }
        } else {
            let item = media.playerItemForResolution(resolution)
            let time = player?.currentItem?.currentTime() ?? CMTime.zero
            DispatchQueue.main.async { [weak self] in
                self?.player?.replaceCurrentItem(with: item)
                self?.playerTime = time
                VideoLogger.shared.append.send("time moved to \(time.String)")
                self?.shouldSeekTime = true
            }
        }
    }
    
    func subtitleChanged(value: OnOff) {
        switch value {
        
        case .on:
            subtitleLabel.isHidden = false
//            defaults.subtitles = option.package
            defaults.isSubtitilesOn = true
//            defaults.hasSubtitles = true
//            activateSubtitles(true)
        case .off:
            subtitleLabel.isHidden = true
            defaults.isSubtitilesOn = false
//            activateSubtitles(false)
        }
    }
    
    func subtitleFontChanged(value: FontSize) {
        print("font size is: \(value.rawValue)")
        subtitlesFontSize = value
        defaults.subtitlesSize = value
        // label.font = label.font.withSize(20)
        subtitleLabel.font = subtitleLabel.font.withSize(value.labelFontSize)
        /*
         switch value {
        case .small:
            subtitlesFontSize = .small
        case .medium:
            subtitlesFontSize = .medium
//            player?.pause()
//            initSubtitleStyle()
//            player?.play()
//            print("every thing ok")
//            break
        case .larg:
            subtitlesFontSize = .larg
        }
        */
    }
    
    func autoNextChanged(value: OnOff) {
        print("Auto Next is: \(value.rawValue)")
        switch value {
        case .off:
            defaults.autoNext = false
        case .on:
            defaults.autoNext = true
        }
    }
    
    func continueWatchingChanged(value: OnOff) {
        print("Continue Watching is: \(value.rawValue)")
        switch value {
        case .off:
            defaults.continueWatching = false
        case .on:
            defaults.continueWatching = true
        }
    }
    
    func needReportVideo() {
        if let id = currentMedia?.id {
            parent?.delegate?.CodersVideoPlayer(reportMovie: id)
        }
    }
    
    func showPopupMenu() {
        
    }
    
    func hidePopupMenu() {
        menu?.removeFromSuperview()
    }
    
    func itemSelected(_ item: CodersAVMenuItem) {
        
        switch item {
        
        case .towOptions(model: let model):
            print(model.key.title)
            switch model.key {
            
            case .subtitle:
                print(model.key.title)
            case .autoNext:
                print(model.key.title)
            case .continueWatching:
                print(model.key.title)
            }
                        
        case .threeOptions(model: let model):
            switch model.key {
            
            case .subtitleFont:
                print(model.key.title)
            }
        case .oneOption(model: let model):
            print(model.key.title)
        case .fourOptions(model: let model):
            print(model.key.title)
        case .quality(model: let model):
            print("you have choose: \(model)")
        }
        
        
    }
    
    
}
