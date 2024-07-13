//
//  SetLockConfirmView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/13.
//

import SwiftUI

struct SetLockConfirmView: View {
    @Binding var path: [LockPath]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var model: AppModel
    @State private var passcode: [String?] = [nil, nil, nil, nil]
    @State private var passText = ""
    @State private var isShowAlert = false
    @State private var passCode = ""
    
    var body: some View {
        VStack {
            Spacer()
            Text("パスコードの再入力")
                .font(.title3)
                .fontWeight(.bold)
            
            HStack {
                ForEach(0..<4) { index in
                    if passcode[index] == nil {
                        Image(systemName: "circle")
                            .padding()
                    } else {
                        Image(systemName: "circle.fill")
                            .padding()
                    }
                }
            }
            
            Text(passText)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.clear)
            Spacer()
            
            VStack {
                ForEach(1..<10, id: \.self) { i in
                    if i % 3 == 1 {
                        HStack {
                            Spacer()
                        }
                    }
                    Button {
                        inputText(number: String(i))
                    } label: {
                        Text("\(i)")
                            .font(.title)
                            .frame(width: 90, height: 45)
                            .foregroundColor(Color(.orange))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color(.orange), lineWidth: 1.0)
                            )
                    }
                }
            }
            
            Button {
                inputText(number: "0")
            } label: {
                Text("0")
                    .font(.title)
                    .frame(width: 90, height: 45)
                    .foregroundColor(Color(.orange))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(.orange), lineWidth: 1.0)
                    )
            }
            
            Spacer()
        }
        .navigationTitle("確認入力")
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    path.removeLast()
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward.fill")
                }
            }
        }
        .alert("FaceIDを使いますか？", isPresented: $isShowAlert) {
            Button("はい") {
                UserDefaults.standard.set(true, forKey: "UseFaceID")
                path.removeAll()
                model.setPassword(passCode)
            }
            Button("いいえ") {
                UserDefaults.standard.set(false, forKey: "UseFaceID")
                path.removeAll()
                model.setPassword(passCode)
            }
        }
    }
    
    private func inputText(number: String) {
        for (index, getText) in passcode.enumerated() {
            if getText == nil {
                passcode[index] = number
                if index == 3 {
                    if passcode == passcode {
                        for i in 0..<4 {
                            passCode += passcode[i] ?? ""
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isShowAlert = true
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            passText = "パスワードが1回目と異なります\nもう一度行ってください"
                            passcode = [nil, nil, nil, nil]
                            path.removeLast()
                        }
                    }
                }
                break
            }
        }
    }
}
