//
//  PasscodeSetupView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/13.
//

import SwiftUI

struct PasscodeSetupView: View {
    @Binding var isSettingPasscode: Bool
    
    @EnvironmentObject var passcheck: passCheck
    @State var count = 0
    @State private var isConfirmingPasscode = false
    
    var body: some View {
        VStack {
            // スペースを追加して、ナビゲーションバーとキャンセルボタンの間に余白を作成
            Spacer().frame(height: 10)
            
            HStack {
                Button {
                    passcheck.firstCheck = [nil, nil, nil, nil]
                    passcheck.passText = "パスワードを忘れると復元できません\n忘れないようご注意ください"
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
            
            Text("\(passcheck.passText)")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.pink)
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
        .fullScreenCover(isPresented: $isConfirmingPasscode) {
            PasscodeSetupConfirmView(isSettingPasscode: $isSettingPasscode, isConfirmingPasscode: $isConfirmingPasscode)
                .environmentObject(passcheck)
        }
        
    }
    
    private func inputText(number: String) {
        for (index, getText) in passcheck.firstCheck.enumerated() {
            if getText == nil {
                passcheck.firstCheck[index] = number
                if index == 3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isConfirmingPasscode = true
                    }
                }
                break
            }
        }
    }
}
