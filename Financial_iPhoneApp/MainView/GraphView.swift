//
//  GraphView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/29.
//

import SwiftUI
import SwiftData
import Charts

struct LineData: Identifiable {
    var id = UUID()
    var month: String
    var amount: Int
    var category: String // カテゴリを追加
}

struct GraphView: View {
    
    @Query private var datas: [TransactionData] // トランザクションデータの取得
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    let formatter2 = DateFormatter()
    
    @State private var selectedDate: Date = Date()
    @State private var selectedDateString: String = ""
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var isDatePickerVisible = false
    
    // 表示する年の範囲
    private let minYear: Int = 2000
    private let maxYear: Int = 2024
    
    @State private var isOn: Bool = true
    @State private var isOn1: Bool = true
    @State private var isOn2: Bool = true
    
    init() {
        formatter.dateFormat = "yyyy年"
        formatter2.dateFormat = "M月"
        formatter2.locale = Locale(identifier: "ja_JP")
    }
    
    var body: some View {
        VStack {
            VStack {
                // 年の切り替えボタン
                HStack {
                    Button(action: {
                        self.selectedDate = self.calendar.date(byAdding: .year, value: -1, to: self.selectedDate)!
                        self.selectedYear = Calendar.current.component(.year, from: self.selectedDate)
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    
                    Spacer()
                    
                    // 選択された年の表示
                    Button(action: {
                        // 年の表示部分がタップされたらDatePickerを表示する
                        self.isDatePickerVisible.toggle()
                    }) {
                        Text(formatter.string(from: selectedDate))
                            .font(.title)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.selectedDate = self.calendar.date(byAdding: .year, value: 1, to: self.selectedDate)!
                        self.selectedYear = Calendar.current.component(.year, from: self.selectedDate)
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)
                
            }
            .padding(.bottom, 20) // 下部に余白を追加
            .sheet(isPresented: $isDatePickerVisible) { // 年のピッカーを表示するためのシート
                VStack {
                    // DatePickerを閉じるボタン
                    Button(action: {
                        self.isDatePickerVisible = false
                        self.selectedDate = self.calendar.date(from: DateComponents(year: selectedYear)) ?? Date() // 確定ボタンが押されたときの処理
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
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        
                    }
                }.presentationDetents([.height(280)]) // シートの高さ
            }
            VStack {
                Chart(calculateMonthlyUsageAmount()){ dataRow in
                    LineMark(
                        x: .value("month", dataRow.month),
                        y: .value("amount", dataRow.amount)
                    )
                    .foregroundStyle(by: .value("Category", dataRow.category))
                }
                .frame(height: 300)
                .chartYAxis{
                    AxisMarks(position: .leading)
                }
                List {
                    Toggle(isOn: $isOn) {
                        Text("全体")
                    }
                    Toggle(isOn: $isOn1) {
                        Text("カテゴリ1")
                    }
                    Toggle(isOn: $isOn2) {
                        Text("カテゴリ2")
                    }
                }
            }
        }
        .onAppear {
            selectedDateString = formatter.string(from: selectedDate)
        }
    }
    
    // 各月の使用金額を計算する関数
    private func calculateMonthlyUsageAmount() -> [LineData] {
        var monthlyUsage: [LineData] = []
        for month in 1...12 {
            let monthData = datas.filter { data in
                let components = calendar.dateComponents([.year, .month], from: data.selectedDate)
                return components.year == selectedYear && components.month == month
            }
            let totalAmount = monthData.reduce(0) { $0 + (Int($1.amount) ?? 0) }
            let dateComponents = DateComponents(year: selectedYear, month: month)
            let monthDate = calendar.date(from: dateComponents)!
            let monthString = formatter2.string(from: monthDate)
            monthlyUsage.append(LineData(month: monthString, amount: totalAmount, category: "all"))
        }
        return monthlyUsage
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CategoryData.self, TransactionData.self], inMemory: true)
}
