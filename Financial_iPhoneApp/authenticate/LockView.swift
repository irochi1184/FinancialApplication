//
//  LockView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/13.
//

import SwiftUI

struct LockView: View {
    
    @EnvironmentObject var model: AppModel // アプリモデルの環境オブジェクト
    
    @State var passCheck: [String?] = [nil, nil, nil, nil] // パスコードチェック用の状態変数
    @EnvironmentObject var passcheck: passCheck // パスワードチェック用の環境オブジェクト
    
    // -> trueでcontentViewを表示
    @State var isShow = false // コンテンツビューの表示状態
    
    // 設定したパスワード
    let answer = UserDefaults.standard.string(forKey: "password")
    
    // FaceID関連
    let face: FaceAuth = FaceAuth()
    let useFaceID = UserDefaults.standard.bool(forKey: "UseFaceID")
    
    // パスワード間違いメッセージ表示用
    @State private var showError = false
    
    // カラー設定
    @State private var buttonText = Color.mint // ボタンテキストの色
    @State private var buttonBack = Color.white // ボタン背景の色
    
    var body: some View {
        ZStack {
            VStack {
                // スペースを追加して、ナビゲーションバーとキャンセルボタンの間に余白を作成
                Spacer().frame(height: 100)
                
                Spacer()
                Text("パスコードの入力")
                    .font(.title3)
                    .fontWeight(.bold)
                
                // パスコード入力の視覚的表示
                HStack {
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
                    // パスワード間違いメッセージの表示
                    Text("パスワードが間違っています")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.pink)
                }
                
                Spacer()
                
                // 入力ボタン
                VStack(spacing: 10) {
                    // 1-9までのボタンを行ごとに表示
                    ForEach(buttonRows, id: \.self) { row in
                        HStack(spacing: 10) {
                            ForEach(row, id: \.self) { number in
                                createButton(number: number)
                            }
                        }
                    }
                    // 0と削除ボタンを表示
                    HStack(spacing: 10) {
                        Spacer().frame(width: 100, alignment: .leading)
                        createButton(number: 0)
                        createButton(number: -1) // 削除ボタン
                    }
                }
                
                Spacer()
                    .onAppear {
                        // FaceIDを使用するかどうかのチェック
                        if useFaceID {
                            exec()
                        }
                    }
            }
            
            if isShow {
                // コンテンツビューの表示
                ContentView(model: model)
                    .environment(\.modelContext, model.container!.mainContext)
                    .environmentObject(model.passcodeManager)
                    .transition(.opacity)
            }
        }
    }
    
    // ボタンの行を定義
    private let buttonRows: [[Int]] = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
    ]
    
    // ボタンを作成する関数
    private func createButton(number: Int) -> some View {
        Button {
            // 入力された数字または削除の処理を呼び出す
            inputText(number: number == -1 ? "del" : String(number))
        } label: {
            Text(number == -1 ? "⌫" : "\(number)")
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
    
    // 数字または削除の入力処理
    private func inputText(number: String) {
        if number == "del" {
            // 削除処理
            for (index, getText) in passCheck.enumerated().reversed() {
                if getText != nil {
                    passCheck[index] = nil
                    break
                }
            }
        } else {
            // 数字入力処理
            var checkAnswer = ""
            
            for (index, getText) in passCheck.enumerated() {
                if getText == nil {
                    passCheck[index] = number
                    if index == 3 {
                        // 4桁入力完了でパスコードをチェック
                        for i in 0...3 {
                            checkAnswer += (passCheck[i] ?? "")
                        }
                        if checkAnswer == answer {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    isShow.toggle()
                                }
                            }
                        } else {
                            // パスコードが一致しない場合の処理
                            passCheck = [nil, nil, nil, nil]
                            showError = true
                        }
                    }
                    break
                }
            }
        }
    }
    
    // 顔認証の関数
    func exec() {
        face.auth { result in
            // 認証が成功した時の処理
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
