//
//  Item.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
