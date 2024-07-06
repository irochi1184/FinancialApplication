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
    @State var menuExpanded: Bool = false      // 詳細を隠す
    
    // エラーメッセージ表示用
    @State private var errorMessage: String?
    
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
    
    // フォーム用の一時的な変数
    @State private var tempTransactionName: String = ""
    @State private var tempSelectedDate: Date = Date()
    @State private var tempAmount: String = ""
    @State private var tempCategory: String = ""
    @State private var tempMemo: String = ""
    
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
                    TextField("入力", text: $tempTransactionName)
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
                            Text(formatter.string(from: tempSelectedDate))
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
                    TextField("金額 (円)", text: $tempAmount)
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
                        NavigationLink(destination: CategorySelectionView(selectedCategory: $tempCategory)) {
                            Text(tempCategory.isEmpty ? "カテゴリー選択" : tempCategory)
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
                    
                    // --------------- 詳細（メモ） --------------- //
                    HStack {
                        Text("詳細")
                            .bold()
                            .foregroundColor(.gray)
                            .padding(.leading, 15)
                        Image(systemName: menuExpanded ? "chevron.down" : "chevron.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 12))
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            menuExpanded.toggle()
                        }
                    }
                    
                    if menuExpanded {
                        VStack {
                            TextField("入力", text: $tempMemo, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle()) // 枠線
                                .padding(.bottom, 15)
                        }
                        .padding([.leading, .bottom, .trailing], 15) // 左、下、右に余白
                    }
                    
                    // エラーメッセージ表示
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Button(action: {
                        // エラーメッセージをクリア
                        errorMessage = nil
                        
                        // 入力チェック
                        var errorMessages = [String]()
                        
                        if tempTransactionName.isEmpty {
                            errorMessages.append("取引名が未入力です。")
                        }
                        if tempAmount.isEmpty {
                            errorMessages.append("金額が未入力です。")
                        }
                        if tempCategory.isEmpty {
                            errorMessages.append("カテゴリーが未選択です。")
                        }
                        
                        if !errorMessages.isEmpty {
                            // エラーメッセージを結合して表示
                            errorMessage = errorMessages.joined(separator: "\n")
                        } else {
                            // エラーメッセージをクリア
                            errorMessage = nil
                            // 「保存」ボタンのアクション
                            saveTransaction()
                        }
                    }) {
                        Text("保存")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .padding(.top, 10)
                    .padding(10)
                    
                    Spacer()
                    
                }
                .navigationBarHidden(true)
                .onAppear {
                    // 初期値を設定
                    tempTransactionName = transaction.transactionName
                    tempSelectedDate = transaction.selectedDate
                    tempAmount = transaction.amount
                    tempCategory = transaction.category
                    tempMemo = transaction.memo
                }
            }
            .sheet(isPresented: $isDatePickerVisible) {
                DayPickerView(
                    isDatePickerVisible: $isDatePickerVisible,
                    selectedYear: $selectedYear,
                    selectedMonth: $selectedMonth,
                    selectedDay: $selectedDay,
                    minYear: minYear,
                    maxYear: maxYear,
                    onDateSelected: {
                        tempSelectedDate = self.calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: selectedDay)) ?? Date()
                    }
                )
            }
        }
    }
    
    private func saveTransaction() {
        if let transaction = transaction {
            transaction.transactionName = tempTransactionName
            transaction.selectedDate = tempSelectedDate
            transaction.amount = tempAmount
            transaction.category = tempCategory
            transaction.memo = tempMemo
            
            do {
                try context.save()
                presentationMode.wrappedValue.dismiss() // 画面を閉じて前画面に戻る
            } catch {
                print("Error saving transaction: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TransactionData.self) // データ保存用
}
