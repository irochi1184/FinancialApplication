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
    // 別にフォントサイズが変わるわけではない
    
    var body: some View {
        // フォーム
        Form {
            // トグルスイッチ
            Toggle("Show Previews", isOn: $showPreview)
            
            // スライドバー
            HStack{
                Text("Font Size (\(fontSize, specifier: "%.0f") pt)")
                Slider(value: $fontSize, in: 9...96) {
                    Text("Font Size (\(fontSize, specifier: "%.0f") pt)")
                }
            }
            
            // カウントステッパー
            Stepper(value: $fontSize, in : 9...96) {
                Text("Font Size (\(fontSize, specifier: "%.0f") pt)")
            }
            
            // テキスト入力エリア
            TextField("ユーザID", text: $userId)
        }
        
    }
}


#Preview {
    SettingView()
}
