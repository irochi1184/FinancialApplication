//
//  DatePickerView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/06.
//

import SwiftUI

struct DatePickerView: View {
    @Binding var isDatePickerVisible: Bool // DatePickerの表示状態
    @Binding var selectedYear: Int // 選択された年
    @Binding var selectedMonth: Int // 選択された月
    let minYear: Int // 最小の年
    let maxYear: Int // 最大の年
    let onDateSelected: () -> Void // 日付が選択されたときの処理
    
    var body: some View {
        VStack {
            Button(action: {
                isDatePickerVisible = false
                onDateSelected() // 確定ボタンが押されたときの処理
            }) {
                Text("確定")
                    .foregroundColor(.blue)
                    .padding()
            }
            HStack {
                Picker(selection: $selectedYear, label: Text("")) {
                    ForEach(minYear...maxYear, id: \.self) { year in
                        Text("\(String(year))年").tag(year)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
                .frame(maxWidth: .infinity)
                
                Picker("Month", selection: $selectedMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text("\(month)月")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)
            }
        }
        .presentationDetents([.height(280)])
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TransactionData.self)
}
