//
//  CommonView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/06.
//

import SwiftUI
import SwiftData

struct CategorySelectionView: View {
    @Binding var selectedCategory: String
    @Environment(\.dismiss) var dismiss
    @Query private var categories: [CategoryData]
    
    var body: some View {
        List {
            ForEach(categories.sorted { $0.order < $1.order }, id: \.self) { category in
                Button(action: {
                    selectedCategory = category.categoryName
                    dismiss() // カテゴリーをチェックしたら自動的に前のViewに戻る
                }) {
                    HStack {
                        Text(category.categoryName)
                        if selectedCategory == category.categoryName {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CategoryData.self, TransactionData.self], inMemory: true)
}

struct DayPickerView: View {
    @Binding var isDatePickerVisible: Bool
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int
    @Binding var selectedDay: Int
    
    let minYear: Int
    let maxYear: Int
    let calendar = Calendar.current
    
    var onDateSelected: (() -> Void)?
    
    var body: some View {
        VStack {
            // DatePickerを閉じるボタン
            Button(action: {
                isDatePickerVisible = false
                onDateSelected?()
            }) {
                Text("閉じる")
                    .foregroundColor(.blue)
                    .padding()
            }
            
            HStack {
                // 年のピッカー
                Picker(selection: $selectedYear, label: Text("")) {
                    ForEach(minYear...maxYear, id: \.self) { year in
                        Text("\(String(year))年").tag(year) // Stringに変換しないとカンマが入ってしまう
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)
                
                // 月のピッカー
                Picker("Month", selection: $selectedMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text("\(month)月")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)
                
                // 日のピッカー
                Picker("Day", selection: $selectedDay) {
                    ForEach(1...numberOfDays(in: selectedMonth), id: \.self) { day in
                        Text("\(day)日")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)
            }
        }.presentationDetents([.height(280)]) // シートの高さ
    }
    
    private func numberOfDays(in month: Int) -> Int {
        let dateComponents = DateComponents(year: selectedYear, month: month)
        if let date = calendar.date(from: dateComponents),
           let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        }
        return 31 // デフォルトでは31日を返す
    }
}
