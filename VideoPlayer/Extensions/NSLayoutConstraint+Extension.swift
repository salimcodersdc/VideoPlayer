//
//  NSLayoutConstraint+Extension.swift
//  VideoPlayer
//
//  Created by Yousef on 10/7/21.
//

import UIKit

extension NSLayoutConstraint {
    override public var description: String {
        let id = identifier ?? ""
        var first: String = ""
        var second: String = ""
        if let firstItem = firstItem as? UIView {
            first = "\(firstItem.tag)"
        }
        if let secondItem = secondItem as? UIView {
            second = "\(secondItem.tag)"
        }
        return "id: \(id), firstItem: \(first), secondItem: \(second), constant: \(constant)" //you may print whatever you want here
    }
}
