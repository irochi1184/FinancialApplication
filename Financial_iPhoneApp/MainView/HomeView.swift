//
//  HomeView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/29.
//

import SwiftUI
import SwiftData
import Charts
import Combine

// データの変更を監視するオブジェクト
class TransactionDataStore: ObservableObject {
    @Published var datas: [TransactionData] = []
}

// タブ構造体: 各タブの情報を保持
struct Tab: Identifiable {
    var id: UUID = .init() // 一意なID
    let title: String      // タブのタイトル
    let color: Color       // タブの色
}

// 金額構造体: 各金額の情報を保持
struct Amounts: Identifiable {
    var id = UUID()
    let name: String       // 金額の名前（カテゴリ）
    let count: Int         // 金額の数値
    var color: Color       // 表示する色
}

// カテゴリの設定: カテゴリごとの初期データを定義
private var category: [Amounts] = [
    .init(name: "none", count: 1, color: .gray.opacity(0.8))
]

struct HomeView: View {
    @EnvironmentObject var dataStore: TransactionDataStore // データの変更を監視
    
    @State private var category: [Amounts] = []
    @State private var cachedCategory: [Amounts] = []
    @State private var cachedAmounts: [Amounts] = []
    @State private var isDataChanged = false
    
    let calendar = Calendar.current  // カレンダー
    let formatter = DateFormatter()  // 日付フォーマッター1: "yyyy年 MM月"
    let formatter2 = DateFormatter() // 日付フォーマッター2: "MM月dd日"
    
    @Query private var datas: [TransactionData] // トランザクションデータの取得
    
    @State private var selectedDate: Date = Date()                                           // 選択された日付(初期値は今日日付)
    @State private var totalUsageAmount: Int = 0                                             // 使用金額の合計
    @AppStorage("monthlyLimitAmount") private var monthlyLimitAmount: Int = 100000           // 月の限度額
    @State private var amounts: [Amounts] = []                                               // 金額の配列
    @State private var isDatePickerVisible = false                                           // DatePickerの表示状態
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())   // 選択された年
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date()) // 選択された月
    @State private var isExpense: Bool = true                                                // タブの状態（利用詳細/カテゴリー別）
    
    @State private var isEditViewPresented = false // 取引編集画面の表示状態
    @State private var selectedTransaction: TransactionData? // 選択されたトランザクションデータ
    
    // 初期化
    init() {
        // UISegmentedControlの外観をカスタマイズ
        UISegmentedControl.appearance().backgroundColor = UIColor(Color.gray.opacity(0.1))
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.cyan)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        // 日付フォーマットを設定
        formatter.dateFormat = "yyyy年 MM月"
        formatter2.dateFormat = "MM月dd日"
    }
    
    var body: some View {
        ZStack {
            VStack (spacing : 0){
                HeaderView(formatter: formatter, selectedDate: $selectedDate, calendar: calendar, isDatePickerVisible: $isDatePickerVisible, onChangeMonth: changeMonth) // ヘッダー
                tabPickerView    // ピッカービューの表示
                Divider() // 区切り線
                tabAndGraphView  // タブとグラフ部分の表示
            }
            FloatingButton()     // フローティングボタンの表示
        }
        .onAppear {
            updateData() // 画面が表示されたときにデータを更新
        }
        .onChange(of: dataStore.datas) {
            updateData() // データが変更されたときにデータを更新
        }
        .onChange(of: selectedDate) {
            updateData() // 日付が変更されたときにデータを更新
        }
    }
    
    // ピッカービュー
    private var tabPickerView: some View {
        Section {
            Picker(selection: $isExpense, label: Text("項目")) {
                Text("利用詳細").tag(true)
                Text("カテゴリー別").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding([.leading, .trailing], 15) // 左、下、右に余白
        .padding(.bottom, 10)
    }
    
    // タブとグラフ部分のビュー
    private var tabAndGraphView: some View {
        TabView(selection: $isExpense) { // TabViewを使用してページング機能を実装
            ScrollView {
                home1View
            }
            .tag(true)
            .tabItem { Text("利用詳細") }
            
            ScrollView {
                home2View
            }
            .tag(false)
            .tabItem { Text("カテゴリー別") }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // ページングスタイルの設定
    }
    
    // 利用詳細のビュー
    private var home1View: some View {
        VStack {
            Spacer().frame(height: 20)
            ZStack {
                if !cachedAmounts.isEmpty {
                    Chart(cachedAmounts, id: \.id) { amount in // 円グラフの表示
                        SectorMark(
                            angle: .value("count", amount.count),
                            innerRadius: .inset(30)
                        )
                        .foregroundStyle(amount.color)
                    }
                    .frame(height: 300)
                } else {
                    Text("データがありません").foregroundColor(.gray).frame(height: 300)
                }
                
                // 円グラフの中心に表示するテキスト
                VStack {
                    Text("● ").foregroundColor(.gray.opacity(0.8)).font(.caption) +
                    Text("月の限度額：\(monthlyLimitAmount)円").font(.subheadline).foregroundColor(.black)
                    Text("● ").foregroundColor(.blue).font(.caption) +
                    Text("使用金額：\(calculateTotalUsageAmount())円").font(.subheadline).foregroundColor(.black)
                    if calculateTotalUsageAmount() > monthlyLimitAmount {
                        Text("● ").foregroundColor(.red).font(.caption) +
                        Text("超過金額：\(calculateTotalUsageAmount() - monthlyLimitAmount)円").font(.subheadline).foregroundColor(.black)
                    }
                }
            }
            .frame(width: 300, height: 300)
            Spacer().frame(height: 20)
            Text("使用内容").font(.headline).frame(maxWidth: 350, alignment: .leading)
            Divider() // 区切り線
            transactionListView // 取引リストビューの表示
        }
        .padding(.bottom, 20)
        .sheet(isPresented: $isDatePickerVisible) { // DatePickerの表示
            DatePickerView(
                isDatePickerVisible: $isDatePickerVisible,
                selectedYear: $selectedYear,
                selectedMonth: $selectedMonth,
                minYear: 2000,
                maxYear: 2024,
                onDateSelected: {
                    self.selectedDate = self.calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth)) ?? Date()
                    updateData() // 日付が選択されたときにデータを更新
                }
            )
        }
    }
    
    // カテゴリー別のビュー
    private var home2View: some View {
        VStack {
            Spacer().frame(height: 20)
            ZStack {
                if !cachedCategory.isEmpty {
                    Chart(cachedCategory.sorted(by: { $0.count > $1.count }), id: \.id) { amount in // 円グラフの表示
                        SectorMark(
                            angle: .value("count", amount.count),
                            innerRadius: .inset(30)
                        )
                        .foregroundStyle(amount.color)
                    }
                    .frame(height: 300)
                } else {
                    Text("データがありません").foregroundColor(.gray).frame(height: 300)
                }
                
                // 円グラフの中心に表示するテキスト
                VStack {
                    ForEach(cachedCategory.sorted(by: { $0.count > $1.count }), id: \.id) { amount in // カテゴリデータをリスト表示
                        HStack {
                            Spacer()
                            Text("●").foregroundColor(amount.color).font(.caption) +
                            Text(" \(amount.name)：") + // カテゴリ名の表示
                            Text("\(amount.count)円") // 合計金額の表示
                            Spacer()
                        }
                    }
                }
            }
            .frame(width: 300, height: 300)
            Spacer().frame(height: 30)
            Text("カテゴリ内容").font(.headline).frame(maxWidth: 350, alignment: .leading)
            Divider() // 区切り線
            categoryListView // カテゴリリストビューの表示
        }
        .padding(.bottom, 20)
        .sheet(isPresented: $isDatePickerVisible) { // DatePickerの表示
            DatePickerView(
                isDatePickerVisible: $isDatePickerVisible,
                selectedYear: $selectedYear,
                selectedMonth: $selectedMonth,
                minYear: 2000,
                maxYear: 2024,
                onDateSelected: {
                    self.selectedDate = self.calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth)) ?? Date()
                    updateData() // 日付が選択されたときにデータを更新
                }
            )
        }
    }
    
    // 取引リストビュー
    private var transactionListView: some View {
        List(dateFiltered, id: \.self) { item in // トランザクションデータをリスト表示
            VStack(alignment: .leading) {
                HStack {
                    Text(formatter2.string(from: item.selectedDate)) // 日付の表示
                    Text(item.transactionName) // トランザクション名の表示
                    Spacer()
                    Text("\(item.amount)円") // 金額の表示
                }
            }
            .contentShape(Rectangle()) // 全体をタップ可能にする
            .onTapGesture {
                selectedTransaction = item
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isEditViewPresented.toggle()
                }
            }
        }
        .id(UUID())
        .listStyle(.plain)
        .scrollDisabled(true) // スクロールビューの中でスクロールができないよう設定
        .frame(height: CGFloat(dateFiltered.count) * 50) // 1項目あたりの高さを50と仮定して計算
        .sheet(item: $selectedTransaction) { transaction in
            DataEditView(transaction: $selectedTransaction)
        }
    }
    
    // カテゴリリストビュー
    private var categoryListView: some View {
        List(TotalCategoryData.keys.sorted(by: { TotalCategoryData[$0]! > TotalCategoryData[$1]! }), id: \.self) { category in // カテゴリデータをリスト表示
            HStack {
                Text(category) // カテゴリ名の表示
                Spacer()
                Text("\(TotalCategoryData[category] ?? 0)円") // 合計金額の表示
            }
        }
        .id(UUID())
        .listStyle(.plain)
        .scrollDisabled(true) // スクロールビューの中でスクロールができないよう設定
        .frame(height: CGFloat(TotalCategoryData.keys.count) * 50) // 1項目あたりの高さを50と仮定して計算
    }
    
    // 金額計算
    private func calculateTotalUsageAmount() -> Int {
        dateFiltered.reduce(0) { $0 + ($1.amount as NSString).integerValue } // 使用金額の合計を計算
    }
    
    // 月ごとにフィルタリングされたトランザクションデータ
    private var dateFiltered: [TransactionData] {
        let selectedMonthComponents = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        return datas.filter {
            let dataMonthComponents = Calendar.current.dateComponents([.year, .month], from: $0.selectedDate)
            return dataMonthComponents == selectedMonthComponents
        }.sorted { $0.selectedDate > $1.selectedDate } // トランザクションデータを日付順にソート
    }
    
    // カテゴリごとの合計金額を計算するプロパティ
    private var TotalCategoryData: [String: Int] {
        var categoryTotals: [String: Int] = [:] // カテゴリごとの合計金額を保持する辞書を初期化
        for transaction in dateFiltered {       // フィルタリングされたトランザクションデータをループで処理
            let category = transaction.category // 各トランザクションのカテゴリを取得
            let amount = (transaction.amount as NSString).integerValue // 各トランザクションの金額を整数に変換して取得
            if let total = categoryTotals[category] { // 辞書にカテゴリが既に存在するかをチェック
                categoryTotals[category] = total + amount // カテゴリが存在する場合、そのカテゴリの合計金額に今回の金額を加算
            } else {
                categoryTotals[category] = amount // カテゴリが存在しない場合、新しいカテゴリーで金額を辞書に追加
            }
        }
        return categoryTotals // カテゴリごとの合計金額を返す
    }
    
    // 月の変更
    private func changeMonth(by value: Int) {
        selectedDate = calendar.date(byAdding: .month, value: value, to: selectedDate)!
        updateData() // 月が変更されたときにデータを更新
    }
    
    // データの更新
    private func updateData() {
        updateAmounts() // 使用金額の更新
        updateCategories() // カテゴリの更新
    }
    
    // 使用金額の更新
    private func updateAmounts() {
        totalUsageAmount = calculateTotalUsageAmount() // 使用金額を計算
        if monthlyLimitAmount >= totalUsageAmount { // 使用金額が月の限度額以下の場合
            amounts = [
                .init(name: "月の限度額", count: monthlyLimitAmount - (monthlyLimitAmount - totalUsageAmount), color: .blue),
                .init(name: "使用金額", count: monthlyLimitAmount - totalUsageAmount, color: .gray.opacity(0.8))
            ]
        } else if monthlyLimitAmount * 2 < totalUsageAmount { // 使用金額が月の限度額の倍以上の場合
            amounts = [
                .init(name: "月の限度額", count: 0, color: .blue),
                .init(name: "使用金額", count: 1, color: .red)
            ]
        } else { // 使用金額が月の限度額を超えるが倍未満の場合
            amounts = [
                .init(name: "月の限度額", count: monthlyLimitAmount - (totalUsageAmount - monthlyLimitAmount), color: .blue),
                .init(name: "使用金額", count: monthlyLimitAmount - totalUsageAmount, color: .red.opacity(0.8))
            ]
        }
        cachedAmounts = amounts
    }
    
    // カテゴリーの更新
    private func updateCategories() {
        let colors: [Color] = [.cyan, .green, .yellow, .purple, .pink, .orange, .blue, .teal, .indigo, .red ]
        var colorIndex = 0
        category = TotalCategoryData.keys.sorted(by: { TotalCategoryData[$0]! > TotalCategoryData[$1]! }).map { categoryName in
            let color = colors[colorIndex % colors.count]
            colorIndex += 1
            return Amounts(name: categoryName, count: TotalCategoryData[categoryName] ?? 0, color: color)
        }
        cachedCategory = category
    }
    
    // フローティングボタン
    struct FloatingButton: View {
        @State private var isPresented: Bool = false // 画面遷移の状態
        
        var body: some View {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { isPresented = true }, label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                    })
                    .sheet(isPresented: $isPresented) {
                        PlusView() // 画面遷移先のビュー
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
}

#Preview {
    ContentView(model: AppModel())
        .modelContainer(for: [CategoryData.self, TransactionData.self], inMemory: true)
}
