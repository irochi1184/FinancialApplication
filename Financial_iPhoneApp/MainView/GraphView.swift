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
    var category: String?
    
    init(month: String, amount: Int, category: String? = nil) {
        self.id = UUID()
        self.month = month
        self.amount = amount
        self.category = category
    }
}

struct GraphView: View {
    
    @Query private var datas: [TransactionData] // トランザクションデータの取得
    @Query private var categorys: [CategoryData]
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    let formatter2 = DateFormatter()
    
    @State private var selectedDate: Date = Date()
    @State private var selectedDateString: String = ""
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var isDatePickerVisible = false
    
    @State private var showCategoryGraph = true // カテゴリーごとのグラフを表示するか、総額グラフを表示するかのフラグ
    
    // 表示する年の範囲
    private let minYear: Int = 2000
    private let maxYear: Int = 2024
    
    init() {
        formatter.dateFormat = "yyyy年"
        formatter2.dateFormat = "M月"
        formatter2.locale = Locale(identifier: "ja_JP")
    }
    
    var body: some View {
        VStack {
            // 年選択と切り替えボタン
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
                
                // グラフの切り替えボタン
                Picker("", selection: $showCategoryGraph) {
                    Text("カテゴリー別").tag(true)
                    Text("総額").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(10)
            }
            .padding(.bottom, 20)
            .sheet(isPresented: $isDatePickerVisible) { // 年のピッカーを表示するためのシート
                VStack {
                    // DatePickerを閉じるボタン
                    Button(action: {
                        self.isDatePickerVisible = false
                        self.selectedDate = self.calendar.date(from: DateComponents(year: selectedYear)) ?? Date()
                    }) {
                        Text("閉じる")
                            .foregroundColor(.blue)
                            .padding()
                    }
                    
                    HStack {
                        // 年のピッカー
                        Picker(selection: $selectedYear, label: Text("")) {
                            ForEach(minYear...maxYear, id: \.self) { year in
                                Text("\(String(year))年").tag(year)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        
                    }
                }.presentationDetents([.height(280)]) // シートの高さ
            }
            VStack {
                Chart(showCategoryGraph ? calculateMonthlyUsageAmount() : calculateTotalMonthlyUsageAmount()){ dataRow in
                    LineMark(
                        x: .value("month", dataRow.month),
                        y: .value("amount", dataRow.amount)
                    )
                    .foregroundStyle(by: .value("Category", dataRow.category ?? "総額"))
                    PointMark(
                        x: .value("month", dataRow.month),
                        y: .value("amount", dataRow.amount)
                    )
                    .foregroundStyle(by: .value("Category", dataRow.category ?? "総額"))
                }
                .frame(height: 300)
                .chartYAxis{
                    AxisMarks(position: .leading)
                }
                
                if showCategoryGraph {
                    List (categorys){ category in
                        Toggle(isOn: Binding(
                            get: {
                                category.toggle
                            },
                            set: { value in
                                category.toggle = value
                            }
                        )) {
                            Text("\(category.categoryName)")
                        }
                    }.id(UUID())
                } else {
                    // 総額をリスト表示
                    List(calculateTotalMonthlyUsageAmount()) { dataRow in
                        HStack {
                            Text("\(dataRow.month)")
                            Spacer()
                            Text("\(dataRow.amount)円")
                        }
                    }
                    .id(UUID())
                }
            }
        }
        .onAppear {
            selectedDateString = formatter.string(from: selectedDate)
        }
    }
    
    // 各月の使用金額を計算する関数（カテゴリー別）
    private func calculateMonthlyUsageAmount() -> [LineData] {
        var monthlyUsage: [LineData] = []
        for month in 1...12 {
            for categoryX in categorys {
                if categoryX.toggle {
                    let monthData = datas.filter { data in
                        let components = calendar.dateComponents([.year, .month], from: data.selectedDate)
                        return components.year == selectedYear && components.month == month && data.category == categoryX.categoryName
                    }
                    let totalAmount = monthData.reduce(0) { $0 + (Int($1.amount) ?? 0) }
                    let dateComponents = DateComponents(year: selectedYear, month: month)
                    let monthDate = calendar.date(from: dateComponents)!
                    let monthString = formatter2.string(from: monthDate)
                    monthlyUsage.append(LineData(month: monthString, amount: totalAmount, category: categoryX.categoryName))
                }
            }
        }
        return monthlyUsage
    }
    
    // 各月の総額を計算する関数
    private func calculateTotalMonthlyUsageAmount() -> [LineData] {
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
            monthlyUsage.append(LineData(month: monthString, amount: totalAmount))
        }
        return monthlyUsage
    }
}

#Preview {
    ContentView(model: AppModel())
        .modelContainer(for: [CategoryData.self, TransactionData.self], inMemory: true)
}
