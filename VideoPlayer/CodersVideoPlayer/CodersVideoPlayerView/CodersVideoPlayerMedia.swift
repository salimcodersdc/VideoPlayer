//
//  CodersVideoPlayerMedia.swift
//  VideoPlayer
//
//  Created by Yousef on 10/5/21.
//

import UIKit
import AVFoundation

public protocol CodersMedia {
    var id: Int {get}
    var mediaURL: URL {get}
    var srtURL: URL? {get}
    var isLiveStreaming: Bool {get}
}

class CodersVideoPlayerMedia {
    let id: Int
    let mediaURL: URL
    let srtURL: URL?
    var baseURL: String
    var resolutions: [VPResolution]
    var subtitles: NSDictionary
    var isLiveStreaming: Bool
    
    init(_ media: CodersMedia) {
        self.id = media.id
        self.mediaURL = media.mediaURL
        self.srtURL = media.srtURL
        self.baseURL = ""
        self.resolutions = []
        self.subtitles = NSDictionary()
        self.isLiveStreaming = media.isLiveStreaming
        prepareMediaToBePlayed()
    }
    
    private func prepareMediaToBePlayed() {
        fetchBaseURL()
        fetchResolutions()
        fetchSubtitles()
        
    }
    
    private func fetchBaseURL() {
        baseURL = M3u8Parser.baseURL(mediaURL)
    }
    
    private func fetchResolutions() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            M3u8Parser.ResolutionsAsync(url: strongSelf.mediaURL) { response in
                switch response {
                
                case .success(let data):
                    strongSelf.resolutions = data
                    print("🔥 Resolutions Done")
                    VideoLogger.shared.append.send("🔥 Resolutions Done")
                case .failure(let error):
                    print("🔥 Resolutions Error \(error.localizedDescription)")
                    VideoLogger.shared.append.send("🔥 Resolutions Error \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchSubtitles() {
        guard let srtURL = srtURL else { return }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            if let content = try? String(contentsOf: srtURL) {
                strongSelf.subtitles = Subtitle.parseDict(content)
                print("🔥 Subtitles Done")
                VideoLogger.shared.append.send("🔥 Subtitles Done")
                return
            } else {
                VideoLogger.shared.append.send("🔥 Subtitles Error: Can't read the content of the file")
                print("🔥 Subtitles Error: Can't read the content of the file")
            }
        }
    }
    
    public func playerItem() -> AVPlayerItem? {
        let asset = AVURLAsset(url: mediaURL)
        let result = AVPlayerItem(asset: asset)
        return result
    }
    
    private func playerItemWithSubtitles(srtURL: URL) -> AVPlayerItem? {
        
        
        if let content = try? String(contentsOf: srtURL) {
            if let vtt = Subtitle.convertIntoVtt(content) {
                return M3U8PlusSubtitles(vttURL: vtt)
            }
        }
        
        return playerItem()
    }
    
    func playerItemForResolution(_ resolution: VPResolution) -> AVPlayerItem? {
        let urlString = baseURL + resolution.URI
        guard let url = URL(string: urlString) else { return playerItem()}
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        return item
    }
    
    //MARK: - Private Functions
    private func M3U8PlusSubtitles(vttURL: URL) -> AVPlayerItem? {
        let videoAsset = AVURLAsset(url: mediaURL)
        
        let subtitleAsset = AVURLAsset(url: vttURL)
        
        let videoPlusSubtitles = AVMutableComposition()
        
       
        
        // create video track to be added to the mutable composition
        let videoTrack = videoPlusSubtitles.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        // extract the main track from video asset
        let videoAssetVideoMedias = videoAsset.tracks(withMediaType: .video)
        guard let firstVideoTrack = videoAssetVideoMedias.first else {
            print(print("something bad happend extracting video track"))
            return nil
        }

        do {

            try videoTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: videoAsset.duration),
                                            of: firstVideoTrack,
                                            at: CMTime.zero)
        } catch {
            print("something bad happend Adding video track")
            print("error: \(error.localizedDescription)")
            return nil
        }

        
        // create sound track to be added to the mutable composition
        let soundTrack = videoPlusSubtitles.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        // extract the main track from video asset
        let videoAssetSoundMedias = videoAsset.tracks(withMediaType: .audio)
        guard let firstSoundTrack = videoAssetSoundMedias.first else {
            print(print("something bad happend extracting Sound track"))
            return nil
        }

        do {

            try soundTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: videoAsset.duration),
                                            of: firstSoundTrack,
                                            at: CMTime.zero)
        } catch {
            print("something bad happend Adding sound track")
            print("error: \(error.localizedDescription)")
            return nil
        }
        
        let subtitleTrack = videoPlusSubtitles.addMutableTrack(withMediaType: .text, preferredTrackID: kCMPersistentTrackID_Invalid)

        // extract the main track from subtitle asset
        guard let firstSubtitleTrack = subtitleAsset.tracks.first else {
            print(print("something bad happend extracting subtitle track"))
            return nil
        }

        do {
            try subtitleTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: videoPlusSubtitles.duration),
                                                of: firstSubtitleTrack,
                                                at: CMTime.zero)
        } catch {
            print("something bad happend Adding subtitle track")
            print("error: \(error.localizedDescription)")
            return nil
        }
        
        let playerItem = AVPlayerItem(asset: videoPlusSubtitles)
        
        return playerItem
    }
    
    
    private func M3U8PlusSubtitlesAsync(vttURL: URL, complition: @escaping (Result<AVPlayerItem, CodersVideoPlayerMediaError>) -> ()) {
        let videoAsset = AVURLAsset(url: mediaURL)
        
        let subtitleAsset = AVURLAsset(url: vttURL)
        
        let videoPlusSubtitles = AVMutableComposition()
        
        videoAsset.loadValuesAsynchronously(forKeys: assetKeysRequiredToPlay) {
            
            let range = CMTimeRange(start: CMTime.zero, duration: videoAsset.duration)
            do {
                try videoPlusSubtitles.insertTimeRange(range, of: videoAsset, at: CMTime.zero)
            }
            catch {
                print(error.localizedDescription)
                complition(.failure(CodersVideoPlayerMediaError.noCreate))
                
                
            }
            
            let subtitleTrack = videoPlusSubtitles.addMutableTrack(withMediaType: .text, preferredTrackID: kCMPersistentTrackID_Invalid)

            // extract the main track from subtitle asset
            if let firstSubtitleTrack = subtitleAsset.tracks.first {
                do {
                    try subtitleTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: videoPlusSubtitles.duration),
                                                        of: firstSubtitleTrack,
                                                        at: CMTime.zero)
                } catch {
                    print("something bad happend Adding subtitle track")
                    print("error: \(error.localizedDescription)")
                    complition(.failure(CodersVideoPlayerMediaError.noCreate))
                    
                }
            } else {
                print(print("something bad happend extracting subtitle track"))
            }

           
            
            let playerItem = AVPlayerItem(asset: videoPlusSubtitles)
            complition(.success(playerItem))
            
        }
        
    }
}


extension CodersVideoPlayerMedia {
    enum CodersVideoPlayerMediaError: Error {
        case noVideo
        case noCreate
    }
}
