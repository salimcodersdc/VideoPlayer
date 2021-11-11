//
//  PopupView.swift
//  autolayoutTransation
//
//  Created by Yousef on 2/3/21.
//

import UIKit
import AVKit

protocol CodersVideoPlayerDelegate: AnyObject {
    func CodersVideoPlayer(reportMovie movieId: Int)
    func CodersVideoPlayer(mediaPlayed movieId: Int, time: CMTime)
}

protocol CodersVideoPlayerContainer: UIViewController {
    var player: CodersVideoPlayer? { get set }
}

class CodersVideoPlayer: UIView {
    
    /// container hold the details about the  movie in  play
    let playerBodyContainer: CodersVideoPlayerBody = {
        let view = CodersVideoPlayerBody()
//        view.backgroundColor = .systemYellow
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// container hold the movie to play
    lazy var playerViewContainer: CodersVideoPlayerView = {
        let view = CodersVideoPlayerView(parent: self, media: self.media)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    
    ///
    weak var delegate: CodersVideoPlayerDelegate? = nil
    
    /// pointer to parent window which hold this player
    var parentWindow: UIWindow?
    
    /// list of media to be played in the player
    var media: [CodersMedia] = []
    
    /// indicator tells if the player shrinked or not
    private var isShrinked: Bool = false
    
    
    /// set of constraints applies to the player view when the device in the portrait orientation
    var portraitPlayerViewTopAnchor: NSLayoutConstraint?
    var portraitPlayerViewLeftAnchor: NSLayoutConstraint?
    var portraitPlayerViewRightAnchor: NSLayoutConstraint?
    var portraitPlayerViewHeightAnchor: NSLayoutConstraint?
    
    /// set of constraints applies to the player view when the device in the landscape orientation
    var landscapePlayerViewTopAnchor: NSLayoutConstraint?
    var landscapePlayerViewLeftAnchor: NSLayoutConstraint?
    var landscapePlayerViewRightAnchor: NSLayoutConstraint?
    var landscapePlayerViewBottomAnchor: NSLayoutConstraint?
    
    /// indicator tells if the player in full mode or not
    private var isFullScreen: Bool = false {
        didSet {
           
        }
    }
    
    /// singelton instance of this class so no one can istantiate this class again
//    public static let shared = CodersVideoPlayer()
    
    
    func moveWithPanGesture(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.translation(in: nil)
        self.center = CGPoint(x: self.center.x + point.x, y: self.center.y + point.y)
        gesture.setTranslation(.zero, in: nil)
    }
    
//    fileprivate init(window: UIWindow?, media: [VPMedia]) {
//        self.parentWindow = window
//        self.media = media
//        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
//        super.init(frame: rect)
//        guard let window = window else { return }
//        window.addSubview(self)
//        showSelf()
//        addObserver()
//    }
//    override fileprivate init(frame: CGRect) {
//        self.parentWindow = nil
//        super.init(frame: frame)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    weak var container: CodersVideoPlayerContainer? = nil
    
    init(container: CodersVideoPlayerContainer) {
        super.init(frame: CGRect.zero)
        
        self.container = container
        self.parentWindow = container.view.window
        addObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        print("Player has been removed")
    }
    
    /// this function launch the player  in certain window with a list of media
    func play(media: [CodersMedia]) {
//        self.parentWindow = window
        if isShrinked {
            maximize()
            playerViewContainer.isShrinked = false
            deactivateConstraints()
        }
        self.media = media
        removeFromSuperview()
        container?.view.window!.addSubview(self)
        setupViews()
        showSelf()
//        addObserver()
    }
    
    func close() {self.parentWindow = window
        playerBodyContainer.removeSubcribers()
        subviews.forEach({$0.removeFromSuperview()})
        removeFromSuperview()
        self.parentWindow = nil
        self.media = []
//        delegate?.CodersVideoPlayerDidClosed()
        container?.player = nil
    }
    
    func maximize() {
        layer.shadowOpacity = 0
        let statusBarFrameHeight: CGFloat = 50
        // Get back to the original size
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.frame = frame
        
        // Restore Video player view
        let playerHeight = UIScreen.main.bounds.width * 9 / 16
        let newY = statusBarFrameHeight
        let rect = CGRect(x: 0, y: newY, width: UIScreen.main.bounds.width, height: playerHeight)
        playerViewContainer.expand(rect: rect)
        
        addSubview(playerBodyContainer)
        isShrinked = false
    }
    
    func minimize() {
        
        deactivateConstraints()
        
        let statusBarFrameHeight: CGFloat = 25
        
        // minimizing player view
        let padding: CGFloat = 16
        let playerWidth = UIScreen.main.bounds.width * 0.5
        let playerHeight = playerWidth * 9 / 16
        let newX = UIScreen.main.bounds.width - playerWidth - padding
        let newY = UIScreen.main.bounds.height - playerHeight - padding - statusBarFrameHeight
        let rect = CGRect(x: newX, y: newY, width: playerWidth, height: playerHeight)
        self.frame = rect
//        activateLandscapePlayerView()
//        playerViewContainer.layoutIfNeeded()
        playerViewContainer.shrink(rect: bounds)
        
        
        
        // set shadows for self
        self.layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 3)
        isShrinked = true
    }
    
   
    
    /// define both sets of  playerView constraints portrait, landscape
    private func defineConstraints() {
        
        // Define portrait constraints
        portraitPlayerViewTopAnchor = playerViewContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0)
        portraitPlayerViewLeftAnchor = playerViewContainer.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 0)
        portraitPlayerViewRightAnchor = playerViewContainer.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: 0)
        portraitPlayerViewHeightAnchor = playerViewContainer.heightAnchor.constraint(equalToConstant: 20)
        
        // Define landscape constraints
        landscapePlayerViewTopAnchor = playerViewContainer.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        landscapePlayerViewLeftAnchor = playerViewContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        landscapePlayerViewRightAnchor = playerViewContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: 0)
        landscapePlayerViewBottomAnchor = playerViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
    }
    
    /// deactivate all constraints
    private func deactivateConstraints() {
        portraitPlayerViewTopAnchor?.isActive = false
        portraitPlayerViewLeftAnchor?.isActive = false
        portraitPlayerViewRightAnchor?.isActive = false
        portraitPlayerViewHeightAnchor?.isActive = false
        landscapePlayerViewTopAnchor?.isActive = false
        landscapePlayerViewLeftAnchor?.isActive = false
        landscapePlayerViewRightAnchor?.isActive = false
        landscapePlayerViewBottomAnchor?.isActive = false
        playerViewContainer.layoutIfNeeded()
        playerBodyContainer.removeFromSuperview()
    }
    
    /// set the right set of constraints according to the  device orientation
    private func activateConstraints() {
        
        deactivateConstraints()
        if isShrinked {
            activateLandscapePlayerView()
        } else {
            switch UIDevice.current.orientation {
            
            case .unknown:
                activatePortraitPlayerView()
                break
            case .portrait:
                activatePortraitPlayerView()
                break
            case .landscapeLeft:
                activateLandscapePlayerView()
                break
            case .landscapeRight:
                activateLandscapePlayerView()
                break
            default:
                activatePortraitPlayerView()
                break
            }
        }
        
        
        
    }
    
    /// activate portrait constraints
    private func activatePortraitPlayerView() {
        portraitPlayerViewTopAnchor?.isActive = true
        portraitPlayerViewLeftAnchor?.isActive = true
        portraitPlayerViewRightAnchor?.isActive = true
        portraitPlayerViewHeightAnchor?.isActive = true
        portraitPlayerViewHeightAnchor?.constant = UIScreen.main.bounds.width * 9 / 16 // self.frame.size.width * 9 / 16
        playerViewContainer.layoutIfNeeded()
        addBodyContainer()
        isFullScreen = false
    }
    
    /// activate landscape constraints
    private func activateLandscapePlayerView() {
        landscapePlayerViewTopAnchor?.isActive = true
        landscapePlayerViewLeftAnchor?.isActive = true
        landscapePlayerViewRightAnchor?.isActive = true
        landscapePlayerViewBottomAnchor?.isActive = true
        isFullScreen = true
    }
    
    
    /// initialize basic view when the player loaded
    private func setupViews() {
    
        addSubview(playerViewContainer)
        
        defineConstraints()

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activateConstraints()
        
    }
    
    /// launch the player in animation when it first launch
    private func showSelf() {
        if let parentWindow = parentWindow {
            
            self.frame = CGRect(x: parentWindow.frame.width - 120, y: parentWindow.frame.height - 120, width: 100, height: 100)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) { [weak self] in
                self?.frame = parentWindow.frame
            } completion: { [weak self] (_) in
                guard let strongSelf = self else { return }
                strongSelf.activateConstraints()
                strongSelf.playerViewContainer.play(media: strongSelf.media)
            }
        }
    }
    
    /// add observer to monitor the device orientation
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRotation), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    
    /// this func called when device orientation changed, it modify player frame and constraints
    @objc private func handleRotation() {
        if let rect = parentWindow?.frame {
            frame = rect
        }
        print("width: \(frame.size.width), player height: \(frame.size.width * 9 / 16)")
        activateConstraints()
        
    }
    
    /// add the container which show video details to the player
    private func addBodyContainer() {
        addSubview(playerBodyContainer)
        NSLayoutConstraint.activate([
            playerBodyContainer.topAnchor.constraint(equalTo: playerViewContainer.bottomAnchor, constant: 0),
            playerBodyContainer.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 0),
            playerBodyContainer.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: 0),
            playerBodyContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 0),
        ])
    }
}
