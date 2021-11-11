//
//  Date+Extension.swift
//  VideoPlayer
//
//  Created by Yousef on 10/5/21.
//

import Foundation


fileprivate class DateManager {
    
    static var shared = DateManager()
    
    private var formatter = DateFormatter()
    
    private init() { }
    
    func time(_ date: Date) -> String {
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
}

extension Date {
    var time: String {
        return DateManager.shared.time(self)
    }
}
