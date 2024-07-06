//
//  HeaderView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/06.
//

import SwiftUI

struct HeaderView: View {
    let formatter: DateFormatter
    @Binding var selectedDate: Date
    let calendar: Calendar
    @Binding var isDatePickerVisible: Bool
    let onChangeMonth: (Int) -> Void
    
    var body: some View {
        HStack {
            Button(action: { onChangeMonth(-1) }) { // 前の月へ移動
                Image(systemName: "chevron.left")
            }
            Spacer()
            Button(action: { isDatePickerVisible.toggle() }) { // DatePickerの表示を切り替え
                Text(formatter.string(from: selectedDate)) // 「20XX年XX月」にフォーマット
                    .font(.title)
                    .padding()
            }
            Spacer()
            Button(action: { onChangeMonth(1) }) { // 次の月へ移動
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TransactionData.self)
}
