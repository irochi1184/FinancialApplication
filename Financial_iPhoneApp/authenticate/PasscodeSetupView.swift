import SwiftUI

struct PasscodeSetupView: View {
    @Binding var isSettingPasscode: Bool
    @Binding var toggle: Bool
    
    @EnvironmentObject var passcheck: passCheck
    @State var count = 0
    @State private var isConfirmingPasscode = false
    
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
                    passcheck.passText = "パスワードを忘れると復元できません\n忘れないようご注意ください"
                    toggle = false // トグルをオフにする
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
        .fullScreenCover(isPresented: $isConfirmingPasscode) {
            PasscodeSetupConfirmView(isSettingPasscode: $isSettingPasscode, isConfirmingPasscode: $isConfirmingPasscode)
                .environmentObject(passcheck)
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
