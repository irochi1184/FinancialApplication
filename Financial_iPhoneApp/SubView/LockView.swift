//
//  LockView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/13.
//

import Foundation
import LocalAuthentication
import SwiftUI

struct LockView: View {
    @ObservedObject var model: AppModel
    @State private var isUnlocked = false
    
    var body: some View {
        VStack {
            if isUnlocked {
                ContentView()
                    .environment(\.modelContext, model.container!.mainContext) // データ保存用
            } else {
                Text("Locked")
                Button("Authenticate") {
                    authenticate()
                }
            }
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason: String
            if context.biometryType == .faceID {
                reason = "Face IDを使用してデータのロックを解除します。"
            } else if context.biometryType == .touchID {
                reason = "Touch IDを使用してデータのロックを解除します。"
            } else {
                reason = "デバイスの認証を使用してデータのロックを解除します。"
            }
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {
                    // authenticated successfully
                    DispatchQueue.main.async {
                        isUnlocked = true
                    }
                } else {
                    // there was a problem
                    // Handle the error here if needed
                }
            }
        } else {
            // no biometrics
            // Handle the lack of biometry support here if needed
        }
    }
}
