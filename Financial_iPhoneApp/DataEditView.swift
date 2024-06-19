//
//  DataEditView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/06/20.
//

import Foundation
import SwiftUI
import SwiftData

struct DataEditView: View {
    @Binding var transaction: TransactionData
    @Environment(\.modelContext) private var context
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("取引の詳細")) {
                    TextField("取引名", text: $transaction.transactionName)
                    DatePicker("日付", selection: $transaction.selectedDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                    HStack {
                        Spacer()
                        TextField("金額", text: $transaction.amount)
                            .keyboardType(.numberPad)
                        Text("円")
                    }
                    TextField("カテゴリー", text: $transaction.category)
                }
                
                Section {
                    Button(action: { saveTransaction() })
                    {
                        Text("保存")
                    }
                }
            }
//            .navigationBarTitle("取引の編集")
            .navigationBarItems(trailing: Button("キャンセル") {
                presentationMode.wrappedValue.dismiss() // 画面を閉じて前画面に戻る
            })
        }
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
