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
    
    @Environment(\.scenePhase) private var scenePhase
    
    let SetPass = UserDefaults.standard.bool(forKey: "SetPass")
    
    var body: some Scene {
        WindowGroup {
            if model.isReady {
                if SetPass {
                    // パスコードあり
                    LockView()
                        .environmentObject(model)
                        .environment(\.modelContext, model.container!.mainContext)
                } else {
                    ContentView(model: model)
                        .environmentObject(model)
                        .environment(\.modelContext, model.container!.mainContext)
                }
            } else {
                ProgressView("Loading...")
                    .onAppear {
                        Task {
                            await model.load()
                        }
                    }
            }
        }
    }
}
