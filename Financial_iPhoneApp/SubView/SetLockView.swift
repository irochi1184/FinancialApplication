//
//  SetLockView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/13.
//

import SwiftUI

enum LockPath: Hashable {
    case pathSub1
    case pathSub2
}

struct SetLockView: View {
    @Binding var path: [LockPath]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var model: AppModel
    @State private var passcode: [String?] = [nil, nil, nil, nil]
    @State private var passText = "パスワードを忘れると復元できません\n忘れないようご注意ください"
    
    var body: some View {
        VStack {
            Spacer()
            Text("パスコードの入力")
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
                .foregroundColor(Color.pink)
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
        .navigationTitle("入力")
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    passcode = [nil, nil, nil, nil]
                    passText = "パスワードを忘れると復元できません\n忘れないようご注意ください"
                    path.removeLast()
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward.fill")
                }
            }
        }
    }
    
    private func inputText(number: String) {
        for (index, getText) in passcode.enumerated() {
            if getText == nil {
                passcode[index] = number
                if index == 3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        path.append(.pathSub2)
                    }
                }
                break
            }
        }
    }
}
