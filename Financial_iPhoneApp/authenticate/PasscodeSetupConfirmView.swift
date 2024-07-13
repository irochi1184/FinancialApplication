//
//  PasscodeSetupConfirmView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/13.
//

import SwiftUI

struct PasscodeSetupConfirmView: View {
    @Binding var isSettingPasscode: Bool
    @Binding var isConfirmingPasscode: Bool
    
    @EnvironmentObject var passcheck: passCheck
    
    @State var isShowAlert = false
    @State var passCode = ""
    
    // カラー設定
    @State private var buttonText = Color.mint
    @State private var buttonBack = Color.white
    
    var body: some View {
        VStack {
            // スペースを追加して、ナビゲーションバーとキャンセルボタンの間に余白を作成
            Spacer().frame(height: 10)
            
            HStack {
                Button {
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
            
            Text("\(passcheck.passText)")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.clear)
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
        }
        .alert("FaceIDを使用しますか？", isPresented: $isShowAlert) {
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
    
    private func inputText(number: String) {
        for (index, getText) in passcheck.secondCheck.enumerated() {
            if getText == nil {
                passcheck.secondCheck[index] = number
                if index == 3 {
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
