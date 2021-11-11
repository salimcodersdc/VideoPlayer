//
//  MenusModels.swift
//  autolayoutTransation
//
//  Created by Yousef on 2/7/21.
//

import Foundation
import AVFoundation

//MARK: - Resolutions
public enum Resolutions: Int {
    case r360 = 360
    case r480 = 480
    case r720 = 720
    case r1080 = 1080
}

public enum OnOff: String {
    case on = "On"
    case off = "Off"
}

public enum FontSize: Int {
    case small = 8
    case medium = 10
    case larg = 12
    
    var title: String {
        switch self {
        
        case .small:
            return "Small"
        case .medium:
            return "Medium"
        case .larg:
            return "Larg"
        }
    }
    
    var labelFontSize: CGFloat {
        switch self {
        
        case .small:
            return 13
        case .medium:
            return 16
        case .larg:
            return 19
        }
    }
}


//MARK: - One options
public enum CodersAVMenuOneOptionsItemKey {
    case reportVideo
    
    var title: String {
        switch self {
        case .reportVideo: return "Report Video"
        }
        
    }
    
    var imageName: String {
        switch self {
        case .reportVideo: return "ic_report_video"
        }
        
    }
}

public struct CodersAVMenuOneOptionsItem {
    let key: CodersAVMenuOneOptionsItemKey
    
    public init(key: CodersAVMenuOneOptionsItemKey) {
        self.key = key
    }
}


//MARK: - tow options
public enum CodersAVMenuTowOptionsItemKey {
    case subtitle
    case autoNext
    case continueWatching
    
    var title: String {
        switch self {
        case .subtitle: return "Subtitle"
        case .autoNext: return "Auto Next"
        case .continueWatching: return "Continue Watching"
        }
        
    }
    
    var imageName: String {
        switch self {
        case .subtitle: return "ic_subtitles"
        case .autoNext: return "ic_autonext"
        case .continueWatching: return "ic_continue_watching"
        }
        
    }
}

public struct CodersAVMenuTowOptionsItem {
    let key: CodersAVMenuTowOptionsItemKey
    let firstOption: String
    let secondOption: String
    var selectedOption: Int
    
    public init(key: CodersAVMenuTowOptionsItemKey, firstOption: String, secondOption: String, selectedOption: Int) {
        self.key = key
        self.firstOption = firstOption
        self.secondOption = secondOption
        self.selectedOption = selectedOption
    }
}

//MARK: - three options
public enum CodersAVMenuThreeOptionsItemKey: String {
    case subtitleFont = "Subtitle Font"
    
    var title: String {
        switch self {
        
        case .subtitleFont: return "Subtitle Font"
        }
    }
    
    var imageName: String {
        switch self {
        
        case .subtitleFont: return "ic_continue_watching"
        }
    }
}

public struct CodersAVMenuThreeOptionsItem {
    let key: CodersAVMenuThreeOptionsItemKey
    let firstOption: String
    let secondOption: String
    let thirdOption: String
    var selectedOption: Int
    
    public init(key: CodersAVMenuThreeOptionsItemKey, firstOption: String, secondOption: String, thirdOption: String, selectedOption: Int) {
        self.key = key
        self.firstOption = firstOption
        self.secondOption = secondOption
        self.thirdOption = thirdOption
        self.selectedOption = selectedOption
    }
}

//MARK: - Four options
public enum CodersAVMenuFourOptionsItemKey: String {
    case quality = "Quality"
    
    var title: String {
        switch self {
        
        case .quality: return "Quality"
        }
    }
    
    var imageName: String {
        switch self {
        
        case .quality: return "ic_high_quality"
        }
    }
}

public struct CodersAVMenuFourOptionsItem {
    let key: CodersAVMenuFourOptionsItemKey
    let firstOption: String
    let secondOption: String
    let thirdOption: String
    let fourthOption: String
    var selectedOption: Int
    
    public init(key: CodersAVMenuFourOptionsItemKey, firstOption: String, secondOption: String, thirdOption: String, fourthOption: String, selectedOption: Int) {
        self.key = key
        self.firstOption = firstOption
        self.secondOption = secondOption
        self.thirdOption = thirdOption
        self.fourthOption = fourthOption
        self.selectedOption = selectedOption
    }
}


//MARK: - Quality options
public struct CodersAVMenuQualityOptionsItem {
    
    let resolutions: [VPResolution]
    var selectedOption: Int
    
    var title: String {
        return "Quality"
    }
    
    var imageName: String {
        return "ic_high_quality"
    }
    
}

//MARK: - the array item
public enum CodersAVMenuItem {
    case oneOption(model: CodersAVMenuOneOptionsItem)
    case towOptions(model: CodersAVMenuTowOptionsItem)
    case threeOptions(model: CodersAVMenuThreeOptionsItem)
    case fourOptions(model: CodersAVMenuFourOptionsItem)
    case quality(model: CodersAVMenuQualityOptionsItem)
}


