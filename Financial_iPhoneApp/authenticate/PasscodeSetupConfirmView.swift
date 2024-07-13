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
            
            //入力ボタン
            HStack {
                ForEach(1..<4) { i in
                    Button {
                        inputText(number: String(i))
                    } label: {
                        Text("\(i)")
                            .font(.title)
                            .frame(width: 70, height: 70)
                            .foregroundColor(.mint)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke((.mint), lineWidth: 1.0)
                            )
                    }.padding()
                }
            }
            HStack {
                ForEach(4..<7) { i in
                    Button {
                        inputText(number: String(i))
                    } label: {
                        Text("\(i)")
                            .font(.title)
                            .frame(width: 70, height: 70)
                            .foregroundColor(.mint)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke((.mint), lineWidth: 1.0)
                            )
                    }.padding()
                }
            }
            HStack {
                ForEach(7..<10) { i in
                    Button {
                        inputText(number: String(i))
                    } label: {
                        Text("\(i)")
                            .font(.title)
                            .frame(width: 70, height: 70)
                            .foregroundColor(.mint)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke((.mint), lineWidth: 1.0)
                            )
                    }.padding()
                }
            }
            Button {
                inputText(number: "0")
            } label: {
                Text("0")
                    .font(.title)
                    .frame(width: 70, height: 70)
                    .foregroundColor(.mint)
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke((.mint), lineWidth: 1.0)
                    )
            }.padding()
            //入力ボタン
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
    
    private func inputText(number: String) {
        for (index, getText) in passcheck.secondCheck.enumerated() {
            if getText == nil {
                passcheck.secondCheck[index] = number
                if index == 3 {
                    if passcheck.firstCheck == passcheck.secondCheck {
                        for i in 0...3 {
                            passCode = passCode + (passcheck.firstCheck[i] ?? "")
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
