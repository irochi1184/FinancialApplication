//
//  AppModel.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/13.
//

import SwiftUI
import SwiftData

class AppModel: ObservableObject {
    @Published var isReady = false
    @Published var passcodeManager = passCheck()
    var container: ModelContainer?
    
    private let defaultCategories = ["食費", "雑費", "家賃", "娯楽費", "電気代", "水道代", "交通費", "書籍代"]
    private let defaultsKey = "isAppAlreadyLaunchedOnce"
    
    @MainActor
    func load() async {
        do {
            container = try ModelContainer(for: TransactionData.self, CategoryData.self)
            await addDefaultCategoriesIfNeeded()
            self.isReady = true
        } catch {
            print("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    @MainActor
    private func addDefaultCategoriesIfNeeded() async {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: defaultsKey) == false, let context = container?.mainContext {
            for categoryName in defaultCategories {
                let newCategory = CategoryData(categoryName: categoryName)
                context.insert(newCategory)
            }
            do {
                try context.save()
                defaults.set(true, forKey: defaultsKey)
            } catch {
                print("Failed to save default categories: \(error)")
            }
        }
    }
}
