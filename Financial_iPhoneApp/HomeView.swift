//
//  HomeView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/29.
//

import SwiftUI
import Charts

struct FavoriteFruit {
    let name: String
    let count: Int
    var color: Color
}

struct HomeView: View {
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    @State private var selectedDate: Date = Date()
    @State private var selectedDateString: String = ""
    @State private var selectedDay: Date?
    
    @State private var favoriteFruits: [FavoriteFruit] = [
        .init(name: "月の限度額", count: 3, color: .blue),
        .init(name: "使用金額", count: 1, color: .gray)
    ]
    
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
            
            Divider()
            // スペースを追加
            Spacer().frame(height: 20)
            
            ZStack {
                Chart(favoriteFruits, id: \.name) { favoriteFruit in
                    SectorMark(
                        angle: .value("count", favoriteFruit.count),innerRadius: .inset(30)
                    )
                    .foregroundStyle(favoriteFruit.color)
                    
                }
                
                // 円グラフの中心に表示するテキスト
                Text("● ").foregroundColor(.gray).font(.caption) +
                Text("月の限度額：100,000円").font(.subheadline).foregroundColor(.black) +
                Text("\n● ").foregroundColor(.blue).font(.caption) +
                Text("　使用金額：75,000円").font(.subheadline).foregroundColor(.black)
                    //.offset(y: -20) // テキストを上に20ポイント移動
            }
            .frame(width: 300, height: 300)
            
            Spacer().frame(height: 30)
            
            Text("\(formatter.string(from: selectedDate))  使用内容").font(.body)
            Divider()
            // リスト表示
            List {
                Text("あいうえお")
                Text("かきくけこ")
                Text("さしすせそ")
                Text("たちつてと")
                Text("なにぬねの")
                Text("はひふへほ")
                Text("まみむめも")
                Text("やゆよ")
                Text("わをん")
            }
            .listStyle(.plain)
            
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
                    
                }.toolbar {
                    
                }
            }.presentationDetents([.height(280)]) // シートの高さ
        }
    }
}

#Preview {
    HomeView()
}
