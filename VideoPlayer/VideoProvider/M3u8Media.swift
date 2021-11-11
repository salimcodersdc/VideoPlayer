//
//  M3u8Media.swift
//  VideoPlayer
//
//  Created by Yousef on 10/3/21.
//

import UIKit
import AVFoundation


let assetKeysRequiredToPlay = [
        "playable",
        "tracks",
        "duration"
    ]


//MARK: - M3U8Model
public class M3u8Media: NSObject, CodersMedia {
    
    
    public let id: Int
    public let title: String
    public let details: String
    public let thumbnail: UIImage?
    public let mediaURL: URL
    public let srtURL: URL?
    public let isLiveStreaming: Bool
    
    public init(id: Int, title: String, details: String, thumbnail: UIImage? = nil, mediaURL: URL, srtURL: URL?, isLiveStreaming: Bool) {
        self.id = id
        self.title = title
        self.details = details
        self.thumbnail = thumbnail
        self.mediaURL = mediaURL
        self.srtURL = srtURL
        self.isLiveStreaming = isLiveStreaming
    }
}
