//
//  CalenderView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/29.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    
    @Query private var datas: [TransactionData]
    @Environment(\.modelContext) private var context
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    let formatter2 = DateFormatter()
    let weekDays = ["日", "月", "火", "水", "木", "金", "土"]
    
    @State private var selectedDate: Date = Date()
    @State private var selectedDateString: String = ""
    @State private var selectedDay: Date?
    @State private var isListVisible = false // リストの表示状態
    @State private var isEditViewPresented = false // 編集画面の表示状態
    @State private var selectedTransaction: TransactionData? // 選択された取引データ
    @State private var isDatePickerVisible = false // DatePickerの表示状態
    
    // 選択された年と月
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    
    // 表示する年の範囲
    private let minYear: Int = 2000
    private let maxYear: Int = 2024
    
    init() {
        formatter.dateFormat = "yyyy年 MM月"
        formatter2.locale = Locale(identifier: "ja_JP")
        formatter2.dateFormat = "yyyy年M月dd日(EE)"
    }
    
    var body: some View {
        VStack {
            HeaderView(
                formatter: formatter,
                selectedDate: $selectedDate,
                calendar: calendar,
                isDatePickerVisible: $isDatePickerVisible,
                onChangeMonth: changeMonth
            )
            Divider()
            weekDaysView
            Divider()
            calendarDaysView
            
            Divider() // カレンダーと下部の区切り線
            selectedDateView
            transactionListView
            
        }
        .sheet(isPresented: $isDatePickerVisible) {
            DatePickerView(
                isDatePickerVisible: $isDatePickerVisible,
                selectedYear: $selectedYear,
                selectedMonth: $selectedMonth,
                minYear: minYear,
                maxYear: maxYear,
                onDateSelected: {
                    self.selectedDate = self.calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth)) ?? Date()
                }
            )
        }
        .onAppear {
            // ビューが表示されたときに初期値を設定
            let today = Date()
            self.selectedDate = today
            self.selectedDay = today
            self.selectedDateString = formatter2.string(from: today)
            self.isListVisible = true
        }
    }
    
    private var weekDaysView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 0) {
            ForEach(weekDays, id: \.self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
                    .padding(4)
                    .foregroundColor(self.textColor(for: day))
            }
        }
        .padding(.horizontal)
    }
    
    private var calendarDaysView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 0) {
            ForEach(getCalendarMatrix(), id: \.self) { week in
                ForEach(week.indices, id: \.self) { index in
                    if let date = week[index] {
                        Button(action: {
                            self.selectedDateString = formatter2.string(from: date)
                            self.selectedDay = date
                            self.selectedDate = date
                        }) {
                            Text(self.getDayText(date: date))
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .foregroundColor(self.textColor(for: date))
                                .background(
                                    calendar.isDateInToday(date) ? Color.gray.opacity(0.2) :
                                        (self.selectedDay == date ? Color.cyan.opacity(0.2) : Color.white)
                                ) // 背景色を選択状態に応じて変更
                                .bold(self.selectedDay == date)
                        }
                    } else {
                        // 前月の日付は空白
                        Text("")
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color.white)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var selectedDateView: some View {
        Text(selectedDateString.isEmpty ? formatter2.string(from: selectedDate) : selectedDateString)
            .frame(maxWidth: 350, alignment: .leading)
            .font(.headline)
            .padding()
    }
    
    private var transactionListView: some View {
        List(dateFiltered, id: \.self) { item in // フィルタリングされたリストを表示
            VStack(alignment: .leading) {
                HStack {
                    Text(item.transactionName)
                    Spacer()
                    Text("\(item.amount)円")
                }
                .contentShape(Rectangle()) // HStack全体をタップ可能にする
                .onTapGesture {
                    selectedTransaction = item
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isEditViewPresented.toggle()
                    }
                }
            }
        }
        .listStyle(.plain)
        .sheet(item: $selectedTransaction) { transaction in
            DataEditView(transaction: $selectedTransaction)
        }
    }
    
    // 月の変更
    private func changeMonth(by value: Int) {
        selectedDate = calendar.date(byAdding: .month, value: value, to: selectedDate)!
    }
    
    // カレンダーの日付選択時のフィルタリング
    private var dateFiltered: [TransactionData] {
        guard let selectedDay = selectedDay else { return [] }
        let selectedDayComponents = Calendar.current.dateComponents([.year, .month, .day], from: selectedDay)
        return datas.filter {
            let dataDayComponents = Calendar.current.dateComponents([.year, .month, .day], from: $0.selectedDate)
            return dataDayComponents == selectedDayComponents
        }.sorted { // フィルター結果を昇順で表示
            $0.selectedDate < $1.selectedDate
        }
    }
    
    // 日付または曜日のテキストの色を設定する
    func textColor(for component: Any) -> Color {
        if let date = component as? Date {
            let weekday = calendar.component(.weekday, from: date)
            if weekday == 1 { // 日曜日
                return .red
            } else if weekday == 7 { // 土曜日
                return .blue
            } else {
                return .primary
            }
        } else if let day = component as? String {
            if day == "日" {
                return .red
            } else if day == "土" {
                return .blue
            } else {
                return .primary
            }
        } else {
            return .primary
        }
    }
    
    // 日付を取得して文字列に変換する
    func getDayText(date: Date?) -> String {
        guard let date = date else { return "" }
        let day = self.calendar.component(.day, from: date)
        return "\(day)"
    }
    
    // カレンダーの日付を2次元配列に変換する
    func getCalendarMatrix() -> [[Date?]] {
        let year = calendar.component(.year, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        let startOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        let startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startOfMonth))!
        let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        var calendarMatrix: [[Date?]] = Array(repeating: Array(repeating: nil, count: 7), count: 6)
        var currentDate = startDate
        var weekIndex = 0
        
        while currentDate <= endDate {
            let dayOfWeek = calendar.component(.weekday, from: currentDate) - 1
            
            // 日付が現在の月に属する場合のみ表示
            if calendar.component(.month, from: currentDate) == month {
                calendarMatrix[weekIndex][dayOfWeek] = currentDate
            }
            
            // 日曜日の場合、次の週へ移動
            if dayOfWeek == 6 {
                weekIndex += 1
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return calendarMatrix
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CategoryData.self, TransactionData.self], inMemory: true)
}
