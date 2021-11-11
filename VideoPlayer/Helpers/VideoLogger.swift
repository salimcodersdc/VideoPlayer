//
//  VideoLogger.swift
//  VideoPlayer
//
//  Created by Yousef on 10/5/21.
//

import Foundation
import Combine

class VideoLogger {
    
    static var shared = VideoLogger()
    
    var text = CurrentValueSubject<String, Never>("")
    var append = PassthroughSubject<String, Never>()
    var clear = PassthroughSubject<Bool, Never>()
    
    private var calcellables = Set<AnyCancellable>()
    
    private init() {
        addSubcripers()
    }
    
    private func addSubcripers() {
        append
            .sink { [unowned self] newString in
                let now = Date()
                text.value = text.value + "\n" + "\(now.time)\t\(newString)" 
            }
            .store(in: &calcellables)
        
        clear
            .sink { [unowned self] _ in
                text.value = ""
            }
            .store(in: &calcellables)
    }
    
}
