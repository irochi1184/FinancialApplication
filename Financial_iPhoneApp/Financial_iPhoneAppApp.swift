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
    
    var body: some Scene {
        WindowGroup {
            if model.isReady {
                ContentView(model: model)
                    .environment(\.modelContext, model.container!.mainContext)
            } else {
                ProgressView("Loading...")
                    .onAppear {
                        Task {
                            await model.load()
                        }
                    }
            }
        }
        .onChange(of: scenePhase) {
            if model.isLock {
                if scenePhase == .background {
                    model.isUnlocked = false
                } else if scenePhase == .active {
                    // When the app becomes active again, show LockView if it is not unlocked
                    if !model.isUnlocked {
                        model.showLockView = true
                    }
                }
            }
        }
    }
}
