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
    
    init(categoryName: String) {
        self.id = UUID()
        self.categoryName = categoryName
    }
}
