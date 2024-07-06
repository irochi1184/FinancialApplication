//
//  HomeView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/29.
//

import SwiftUI
import SwiftData
import Charts

struct Tab: Identifiable {
    var id: UUID = .init()
    let title: String
    let color: Color
}

struct Amounts {
    let name: String
    let count: Int
    var color: Color
}

private let tabs: [Tab] = [
    .init(title: "ホーム1", color: .cyan),
    .init(title: "ホーム2", color: .green)
]

private var category: [Amounts] = [
    .init(name: "食費", count: 1, color: .blue),
    .init(name: "固定費", count: 1, color: .gray),
    .init(name: "娯楽", count: 1, color: .red),
    .init(name: "日用雑貨", count: 1, color: .orange)
]

struct HomeView: View {
    
    let calendar = Calendar.current
    let formatter = DateFormatter() // "yyyy年 MM月"
    let formatter2 = DateFormatter() // "MM月dd日"
    
    @Query private var datas: [TransactionData]
    
    @State private var selectedDate: Date = Date()
    @State private var selectedDateString: String = ""
    @State private var selectedDay: Date?
    
    @State private var totalUsageAmount: Int = 0 // 使用金額
    @State private var monthlyLimitAmount: Int = 100000 // 月の限度額
    
    @State private var amounts: [Amounts] = []
    
    init() {
        formatter.dateFormat = "yyyy年 MM月"
        formatter2.dateFormat = "MM月dd日"
    }
    
    @State private var isDatePickerVisible = false
    
    // 選択された年と月
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    
    // 表示する年の範囲
    private let minYear: Int = 2000
    private let maxYear: Int = 2024
    
    @State private var selectedTabId: UUID? = tabs[0].id
    @Namespace private var tabNamespace
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        self.selectedDate = self.calendar.date(byAdding: .month, value: -1, to: self.selectedDate)!
                        updateAmounts() // 年月移動でグラフ再描画
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    
                    Spacer()
                    
                    // 選択された月の表示
                    Button(action: {
                        // 月の表示部分がタップされたらDatePickerを表示する
                        self.isDatePickerVisible.toggle()
                    }) {
                        Text(formatter.string(from: selectedDate))
                            .font(.title)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.selectedDate = self.calendar.date(byAdding: .month, value: 1, to: self.selectedDate)!
                        updateAmounts() // 年月移動でグラフ再描画
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)
                
                ScrollView { // Tabやグラフ部分のスクロールを可能にする
                    VStack(spacing: 0) {
                        // Tab
                        ScrollViewReader { scrollProxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(tabs) { tab in
                                        Button {
                                            selectedTabId = tab.id
                                        } label: {
                                            Text(tab.title)
                                                .bold()
                                        }
                                        .id(tab.id)
                                        .padding()
                                        .frame(width: 190)
                                    }
                                }
                            }
                        }
                        
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 0) {
                                ForEach(tabs) { tab in
                                    if tab.title == "ホーム1" {
                                        ZStack {
                                            VStack {
                                                Divider()
                                                Spacer().frame(height: 20)
                                                
                                                ZStack {
                                                    Chart(amounts, id: \.name) { amount in
                                                        SectorMark(
                                                            angle: .value("count", amount.count),innerRadius: .inset(30)
                                                        )
                                                        .foregroundStyle(amount.color)
                                                    }.frame(height: 300)
                                                    
                                                    // 円グラフの中心に表示するテキスト
                                                    Text("● ").foregroundColor(.gray).font(.caption) +
                                                    Text("月の限度額：\(monthlyLimitAmount)円").font(.subheadline).foregroundColor(.black) +
                                                    Text("\n● ").foregroundColor(.blue).font(.caption) +
                                                    Text("　使用金額：\(calculateTotalUsageAmount())円").font(.subheadline).foregroundColor(.black)
                                                }
                                                .frame(width: 300, height: 300)
                                                
                                                Spacer().frame(height: 25)
                                                
                                                Text("使用内容").font(.headline).frame(maxWidth: 350, alignment: .leading)
                                                Divider()
                                                
                                                // リスト表示
                                                List(dateFiltered, id: \.self) { item in
                                                    VStack(alignment: .leading) {
                                                        HStack {
                                                            Text(formatter2.string(from: item.selectedDate))
                                                            Text(item.transactionName)
                                                            Spacer()
                                                            Text("\(item.amount)円")
                                                        }
                                                    }
                                                }
                                                .listStyle(.plain)
                                                .scrollDisabled(true)
                                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                                                
                                            }
                                            .padding(.bottom, 20)
                                            .sheet(isPresented: $isDatePickerVisible) {
                                                DatePickerView(
                                                    isDatePickerVisible: $isDatePickerVisible,
                                                    selectedYear: $selectedYear,
                                                    selectedMonth: $selectedMonth,
                                                    minYear: minYear,
                                                    maxYear: maxYear,
                                                    onDateSelected: {
                                                        self.selectedDate = self.calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth)) ?? Date()
                                                        updateAmounts()
                                                    }
                                                )
                                            }
                                            
                                        }
                                        .containerRelativeFrame(.horizontal)
                                    } else {
                                        ZStack {
                                            VStack {
                                                VStack {
                                                    Divider()
                                                    Spacer().frame(height: 20)
                                                    
                                                    ZStack {
                                                        Chart(category, id: \.name) { amount in
                                                            SectorMark(
                                                                angle: .value("count", amount.count),innerRadius: .inset(30)
                                                            )
                                                            .foregroundStyle(amount.color)
                                                        }.frame(height: 300)
                                                        
                                                        VStack {
                                                            Text("●").foregroundColor(.blue).font(.caption) +
                                                            Text("食費：60000円").font(.subheadline).foregroundColor(.black)
                                                            Text("●").foregroundColor(.gray).font(.caption) +
                                                            Text("固定費：60000円").font(.subheadline).foregroundColor(.black)
                                                            Text("●").foregroundColor(.red).font(.caption) +
                                                            Text("娯楽：60000円").font(.subheadline).foregroundColor(.black)
                                                            Text("●").foregroundColor(.orange).font(.caption) +
                                                            Text("日用雑貨：60000円").font(.subheadline).foregroundColor(.black)
                                                        }
                                                    }
                                                    .frame(width: 300, height: 300)
                                                    
                                                    Spacer().frame(height: 30)
                                                    
                                                    Text("カテゴリ内容").font(.headline).frame(maxWidth: 350, alignment: .leading)
                                                    Divider()
                                                    
                                                    // リスト表示
                                                    List(TotalCategoryData.keys.sorted(), id: \.self) { category in
                                                        HStack {
                                                            Text(category)
                                                            Spacer()
                                                            Text("\(TotalCategoryData[category] ?? 0)円")
                                                        }
                                                    }
                                                    .listStyle(.plain)
                                                    .scrollDisabled(true)
                                                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                                                }
                                                .padding(.bottom, 20)
                                                .sheet(isPresented: $isDatePickerVisible) {
                                                    DatePickerView(
                                                        isDatePickerVisible: $isDatePickerVisible,
                                                        selectedYear: $selectedYear,
                                                        selectedMonth: $selectedMonth,
                                                        minYear: minYear,
                                                        maxYear: maxYear,
                                                        onDateSelected: {
                                                            self.selectedDate = self.calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth)) ?? Date()
                                                            updateAmounts()
                                                        }
                                                    )
                                                }
                                            }
                                        }
                                        .containerRelativeFrame(.horizontal)
                                    }
                                }
                            }
                            .scrollTargetLayout()
                        }
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $selectedTabId)
                }
                .animation(.easeInOut, value: selectedTabId)
            }
            FloatingButton()
        }
        .onAppear {
            updateAmounts()
        }
    }
    
    struct DatePickerView: View {
        @Binding var isDatePickerVisible: Bool
        @Binding var selectedYear: Int
        @Binding var selectedMonth: Int
        let minYear: Int
        let maxYear: Int
        let onDateSelected: () -> Void
        
        var body: some View {
            VStack {
                Button(action: {
                    isDatePickerVisible = false
                    onDateSelected()
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
    
    struct FloatingButton: View {
        @State private var isPresented: Bool = false
        
        var body: some View {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = true
                    }, label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                    })
                    .fullScreenCover(isPresented: $isPresented) {
                        PlusView()
                    }
                    .frame(width: 60, height: 60)
                    .background(Color.blue)
                    .cornerRadius(30.0)
                    .shadow(color: .gray, radius: 3, x: 3, y: 3)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 16.0, trailing: 16.0))
                }
            }
        }
    }
    
    private func calculateTotalUsageAmount() -> Int {
        dateFiltered.reduce(0) { $0 + ($1.amount as NSString).integerValue }
    }
    
    private var dateFiltered: [TransactionData] {
        let selectedMonthComponents = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        return datas.filter {
            let dataMonthComponents = Calendar.current.dateComponents([.year, .month], from: $0.selectedDate)
            return dataMonthComponents == selectedMonthComponents
        }.sorted {
            $0.selectedDate > $1.selectedDate
        }
    }
    
    private var TotalCategoryData: [String: Int] {
        // カテゴリーごとの合計金額を格納する辞書を初期化
        var categoryTotals: [String: Int] = [:]
        
        // フィルタリングされた取引データをループで処理
        for transaction in categoryFiltered {
            // 取引データのカテゴリー名を取得
            let category = transaction.category
            // 取引データの金額を整数に変換
            let amount = (transaction.amount as NSString).integerValue
            
            // 辞書に既にそのカテゴリーが存在するか確認
            if let total = categoryTotals[category] {
                // 既にカテゴリーが存在する場合、そのカテゴリーの合計金額に取引データの金額を加算
                categoryTotals[category] = total + amount
            } else {
                // カテゴリーが存在しない場合、新しい辞書を作成
                categoryTotals[category] = amount
            }
        }
        
        // カテゴリーごとの合計金額を返す
        return categoryTotals
    }

    
    private var categoryFiltered: [TransactionData] {
        let selectedMonthComponents = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        return datas.filter {
            let dataMonthComponents = Calendar.current.dateComponents([.year, .month], from: $0.selectedDate)
            return dataMonthComponents == selectedMonthComponents
        }
    }
    
    private func updateAmounts() {
        totalUsageAmount = calculateTotalUsageAmount()
        if monthlyLimitAmount >= totalUsageAmount {
            amounts = [
                .init(name: "月の限度額", count: monthlyLimitAmount - (monthlyLimitAmount - totalUsageAmount), color: .blue),
                .init(name: "使用金額", count: monthlyLimitAmount - totalUsageAmount, color: .gray)
            ]
        } else if monthlyLimitAmount * 2 < totalUsageAmount {
            amounts = [
                .init(name: "月の限度額", count: 0, color: .blue),
                .init(name: "使用金額", count: 1, color: .red)
            ]
        } else {
            amounts = [
                .init(name: "月の限度額", count: monthlyLimitAmount - (totalUsageAmount - monthlyLimitAmount), color: .blue),
                .init(name: "使用金額", count: monthlyLimitAmount - totalUsageAmount, color: .red.opacity(0.8))
            ]
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TransactionData.self)
}
