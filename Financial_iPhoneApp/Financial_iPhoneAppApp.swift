//
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
                ContentView()
                    .environment(\.modelContext, model.container!.mainContext) // データ保存用
            } else {
                ProgressView("Loading...") // ロード中の表示
                    .onAppear {
                        model.load()
                    }
            }
        }
    }
}

class AppModel: ObservableObject {
    @Published var isReady = false
    var container: ModelContainer?
    
    func load() {
        do {
            container = try ModelContainer(for: TransactionData.self)
            self.isReady = true
        } catch {
            print("Failed to initialize ModelContainer: \(error)")
            // 必要に応じてエラーハンドリングを追加
        }
    }
}

