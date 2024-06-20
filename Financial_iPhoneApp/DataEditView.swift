//
//  DataEditView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/06/20.
//

import SwiftUI
import SwiftData

struct DataEditView: View {
    @Binding var transaction: TransactionData?
    @Environment(\.modelContext) private var context
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isDatePickerVisible = false
    
    // 選択された年と月
    @State private var selectedDay: Int = Calendar.current.component(.day, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    
    // 表示する年の範囲
    private let minYear: Int = 2000
    private let maxYear: Int = 2024
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    init(transaction: Binding<TransactionData?>) {
        self._transaction = transaction
        formatter.dateFormat = "yyyy年 MM月 dd日"
    }
    
    var body: some View {
        if let transaction = transaction {
            NavigationView {
                VStack {
                    // スペースを追加して、ナビゲーションバーとテキストフィールドの間に余白を作成
                    Spacer().frame(height: 20)
                    HStack {
                        Button("戻る") {
                            self.presentationMode.wrappedValue.dismiss() // DataEditViewを閉じる
                        }.padding(.leading, 20)
                        Spacer()
                        Text("編集")
                            .padding(.trailing, 50)
                            .font(.title3)
                        Spacer()
                    }
                    Spacer()
                    
                    // --------------- 取引名 --------------- //
                    Text("取引名")
                        .bold()
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                    TextField("入力", text: Binding(
                        get: { transaction.transactionName },
                        set: { transaction.transactionName = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle()) // 枠線
                    .padding([.leading, .bottom, .trailing], 15) // 左、下、右に余白
                    .padding(.bottom, 10)
                    
                    // --------------- 日付 --------------- //
                    Text("日付")
                        .bold()
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                    HStack {
                        Button(action: {
                            // 日付の表示部分がタップされたらDatePickerを表示する
                            self.isDatePickerVisible.toggle()
                        }) {
                            Text(formatter.string(from: transaction.selectedDate))
                                .foregroundStyle(.blue)
                            Spacer()
                            Image(systemName: "calendar")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(7)
                    }
                    .overlay(RoundedRectangle(cornerRadius: 4) // 枠線の角丸
                        .stroke(.gray, lineWidth: 0.18)) // 枠線の色と太さ
                    .padding([.leading, .bottom, .trailing], 15) // 左、下、右に余白
                    .padding(.bottom, 10)
                    
                    // --------------- 金額 --------------- //
                    Text("金額")
                        .bold()
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                    TextField("金額 (円)", text: Binding(
                        get: { transaction.amount },
                        set: { transaction.amount = $0 }
                    ))
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle()) // 枠線
                    .padding([.leading, .bottom, .trailing], 15) // 左、下、右に余白
                    .padding(.bottom, 10)
                    
                    // --------------- カテゴリー選択 --------------- //
                    Text("カテゴリー選択")
                        .bold()
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                    HStack {
                        NavigationLink(destination: CategorySelectionView(selectedCategory: Binding(
                            get: { transaction.category },
                            set: { transaction.category = $0 }
                        ))) {
                            Text(transaction.category.isEmpty ? "カテゴリー選択" : transaction.category)
                                .foregroundColor(.gray.opacity(0.6))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(7)
                    }
                    .overlay(RoundedRectangle(cornerRadius: 4) // 枠線の角丸
                        .stroke(.gray, lineWidth: 0.18)) // 枠線の色と太さ
                    .padding([.leading, .bottom, .trailing], 15) // 左、下、右に余白
                    .padding(.bottom, 30)
                    
                    Button(action: {
                        // 「保存」ボタンのアクション
                        saveTransaction()
                    }) {
                        Text("保存")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .padding(10)
                    
                    Spacer()
                    
                }
                .navigationBarHidden(true)
            }
            .sheet(isPresented: $isDatePickerVisible) {
                // 年月のピッカーを表示するためのシート
                VStack {
                    // DatePickerを閉じるボタン
                    Button(action: {
                        self.isDatePickerVisible = false
                        // 選択された年月からDateを生成
                        transaction.selectedDate = self.calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: selectedDay)) ?? Date()
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
                        .frame(maxWidth: .infinity)
                        
                        // 月のピッカー
                        Picker("Month", selection: $selectedMonth) {
                            ForEach(1...12, id: \.self) { month in
                                Text("\(month)月")
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)
                        
                        // 日のピッカー
                        Picker("Day", selection: $selectedDay) {
                            ForEach(1...numberOfDays(in: selectedMonth), id: \.self) { day in
                                Text("\(day)日")
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)
                    }
                }.presentationDetents([.height(280)]) // シートの高さ
            }
        }
    }
    
    struct CategorySelectionView: View {
        @Binding var selectedCategory: String
        let categories = ["食費", "雑費", "家賃", "娯楽費", "電気代", "水道代", "交通費", "書籍代"] // Example categories
        
        var body: some View {
            List {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        HStack {
                            Text(category)
                            if selectedCategory == category {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                Spacer()
                Text("新規追加")
            }
        }
    }
    
    private func numberOfDays(in month: Int) -> Int {
        let dateComponents = DateComponents(year: selectedYear, month: month)
        if let date = calendar.date(from: dateComponents),
           let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        }
        return 31 // デフォルトでは31日を返す
    }
    
    private func saveTransaction() {
        do {
            try context.save()
            presentationMode.wrappedValue.dismiss() // 画面を閉じて前画面に戻る
        } catch {
            print("Error saving transaction: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TransactionData.self) // データ保存用
}
