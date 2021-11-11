//
//  VideoPlayerModels.swift
//  autolayoutTransation
//
//  Created by Yousef on 2/7/21.
//

import Foundation
import AVFoundation


enum AudioMediaCharacteristicType: String {
    case sound = "Sound"
    case unknown = "Unknown"
}

struct AudioMediaCharacteristic {

    let language: String
    let mediaType: AudioMediaCharacteristicType
    let title: String
    let isDefault: Bool
    
    var type: String {
        return mediaType.rawValue
    }
    
    var description: String {
        return """
                title: \(title)
                language: \(language)
                mediaType: \(mediaType.rawValue)
                default: \(isDefault)
                """
    }
    
}


enum LegibleMediaCharacteristicType: String {
    case closedCaption = "Closed Caption"
    case subtitle = "Subtitle"
    case unknown = "Unknown"
}

struct LegibleMediaCharacteristic {
    let language: String
    let mediaType: LegibleMediaCharacteristicType
    let title: String
    let isDefault: Bool
    let package: AVMediaSelectionOption
    
    var type: String {
        return mediaType.rawValue
    }
    
    var description: String {
        return """
                title: \(title)
                language: \(language)
                mediaType: \(mediaType.rawValue)
                default: \(isDefault)
                """
    }
}

//MARK: - AVPlayerDefaults

public struct AVPlayerDefaults {
    var quality: VPResolution?
    var isSubtitilesOn: Bool
    var subtitlesSize: FontSize
    var autoNext: Bool
    var continueWatching: Bool
    var hasSubtitles: Bool
    var subtitles: AVMediaSelectionOption?
    var selectedQuality: Int = 0
   /*
     var selectedQuality: Int {
         switch quality {
         
         case .r360:
             return 1
         case .r480:
             return 2
         case .r720:
             return 3
         case .r1080:
             return 4
         }
     }
     */
    
    var selectedSubtitilesOn: Int {
        return isSubtitilesOn ? 1 : 2
    }
    
    var selectedFontSize: Int {
        switch subtitlesSize {
        
        case .small:
            return 1
        case .medium:
            return 2
        case .larg:
            return 3
        }
    }
    
    var selectedAutoNext: Int {
        return autoNext ? 1 : 2
    }
    
    var selectedContinueWatching: Int {
        return continueWatching ? 1 : 2
    }
    
    public init(quality: VPResolution? = nil,
                isSubtitilesOn: Bool = false,
                subtitlesSize: FontSize = .small,
                autoNext: Bool = true,
                continueWatching: Bool = true,
                hasSubtitles: Bool = false,
                subtitles: AVMediaSelectionOption? = nil) {
        self.quality = quality
        self.isSubtitilesOn = isSubtitilesOn
        self.subtitlesSize = subtitlesSize
        self.autoNext = autoNext
        self.continueWatching = continueWatching
        self.hasSubtitles = hasSubtitles
        self.subtitles = subtitles
        
        
    }
}
