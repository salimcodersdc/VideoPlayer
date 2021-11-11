//
//  VideoProvider.swift
//  VideoPlayer
//
//  Created by Yousef on 9/30/21.
//

import UIKit

class VideoProvider {
    static func allVideos(complition: @escaping ([M3u8Media]) -> Void)  {
        //Minions Local
        /*
        let image = UIImage(named: "minions")!
        let mediaURL = Bundle.main.url(forResource: "Minions", withExtension: "m3u8")!
        let srtURL = Bundle.main.url(forResource: "MinionsHoliday", withExtension: "srt")!
        let mov1 = M3u8Media(
            title: "Minions Holyday",
            details: "Animation movie shows how minions spend thier christmass",
            thumbnail: image,
            mediaURL: mediaURL,
            srtURL: srtURL
        )
        */
        
        let appleURLString = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8"
        let appleMediaUrl = URL(string: appleURLString)!
        let appleImage = UIImage(systemName: "applelogo")!
        let appleSrtURL = Bundle.main.url(forResource: "MinionsHoliday", withExtension: "srt")!
        let appleMov = M3u8Media(
            id: 1,
            title: "Apple Test Video",
            details: "Apple Test Video",
            thumbnail: appleImage,
            mediaURL: appleMediaUrl,
            srtURL: appleSrtURL,
            isLiveStreaming: false
        )
        // "https://manar.live/iptv/index.m3u8"
        let DonnaTv = "https://streaming.softwarecreation.it/DonnaTv/DonnaTv/playlist.m3u8"
        let DonnaTvUrl = URL(string: DonnaTv)!
        let DonnaTvImage = UIImage(systemName: "applewatch")!
//        let appleSrtURL = Bundle.main.url(forResource: "MinionsHoliday", withExtension: "srt")!
        let DonnaTvMov = M3u8Media(
            id: 2,
            title: "Donna Tv",
            details: "Donna Tv",
            thumbnail: DonnaTvImage,
            mediaURL: DonnaTvUrl,
            srtURL: nil,
            isLiveStreaming: true
        )
        
        // https://nn.geo.joj.sk/live/hls/family-540.m3u8
        let JOJFamily = "https://nn.geo.joj.sk/live/hls/family-540.m3u8"
        let JOJFamilyURL = URL(string: JOJFamily)!
        let JOJFamilyImage = UIImage(systemName: "house")!
        let JOJFamilyMov = M3u8Media(
            id: 3,
            title: "JOJ Family",
            details: "JOJ Family",
            thumbnail: JOJFamilyImage,
            mediaURL: JOJFamilyURL,
            srtURL: nil,
            isLiveStreaming: true
        )
        
        // "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"
        // "http://45.10.201.84/uploaded/attachments/ac4b476f-594a-4dcc-8372-1388f00786fb.srt"
        // "https://bitmovin-a.akamaihd.net/content/MI201109210084_1/mpds/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.mpd"
        //  "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"
        // "https://storage.googleapis.com/exoplayer-test-media-1/mkv/android-screens-lavf-56.36.100-aac-avc-main-1280x720.mkv"
        let ForBiggerFunUrlString = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"
        let ForBiggerFunSRTUrlString = "http://45.10.201.84/uploaded/attachments/ac4b476f-594a-4dcc-8372-1388f00786fb.srt"
        
        let ForBiggerFunURL = URL(string: ForBiggerFunUrlString)!
        let ForBiggerFunSRTURL = URL(string: ForBiggerFunSRTUrlString)
        let ForBiggerFunImage = UIImage(systemName: "tv.music.note")
        
        let ForBiggerFunMov = M3u8Media(
            id: 4,
            title: "For Bigger Fun",
            details: "For Bigger Fun",
            thumbnail: ForBiggerFunImage,
            mediaURL: ForBiggerFunURL,
            srtURL: ForBiggerFunSRTURL,
            isLiveStreaming: false
        )
        
        complition([appleMov, DonnaTvMov, JOJFamilyMov, ForBiggerFunMov])
        
    }
}

