//
//  LockView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/13.
//

import SwiftUI

struct LockView: View {
    
    @EnvironmentObject var model: AppModel
    
    @State var passCheck: [String?] = [nil, nil, nil, nil]
    @EnvironmentObject var passcheck: passCheck
    
    // -> trueでcontentViewを表示
    @State var isShow = false
    
    // 設定したパスワード
    let answer = UserDefaults.standard.string(forKey: "password")
    
    // FaceID関連
    let face: FaceAuth = FaceAuth()
    let useFaceID = UserDefaults.standard.bool(forKey: "UseFaceID")
    
    // パスワード間違いメッセージ表示用
    @State private var showError = false
    
    // カラー設定
    @State private var buttonText = Color.mint
    @State private var buttonBack = Color.white
    
    var body: some View {
        ZStack {
            VStack {
                // スペースを追加して、ナビゲーションバーとキャンセルボタンの間に余白を作成
                Spacer().frame(height: 100)
                
                Spacer()
                Text("パスコードの入力")
                    .font(.title3)
                    .fontWeight(.bold)
                
                HStack {
                    // 黒丸
                    ForEach(0..<4) { index in
                        if passCheck[index] == nil {
                            Image(systemName: "circle")
                                .padding()
                        } else {
                            Image(systemName: "circle.fill")
                                .padding()
                        }
                    }
                }
                
                if showError {
                    Text("パスワードが間違っています")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.pink)
                }
                
                Spacer()
                
                // 入力ボタン
                VStack(spacing: 10) {
                    ForEach(buttonRows, id: \.self) { row in
                        HStack(spacing: 10) {
                            ForEach(row, id: \.self) { number in
                                createButton(number: number)
                            }
                        }
                    }
                    HStack(spacing: 10) {
                        createButton(number: 0)
                    }
                }
                Spacer()
                    .onAppear {
                        // faceidをするかどうか
                        if useFaceID {
                            exec()
                        }
                    }
            }
            
            if isShow {
                ContentView(model: model)
                    .environment(\.modelContext, model.container!.mainContext)
                    .environmentObject(model.passcodeManager)
                    .transition(.opacity)
            }
        }
    }
    
    private let buttonRows: [[Int]] = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
    ]
    
    private func createButton(number: Int) -> some View {
        Button {
            inputText(number: String(number))
        } label: {
            Text("\(number)")
                .font(.title)
                .frame(width: 70, height: 70)
                .foregroundColor(buttonText)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(buttonText, lineWidth: 1.0)
                )
        }
        .background(buttonBack)
        .cornerRadius(50)
        .shadow(color: .gray, radius: 3, x: 1, y: 1)
        .padding()
    }
    
    // 入力関数
    private func inputText(number: String) {
        var checkAnswer = ""
        
        for (index, getText) in passCheck.enumerated() {
            // nilかチェック -> 入力済みならスキップ
            // 入力したらfor文を抜け出す
            if getText == nil {
                passCheck[index] = number
                if index == 3 {
                    for i in 0...3 {
                        checkAnswer += (passCheck[i] ?? "")
                    }
                    if checkAnswer == answer {
                        // 一致
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                isShow.toggle()
                            }
                        }
                    } else {
                        // 初期化
                        passCheck = [nil, nil, nil, nil]
                        showError = true
                    }
                }
                break
            }
        }
    }
    
    // 顔認証の関数
    func exec() {
        face.auth { result in
            // 認証が成功した時の記述
            if result == true {
                passCheck = ["a", "a", "a", "a"]
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        isShow.toggle()
                    }
                }
            }
        }
    }
}
