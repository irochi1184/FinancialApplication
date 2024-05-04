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
    var month: String
    var amount: Int
    var category: String // カテゴリを追加
}

struct GraphView: View {
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    @State private var selectedDate: Date = Date()
    @State private var selectedDateString: String = ""
    @State private var selectedDay: Date?
    
    init() {
        formatter.dateFormat = "yyyy年"
    }
    
    @State private var isDatePickerVisible = false
    
    // 選択された年
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
    // 表示する年の範囲
    private let minYear: Int = 2000
    private let maxYear: Int = 2024
    
    let lineData_test: [LineData] = [
        .init(month: "1月", amount: 1000, category: "all"),
        .init(month: "2月", amount: 2000, category: "all"),
        .init(month: "3月", amount: 3000, category: "all"),
        .init(month: "4月", amount: 4000, category: "all"),
        .init(month: "5月", amount: 5000, category: "all"),
        .init(month: "6月", amount: 6000, category: "all"),
        .init(month: "7月", amount: 1000, category: "all"),
        .init(month: "8月", amount: 2000, category: "all"),
        .init(month: "9月", amount: 3000, category: "all"),
        .init(month: "10月", amount: 4000, category: "all"),
        .init(month: "11月", amount: 5000, category: "all"),
        .init(month: "12月", amount: 6000, category: "all"),
    ]
    
    @State  var isOn:Bool = true
    @State  var isOn1:Bool = true
    @State  var isOn2:Bool = true
    
    var body: some View {
        VStack{
            VStack {
                // 月の切り替えボタン
                HStack {
                    Button(action: {
                        self.selectedDate = self.calendar.date(byAdding: .month, value: -1, to: self.selectedDate)!
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
                Chart(lineData_test){ dataRow in
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
                List{
                    Toggle(isOn: $isOn){
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
    }
}

#Preview {
    GraphView()
}
