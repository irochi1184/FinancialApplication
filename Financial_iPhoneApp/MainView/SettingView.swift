//
//  SettingView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/29.
//

import SwiftUI

struct SettingView: View {
    
    // プロパティ(UserDefaultsに保持)
    @AppStorage("isLock") private var isLock = false
    @AppStorage("fontSize") private var fontSize = 12.0
    @AppStorage("userId") private var userId = ""
    @AppStorage("monthlyLimitAmount") private var monthlyLimitAmount = 100000 // 月の限度額
    @EnvironmentObject var model: AppModel
    
    @FocusState  var isNumberPadActive:Bool // numberPad閉じる用
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("金額設定")) {
                    HStack {
                        Text("月の限度額")
                        TextField("限度額を入力", value: $monthlyLimitAmount, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(TextAlignment.trailing)
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
                
                Toggle("画面ロック", isOn: $isLock)
                    .onChange(of: isLock) {
                        if isLock {
                            model.showLockView = false // トグルを変更した直後にロック画面に遷移しない
                        }
                    }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .id(UUID())
        }
    }
}
