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
    
    @State private var isExpense: Bool = true // カテゴリーごとのグラフを表示するか、総額グラフを表示するかのフラグ
    
    // 表示する年の範囲
    private let minYear: Int = 2000
    private let maxYear: Int = 2024
    
    init() {
        formatter.dateFormat = "yyyy年"
        formatter2.dateFormat = "M月"
        formatter2.locale = Locale(identifier: "ja_JP")
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
                Picker("", selection: $isExpense) {
                    Text("カテゴリー別").tag(true)
                    Text("総額").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding([.leading, .trailing], 15) // 左、下、右に余白
            }
            .padding(.bottom, 10)
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
            Divider() // 区切り線
            
            TabView(selection: $isExpense) { // TabViewを使用してページング機能を実装
                ScrollView {
                    categoryView
                }
                .tag(true)
                .tabItem { Text("カテゴリー別") }
                
                ScrollView {
                    totalAmountView
                }
                .tag(false)
                .tabItem { Text("総額") }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // ページングスタイルの設定
        }
        .onAppear {
            selectedDateString = formatter.string(from: selectedDate)
        }
    }
    
    private var categoryView: some View {
        VStack {
            Spacer().frame(height: 20)
            Chart(calculateMonthlyUsageAmount()) { dataRow in
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
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            Divider()
            Spacer().frame(height: 15)
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(100), spacing: 10), count: 3), spacing: 10) {
                ForEach(categorys, id: \.self) { category in
                    Button(action: {
                        category.toggle.toggle()
                    }) {
                        HStack {
                            Image(systemName: category.toggle ? "tag.fill" : "tag")
                                .font(.system(size: 16))
                                .foregroundColor(category.toggle ? .white : .gray)
                            
                            Text("\(category.categoryName)")
                                .font(.subheadline)
                                .fontWeight(.light)
                                .foregroundColor(category.toggle ? .white : .primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5) // テキストの縮小を許可
                        }
                        .frame(width: 80, height: 25) // ボタンサイズを固定
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(category.toggle ? Color.blue : Color(UIColor.secondarySystemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle()) // ボタンのデフォルトスタイルを無効化
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }
    
    private var totalAmountView: some View {
        VStack {
            Spacer().frame(height: 20)
            Chart(calculateTotalMonthlyUsageAmount()) { dataRow in
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
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            Divider()
            Spacer().frame(height: 15)
            
            VStack(spacing: 10) {
                ForEach(calculateTotalMonthlyUsageAmount()) { dataRow in
                    HStack {
                        Text("\(dataRow.month)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(dataRow.amount)円")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 300, height: 5)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.secondarySystemBackground)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 10)
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
