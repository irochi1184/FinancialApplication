//
//  SettingView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/29.
//

import SwiftUI

struct SettingView: View {
    
    // プロパティ(UserDefaultsに保持)
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 12.0
    @AppStorage("userId") private var userId = ""
    @AppStorage("monthlyLimitAmount") private var monthlyLimitAmount = 100000 // 月の限度額
    
    @FocusState  var isNumberPadActive:Bool // numberPad閉じる用
    
    
    var body: some View {
        
        NavigationView {
            List {
                Section(header: Text("金額設定")) {
                    HStack {
                        Text("月の限度額")
                        TextField("限度額を入力", value: $monthlyLimitAmount, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(TextAlignment.trailing) // 右寄せ
                            .focused($isNumberPadActive)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()         // 右寄せにする
                                    Button("閉じる") {
                                        isNumberPadActive = false  //  フォーカスを外す
                                    }
                                }
                            }
                    }
                }
                Section(header: Text("遷移")) {
//                    NavigationLink {
//                        TestA()
//                    } label: {
//                        Text("設定A")
//                    }
//                    NavigationLink {
//                        TestB()
//                    } label: {
//                        Text("設定B")
//                    }
                    NavigationLink {
                        CategorySettingsView()
                    } label: {
                        Text("カテゴリー設定")
                    }
                }
//                Section(header: Text("いろいろ")) {
//                    Text("りんご")
//                    Toggle("Show Previews", isOn: $showPreview)
//                    // スライドバー
//                    HStack {
//                        Text("Font Size (\(fontSize, specifier: "%.0f") pt)")
//                        Slider(value: $fontSize, in: 9...96) {
//                            Text("Font Size (\(fontSize, specifier: "%.0f") pt)")
//                        }
//                    }
//                    // カウントステッパー
//                    Stepper(value: $fontSize, in: 9...96) {
//                        Text("Font Size (\(fontSize, specifier: "%.0f") pt)")
//                    }
//                    
//                    // テキスト入力エリア
//                    TextField("ユーザID", text: $userId)
//                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .id(UUID())
        }
    }
}

//struct TestA: View {
//    var body: some View {
//        Text("きた")
//    }
//}
//
//struct TestB: View {
//    var body: some View {
//        Text("これ")
//    }
//}

#Preview {
    ContentView()
        .modelContainer(for: [CategoryData.self, TransactionData.self], inMemory: true)
}
