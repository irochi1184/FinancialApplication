//
//  PasscodeSetupConfirmView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/13.
//

import SwiftUI

struct PasscodeSetupConfirmView: View {
    @Binding var isSettingPasscode: Bool // パスコード設定状態のバインディング
    @Binding var isConfirmingPasscode: Bool // 確認画面の表示状態のバインディング
    @EnvironmentObject var passcheck: passCheck // パスワードチェック用の環境オブジェクト
    @State var isShowAlert = false // アラート表示状態
    @State var passCode = "" // 設定するパスコード
    
    // カラー設定
    @State private var buttonText = Color.mint // ボタンテキストの色
    @State private var buttonBack = Color.white // ボタン背景の色
    
    var body: some View {
        VStack {
            // スペースを追加して、ナビゲーションバーとキャンセルボタンの間に余白を作成
            Spacer().frame(height: 10)
            
            HStack {
                Button {
                    // パスコード入力をリセットして確認画面を閉じる
                    passcheck.firstCheck = [nil, nil, nil, nil]
                    passcheck.secondCheck = [nil, nil, nil, nil]
                    passcheck.passText = "パスワードを忘れると復元できません\n忘れないようご注意ください"
                    isConfirmingPasscode = false
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward.fill")
                    Text("キャンセル").font(.title3)
                }
                Spacer()
            }
            .padding(.leading)
            
            Spacer()
            Text("パスコードの再入力")
                .font(.title3)
                .fontWeight(.bold)
            
            // パスコード入力の視覚的表示
            HStack {
                ForEach(0..<4) { index in
                    if passcheck.secondCheck[index] == nil {
                        Image(systemName: "circle")
                            .padding()
                    } else {
                        Image(systemName: "circle.fill")
                            .padding()
                    }
                }
            }
            
            // 注意事項の表示
            Text("\(passcheck.passText)")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.clear)
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
        }
        .alert("FaceIDを使用しますか？", isPresented: $isShowAlert) {
            // FaceID使用確認のアラート
            Button("はい") {
                UserDefaults.standard.set(true, forKey: "UseFaceID")
                isSettingPasscode = false
                passcheck.firstCheck = [nil, nil, nil, nil]
                passcheck.secondCheck = [nil, nil, nil, nil]
            }.bold()
            Button("いいえ") {
                UserDefaults.standard.set(false, forKey: "UseFaceID")
                isSettingPasscode = false
                passcheck.firstCheck = [nil, nil, nil, nil]
                passcheck.secondCheck = [nil, nil, nil, nil]
            }.foregroundStyle(.red)
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
            for (index, getText) in passcheck.secondCheck.enumerated().reversed() {
                if getText != nil {
                    passcheck.secondCheck[index] = nil
                    break
                }
            }
        } else {
            // 数字入力処理
            for (index, getText) in passcheck.secondCheck.enumerated() {
                if getText == nil {
                    passcheck.secondCheck[index] = number
                    if index == 3 {
                        // 4桁入力完了でパスコードをチェック
                        if passcheck.firstCheck == passcheck.secondCheck {
                            for i in 0...3 {
                                passCode += (passcheck.firstCheck[i] ?? "")
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                UserDefaults.standard.set(true, forKey: "SetPass")
                                UserDefaults.standard.set(passCode, forKey: "password")
                                isShowAlert = true
                            }
                        } else {
                            // パスコードが一致しない場合の処理
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                passcheck.passText = "パスワードが間違っています\nもう一度やり直してください"
                                passcheck.firstCheck = [nil, nil, nil, nil]
                                passcheck.secondCheck = [nil, nil, nil, nil]
                                isConfirmingPasscode = false
                            }
                        }
                    }
                    break
                }
            }
        }
    }
}
