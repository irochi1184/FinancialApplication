//
//  GraphView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/29.
//

import SwiftUI
import Charts

struct LineData: Identifiable {
    var id = UUID()
    var week: String
    var sales: Int
    var category: String // カテゴリを追加
}

struct GraphView: View {
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    @State private var selectedDate: Date = Date()
    @State private var selectedDateString: String = ""
    @State private var selectedDay: Date?
    
    init() {
        formatter.dateFormat = "yyyy年 MM月"
    }
    
    @State private var isDatePickerVisible = false
    
    // 選択された年と月
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    
    // 表示する年の範囲
    private let minYear: Int = 2000
    private let maxYear: Int = 2024

    let lineData_test: [LineData] = [
        .init(week: "月曜日", sales: 2000, category: "ラーメン"),
        .init(week: "火曜日", sales: 1000, category: "ラーメン"),
        .init(week: "水曜日", sales: 3000, category: "ラーメン"),
        .init(week: "月曜日", sales: 3000, category: "ハンバーグ"),
        .init(week: "火曜日", sales: 5000, category: "ハンバーグ"),
        .init(week: "水曜日", sales: 1000, category: "ハンバーグ"),
    ]
    
    var body: some View {
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
                    
                }
                .padding(.bottom, 20) // 下部に余白を追加
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
        VStack {
            Chart(lineData_test){ dataRow in
                LineMark(
                    x: .value("week", dataRow.week),
                    y: .value("sales", dataRow.sales)
                )
                .foregroundStyle(by: .value("Category", dataRow.category))
            }
            .frame(height: 300)
            Spacer()
        }
    }
}

#Preview {
    GraphView()
}
