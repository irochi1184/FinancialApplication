//
//  PasscodeSetupView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/13.
//

import SwiftUI

struct PasscodeSetupView: View {
    @Binding var isSettingPasscode: Bool // パスコード設定状態のバインディング
    @Binding var toggle: Bool // トグル状態のバインディング
    
    @EnvironmentObject var passcheck: passCheck // パスワードチェック用の環境オブジェクト
    @State var count = 0 // カウントの状態変数
    @State private var isConfirmingPasscode = false // パスコード確認画面の表示状態
    
    // カラー設定
    @State private var buttonText = Color.mint // ボタンテキストの色
    @State private var buttonBack = Color.white // ボタン背景の色
    
    var body: some View {
        VStack {
            // スペースを追加して、ナビゲーションバーとキャンセルボタンの間に余白を作成
            Spacer().frame(height: 10)
            
            HStack {
                Button {
                    // パスコード入力をリセットし、トグルをオフにして設定画面を閉じる
                    passcheck.firstCheck = [nil, nil, nil, nil]
                    passcheck.passText = "パスワードを忘れると復元できません\n忘れないようご注意ください"
                    toggle = false
                    isSettingPasscode = false
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward.fill")
                    Text("キャンセル").font(.title3)
                }
                Spacer()
            }
            .padding(.leading)
            
            Spacer()
            Text("パスコードの入力")
                .font(.title3)
                .fontWeight(.bold)
            
            // パスコード入力の視覚的表示
            HStack {
                ForEach(0..<4) { index in
                    if passcheck.firstCheck[index] == nil {
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
                .foregroundColor(Color.pink)
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
        .fullScreenCover(isPresented: $isConfirmingPasscode) {
            // パスコード確認画面をフルスクリーンで表示
            PasscodeSetupConfirmView(isSettingPasscode: $isSettingPasscode, isConfirmingPasscode: $isConfirmingPasscode)
                .environmentObject(passcheck)
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
            for (index, getText) in passcheck.firstCheck.enumerated().reversed() {
                if getText != nil {
                    passcheck.firstCheck[index] = nil
                    break
                }
            }
        } else {
            // 数字入力処理
            for (index, getText) in passcheck.firstCheck.enumerated() {
                if getText == nil {
                    passcheck.firstCheck[index] = number
                    if index == 3 {
                        // 4桁入力完了で確認画面へ遷移
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isConfirmingPasscode = true
                        }
                    }
                    break
                }
            }
        }
    }
}
