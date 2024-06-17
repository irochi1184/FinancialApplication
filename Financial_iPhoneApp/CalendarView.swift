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
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    let formatter2 = DateFormatter()
    let weekDays = ["日", "月", "火", "水", "木", "金", "土"]
    
    @State private var selectedDate: Date = Date()
    @State private var selectedDateString: String = ""
    @State private var selectedDay: Date?
    @State private var isListVisible = false // リストの表示状態
    
    init() {
        formatter.dateFormat = "yyyy年 MM月"
        formatter2.locale = Locale(identifier: "ja_JP")
        formatter2.dateFormat = "yyyy年M月dd日(EE)"
    }
    
    @State private var isDatePickerVisible = false
    
    // 選択された年と月
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    
    // 表示する年の範囲
    private let minYear: Int = 2000
    private let maxYear: Int = 2024
    
    var body: some View {
        VStack {
            VStack {
                // 月の切り替えボタン
                HStack {
                    Button(action: {
                        self.selectedDate = self.calendar.date(byAdding: .month, value: -1, to: self.selectedDate)!
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
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // 曜日の表示
                LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 0) {
                    ForEach(weekDays, id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .padding(4)
                            .foregroundColor(self.textColor(for: day))
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // カレンダーの日付を表示
                LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 0) {
                    ForEach(getCalendarMatrix(), id: \.self) { week in
                        ForEach(week, id: \.self) { date in
                            Button(action: {
                                if let date = date {
                                    self.selectedDateString = formatter2.string(from: date)
                                    self.selectedDay = date
                                    self.isListVisible = true // 日付が選択されたらリストを表示
                                } else {
                                    self.selectedDateString = ""
                                    self.selectedDay = nil
                                    self.isListVisible = false // 日付が選択解除されたらリストを非表示
                                }
                                if let selectedDay = self.selectedDay {
                                    selectedDate = selectedDay
                                }
                            }) {
                                if date != nil {
                                    Text(self.getDayText(date: date!))
                                        .frame(maxWidth: .infinity)
                                        .padding(8)
                                        .foregroundColor(self.textColor(for: date!))
                                        .background(self.selectedDay == date ? Color.green.opacity(0.5) : Color.white) // 背景色を選択状態に応じて変更
                                        .bold(self.selectedDay == date)
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
                }
                .padding(.horizontal)
//                .padding(.bottom, 20) // 下部に余白を追加
                
                Divider() // カレンダーと下部の区切り線
                
                // 選択された日付を表示するテキスト
                if selectedDateString.elementsEqual("") {
                    Text("\(formatter2.string(from: selectedDate))")
                        .frame(maxWidth: 350, alignment: .leading)
                        .font(.headline)
                        .padding()
                } else {
                    Text("\(selectedDateString)")
                        .frame(maxWidth: 350, alignment: .leading)
                        .font(.headline)
                        .padding()
                }
                
                // 費用項目のリストを表示
                List(dateFiltered, id: \.self) { item in // フィルタリングされたリストを表示
                    VStack(alignment: .leading) {
                        HStack {
                            Text(item.transactionName)
                            Spacer()
                            Text("\(item.amount)円")
                        }
                    }
                }
                .listStyle(.plain)
//                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                
            }
            .sheet(isPresented: $isDatePickerVisible) {
                // 年月のピッカーを表示するためのシート
                VStack {
                    // DatePickerを閉じるボタン
                    Button(action: {
                        self.isDatePickerVisible = false
                        // 選択された年月からDateを生成
                        self.selectedDate = self.calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth)) ?? Date()
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
                        
                        // 月のピッカー
                        Picker("Month", selection: $selectedMonth) {
                            ForEach(1...12, id: \.self) { month in
                                Text("\(month)月")
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)
                        
                    }
                }.presentationDetents([.height(280)]) // シートの高さ
            }
            Spacer()
        }
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
    
    // 日付から曜日を取得する関数
    func getDayOfWeek(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP") // 日本語のロケールを設定
        dateFormatter.dateFormat = "(EEE)" // 曜日を省略形式で表示
        return dateFormatter.string(from: date)
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
        return (day == 1 ? "1" : "\(day)")
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
        .modelContainer(for: TransactionData.self) // データ保存用
}
