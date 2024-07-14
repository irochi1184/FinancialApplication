//
//  SettingView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/29.
//

import SwiftUI

struct SettingView: View {
    @AppStorage("isLock") private var isLock = false
    @AppStorage("fontSize") private var fontSize = 12.0
    @AppStorage("userId") private var userId = ""
    @AppStorage("monthlyLimitAmount") private var monthlyLimitAmount = 100000
    @EnvironmentObject var model: AppModel
    
    @FocusState private var isNumberPadActive: Bool
    
    @State private var isSettingPasscode = false
    @State private var toggle = UserDefaults.standard.bool(forKey: "SetPass")
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("金額設定")) {
                    HStack {
                        Text("月の限度額")
                        TextField("限度額を入力", value: $monthlyLimitAmount, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($isNumberPadActive)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("閉じる") {
                                        isNumberPadActive = false
                                    }
                                }
                            }
                    }
                }
                Section(header: Text("遷移")) {
                    NavigationLink {
                        CategorySettingsView()
                    } label: {
                        Text("カテゴリー設定")
                    }
                }
                Toggle("パスコード設定", isOn: $toggle)
                    .onChange(of: toggle) {
                        if toggle {
                            isSettingPasscode = true
                        } else {
                            UserDefaults.standard.set(false, forKey: "SetPass")
                            UserDefaults.standard.set(false, forKey: "UseFaceID")
                        }
                    }
            }
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $isSettingPasscode) {
                PasscodeSetupView(isSettingPasscode: $isSettingPasscode, toggle: $toggle)
                    .environmentObject(model.passcodeManager)
            }
        }
    }
}

#Preview {
    ContentView(model: AppModel())
        .modelContainer(for: [CategoryData.self, TransactionData.self], inMemory: true)
}
