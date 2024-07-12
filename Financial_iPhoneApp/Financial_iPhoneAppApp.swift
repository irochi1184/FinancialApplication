//  Financial_iPhoneAppApp.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/26.
//

import SwiftUI
import SwiftData

@main
struct Financial_iPhoneAppApp: App {
    @StateObject private var model = AppModel()
    
    var body: some Scene {
        WindowGroup {
            if model.isReady {
                LockView(model: model)
                    .environment(\.modelContext, model.container!.mainContext) // データ保存用
            } else {
                ProgressView("Loading...") // ロード中の表示
                    .onAppear {
                        Task {
                            await model.load()
                        }
                    }
            }
        }
    }
}

class AppModel: ObservableObject {
    @Published var isReady = false
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
            // 必要に応じてエラーハンドリングを追加
        }
    }
    
    @MainActor
    private func addDefaultCategoriesIfNeeded() async {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: defaultsKey) == false, let context = container?.mainContext {
            // 初回起動時の処理
            for categoryName in defaultCategories {
                let newCategory = CategoryData(categoryName: categoryName)
                context.insert(newCategory)
            }
            do {
                try context.save()
                // フラグを設定
                defaults.set(true, forKey: defaultsKey)
            } catch {
                print("Failed to save default categories: \(error)")
            }
        }
    }
}
