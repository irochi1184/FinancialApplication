//
//  CategoryData.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/08.
//

import Foundation
import SwiftData

@Model
final class CategoryData: Identifiable {
    var id: UUID
    var categoryName: String
    var order: Int // 並べ替えの順序を表すプロパティを追加
    var toggle: Bool
    
    init(categoryName: String, order: Int = 0, toggle: Bool = true) {
        self.id = UUID()
        self.categoryName = categoryName
        self.order = order
        self.toggle = toggle
    }
}
