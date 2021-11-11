//
//  VPMedia.swift
//  autolayoutTransation
//
//  Created by Yousef on 2/4/21.
//

// "https://cdn-temp-02.scopesky.iq/share/uploads/movies/srt/01d3cc328acd9aaa27500c54887f1fe6ee293d30ef17ce8ada9540e774228a45_1607254966.srt"

import Foundation
import AVFoundation
import AVKit

public enum VPLanguage: String {
    case english = "en"
    case arabic = "ar"
}

public struct VPSubtitle {
    public let URL: String
    public let language: VPLanguage
    
    public init(URL: String, language: VPLanguage) {
        self.URL = URL
        self.language = language
    }
}

public struct VPResolution {
    public let bandWidth: Double
    public let title: String
    public let URI: String
    
    public init(bandWidth: Double, title: String, URI: String) {
        self.bandWidth = bandWidth
        self.title = title
        self.URI = URI
    }
    
    public init?(_ text: String) {
        guard Int(String(text.first!)) != nil else { return nil }
        let components = text.components(separatedBy: "\n")
        if components[1].hasPrefix("#") { return nil}
        let res = (components[0].components(separatedBy: ","))[0]
        let first = (res.components(separatedBy: "x"))[1]
        self.bandWidth = 0
        self.title = first
        self.URI = components[1]
    }
}

enum VPMediaType {
    case m3u8
    case Composition
}

//MARK: - VPMedia

/**
@class VPMedia
 @abstract
    These constants can be used to specify basic values for any meida type.
 
 @property     title
    String: title for the media for displaying.
 @property     details
    String: short description about media content.
 @property     thumbnail
    UIImage optional: image represent the media
 @func     playerItem
    return AVPlayer Item represent the media
 */
public class VPMedia: NSObject {
    public let title: String
    public let details: String
    public let thumbnail: UIImage?
    
    public init(title: String, details: String, thumbnail: UIImage? = nil) {
        self.title = title
        self.details = details
        self.thumbnail = thumbnail
    }
    
    /// func return optional AVPlayerItem represent the Media
    public func playerItem() -> AVPlayerItem? {
        return nil
    }

}

//MARK: - M3U8Model
public class M3U8Model: VPMedia {
    let mediaURL: URL
    let baseURL: String
    let resolutions: [VPResolution]
    let subtitles: [VPSubtitle]
    
    public init(title: String, details: String, thumbnail: UIImage? = nil, mediaURL: URL, baseURL: String, resolutions: [VPResolution] = [], subtitles: [VPSubtitle] = []) {
        
        self.mediaURL = mediaURL
        self.baseURL = baseURL
        self.resolutions = resolutions
        self.subtitles = subtitles
        super.init(title: title, details: details, thumbnail: thumbnail)
    }
    
    public override func playerItem() -> AVPlayerItem? {
        let asset = AVURLAsset(url: mediaURL)
        let result = AVPlayerItem(asset: asset)
        return result
    }
}

//MARK: - M3U8Model
public class M3U8ModelWithSubtitle: VPMedia {
    let mediaURL: URL
    var srtURL: URL?
    var vttURL: URL?
    
    public init(title: String, details: String, thumbnail: UIImage? = nil, mediaURL: URL, srtURL: URL? = nil, vttURL: URL? = nil) {
        
        self.mediaURL = mediaURL
        self.srtURL = srtURL
        self.vttURL = vttURL
        super.init(title: title, details: details, thumbnail: thumbnail)
    }
    
    public override func playerItem() -> AVPlayerItem? {
        if vttURL != nil {
            srtURL = nil
        }
        
        if let srtURL = srtURL {
            return M3U8PlusSRT(srtURL: srtURL)
        } else if let vttURL = vttURL {
            return M3U8PlusVTT(vttURL: vttURL)
        } else {
            let asset = AVURLAsset(url: mediaURL)
            let result = AVPlayerItem(asset: asset)
            return result
        }
    }
    
    private func M3U8PlusSRT(srtURL: URL) -> AVPlayerItem? {
        let sc = CodersSubtitleConverter()
        guard let vtt = sc.srtToVtt(srtFileURL: srtURL.absoluteString) else { return nil}
        return M3U8PlusVTT(vttURL: vtt)
    }
    
    private func M3U8PlusVTT(vttURL: URL) -> AVPlayerItem? {
        return M3U8PlusSubtitles(vttURL: vttURL)
    }
    
    private func M3U8PlusSRTAsync(srtURL: URL, complition: @escaping (Result<AVPlayerItem, Error>) -> ()) {
        let sc = CodersSubtitleConverter()
        if  let vtt = sc.srtToVtt(srtFileURL: srtURL.absoluteString) {
            M3U8PlusVTTAsync(vttURL: vtt) { (res) in
                complition(res)
            }
        } else {
            complition(.failure(VPMediaError.noCreate))
        }
        
    }
    
    private func M3U8PlusVTTAsync(vttURL: URL, complition: @escaping (Result<AVPlayerItem, Error>) -> ()) {
        M3U8PlusSubtitlesAsync(vttURL: vttURL) { (res) in
            complition(res)
        }
    }
    
    func getPlayerItem(complition: @escaping (Result<AVPlayerItem, Error>) -> ()) {
        if vttURL != nil {
            srtURL = nil
        }
        
        if let srtURL = srtURL {
            M3U8PlusSRTAsync(srtURL: srtURL) { (res) in
                complition(res)
            }
        } else if let vttURL = vttURL {
            M3U8PlusVTTAsync(vttURL: vttURL) { (res) in
                complition(res)
            }
        } else {
            let asset = AVURLAsset(url: mediaURL)
            let result = AVPlayerItem(asset: asset)
            complition(.success(result))
        }
    }
    
    private func M3U8PlusSubtitlesAsync(vttURL: URL, complition: @escaping (Result<AVPlayerItem, Error>) -> ()) {
        let videoAsset = AVURLAsset(url: mediaURL)
        
        let subtitleAsset = AVURLAsset(url: vttURL)
        
        let videoPlusSubtitles = AVMutableComposition()
        print("***************************************************")
//        print(videoPlusSubtitles)
        
        videoAsset.loadValuesAsynchronously(forKeys: assetKeysRequiredToPlay) {
            
            let range = CMTimeRange(start: CMTime.zero, duration: videoAsset.duration)
            do {
                try videoPlusSubtitles.insertTimeRange(range, of: videoAsset, at: CMTime.zero)
            }
            catch {
                print(error.localizedDescription)
                complition(.failure(VPMediaError.noCreate))
                
                
            }
            
            
//            print("videoAsset: \(videoAsset.tracks)")
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
                    complition(.failure(VPMediaError.noCreate))
                    
                }
            } else {
                print(print("something bad happend extracting subtitle track"))
//                return nil
            }

           
            
            let playerItem = AVPlayerItem(asset: videoPlusSubtitles)
            complition(.success(playerItem))
            
        }
        /*
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
        */
        
    }
    
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
}

//MARK: - MP4Model
public class MP4Model: VPMedia {
    let mediaURL: URL
    var srtURL: URL?
    var vttURL: URL?
    
    public init(title: String, details: String, thumbnail: UIImage? = nil, mediaURL: URL, srtURL: URL? = nil, vttURL: URL? = nil) {
        
        self.mediaURL = mediaURL
        self.srtURL = srtURL
        self.vttURL = vttURL
        super.init(title: title, details: details, thumbnail: thumbnail)
    }
    
    public override func playerItem() -> AVPlayerItem? {
        if vttURL != nil {
            srtURL = nil
        }
        
        if let srtURL = srtURL {
            return MP4PlusSRT(srtURL: srtURL)
        } else if let vttURL = vttURL {
            return MP4PlusVTT(vttURL: vttURL)
        } else {
            let asset = AVURLAsset(url: mediaURL)
            let result = AVPlayerItem(asset: asset)
            return result
        }
    }
    
    func playerItemAsync(complition: @escaping (Result<AVAsset, Error>) -> ()) {
        if vttURL != nil {
            srtURL = nil
        }
        
        if let srtURL = srtURL {
            let vc = CodersSubtitleConverter()
            vttURL = vc.srtToVtt(srtFileURL: srtURL.absoluteString)
            
        }
        
        if let vttURL = vttURL {
            MP4PlusTest(vttURL: vttURL) { (result) in
                complition(result)
            }
        } else {
            let asset = AVURLAsset(url: mediaURL)
//            let result = AVPlayerItem(asset: asset)
            complition(.success(asset))
        }
        
    }
    
    private func MP4PlusSRT(srtURL: URL) -> AVPlayerItem? {
        let sc = CodersSubtitleConverter()
        guard let url = sc.srtToVtt(srtFileURL: srtURL.absoluteString) else {
            return nil
        }
        
        return MP4PlusSubtitles(vttURL: url)
    }
    
    private func MP4PlusVTT(vttURL: URL) -> AVPlayerItem? {
    
        return MP4PlusSubtitles(vttURL: vttURL)
        
    }
    
    private func MP4PlusTest(vttURL: URL, complition: @escaping (Result<AVAsset, Error>) -> ()) {
        let videoAsset = AVURLAsset(url: mediaURL)
        
        let subtitleAsset = AVURLAsset(url: vttURL)
        
        let videoPlusSubtitles = AVMutableComposition(url: mediaURL)
        
        
        
        videoAsset.loadValuesAsynchronously(forKeys: assetKeysRequiredToPlay, completionHandler: {
            
            print("videoAsset tracks:")
            print(videoAsset.tracks)
            
            // create video track to be added to the mutable composition
            let videoTrack = videoPlusSubtitles.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            // extract the main track from video asset
            let videoAssetVideoMedias = videoAsset.tracks(withMediaType: .video)
            guard let firstVideoTrack = videoAssetVideoMedias.first else {
                print(print("something bad happend extracting video track"))
                DispatchQueue.main.async {
                    complition(.failure(VPMediaError.noVideo))
                }
                
                return
            }

            do {

                try videoTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: videoAsset.duration),
                                                of: firstVideoTrack,
                                                at: CMTime.zero)
            } catch {
                print("something bad happend Adding video track")
                print("error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    complition(.failure(VPMediaError.noVideo))
                }
            }

            
            // create sound track to be added to the mutable composition
            let soundTrack = videoPlusSubtitles.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            // extract the main track from video asset
            let videoAssetSoundMedias = videoAsset.tracks(withMediaType: .audio)
            if let firstSoundTrack = videoAssetSoundMedias.first {
                do {

                    try soundTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: videoAsset.duration),
                                                    of: firstSoundTrack,
                                                    at: CMTime.zero)
                } catch {
                    print("something bad happend Adding sound track")
                    print("error: \(error.localizedDescription)")
                }
            } else {
                print(print("something bad happend extracting Sound track"))
                
            }

            
            
            subtitleAsset.loadValuesAsynchronously(forKeys: assetKeysRequiredToPlay) {
                
                print("subtitleAsset.tracks")
                print(subtitleAsset.tracks)
                
                if subtitleAsset.tracks.count > 0 {
                    let subtitleTrack = videoPlusSubtitles.addMutableTrack(withMediaType: .text, preferredTrackID: kCMPersistentTrackID_Invalid)

                    // extract the main track from subtitle asset
                    if let firstSubtitleTrack = subtitleAsset.tracks.first {
                        do {
                            try subtitleTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: videoPlusSubtitles.duration),
                                                                of: firstSubtitleTrack,
                                                                at: CMTime.zero)
                            
//                            let playerItem = AVPlayerItem(asset: videoPlusSubtitles)
                            print("videoPlusSubtitles.tracks")
                            print(videoPlusSubtitles.tracks)
                            DispatchQueue.main.async {
                                complition(.success(videoPlusSubtitles))
                            }
                        } catch {
                            print("something bad happend Adding subtitle track")
                            print("error: \(error.localizedDescription)")
                            complition(.failure(VPMediaError.noCreate))
                        }
                    } else {
                        print(print("something bad happend extracting subtitle track"))
                        complition(.failure(VPMediaError.noCreate))
                    }

                    
                }
                
                
                
                
            }
            
        })
        
        
        
        
        
        
        
        
    }
    
    private func MP4PlusSubtitles(vttURL: URL) -> AVPlayerItem? {
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
}

//MARK: - MP3Model
public class MP3Model: VPMedia {
    let mediaURL: URL
    var srtURL: URL?
    let vttURL: URL?
    
    public init(title: String, details: String, thumbnail: UIImage? = nil, mediaURL: URL, srtURL: URL? = nil, vttURL: URL? = nil) {
        
        self.mediaURL = mediaURL
        self.srtURL = srtURL
        self.vttURL = vttURL
        super.init(title: title, details: details, thumbnail: thumbnail)
    }
    
    public override func playerItem() -> AVPlayerItem? {
        if vttURL != nil {
            srtURL = nil
        }
        
        if let srtURL = srtURL {
            return audioWithsrt(srtURL: srtURL)
        } else if let vttURL = vttURL {
            return audioWithVTT(vttURL: vttURL)
        } else {
            let asset = AVURLAsset(url: mediaURL)
            let result = AVPlayerItem(asset: asset)
            return result
        }
    }
    
    private func audioWithsrt(srtURL: URL) -> AVPlayerItem? {
        let sc = CodersSubtitleConverter()
        guard let url = sc.srtToVtt(srtFileURL: srtURL.absoluteString) else {
            return nil
        }
        
        return audioWithVTT(vttURL: url)
    }
    
    private func audioWithVTT(vttURL: URL) -> AVPlayerItem? {
        return audioWithsubtitle(vttURL: vttURL)
    }
    
    private func audioWithsubtitle(vttURL: URL) -> AVPlayerItem? {
        //Create AVMutableComposition
        let videoPlusSubtitles = AVMutableComposition()
        
        // create mp3 asset
        let MP3Asset = AVURLAsset(url: mediaURL)
        
        // create subtitle asset
        let subtitleAsset = AVURLAsset(url: vttURL)
        
        
        // create video track to be added to the mutable composition
        let soundTrack = videoPlusSubtitles.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        // extract the main track from video asset
        let videoPlusSubtitlesAudioMedia = MP3Asset.tracks(withMediaType: .audio)
        guard let firstSoundTrack = videoPlusSubtitlesAudioMedia.first else {
            print(print("something bad happend extracting sound track"))
            return nil
        }
        
        do {
            try soundTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: MP3Asset.duration),
                                            of: firstSoundTrack,
                                            at: CMTime.zero)
        } catch {
            print("something bad happend adding sound track")
            print("error: \(error.localizedDescription)")
            return nil
        }
        
        
        
        print("**************************************")
        print("\(subtitleAsset)")
        print("subtitleAssetTextMedias: \(String(describing: subtitleAsset.tracks))")
        print("**************************************")
        
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
        
        
        
        // Create AVPLayer
        let playerItem = AVPlayerItem(asset: videoPlusSubtitles)
        
        return playerItem
    }
}

enum VPMediaError: Error {
    case noVideo
    case noCreate
}

extension VPMediaError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noVideo: return NSLocalizedString("Unable to extract video track", comment: "")
        case .noCreate: return NSLocalizedString("Unable to create asset", comment: "")
        }
    }
}

