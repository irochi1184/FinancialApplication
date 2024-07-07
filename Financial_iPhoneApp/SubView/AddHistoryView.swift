//
//  AddHistoryView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/06/14.
//

import SwiftUI
import SwiftData

struct AddHistoryView: View {
    
    enum Sort: String, CaseIterable, Identifiable {
        case date = "日付順"
        case add = "追加順"
        
        var id: String { rawValue }
        
        var emoji: String {
            switch self {
            case .date:
                return "?"
            case .add:
                return "?"
            }
        }
        
        var displayTitle: String {
            return "\(rawValue)"
        }
    }
    
    // CRUD処理下準備
    @Environment(\.modelContext) private var context
    @Query private var datas: [TransactionData] // 追加順
    @Query(sort: \TransactionData.selectedDate) private var datas2: [TransactionData] // 日付順
    
    
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedSort = Sort.add
    
    // データの削除
    private func delete(data: TransactionData) {
        context.delete(data)
    }
    
    let formatter = DateFormatter()
    
    init() {
        formatter.dateFormat = "yyyy年 MM月 dd日"
    }
    
    var body: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "chevron.left")
                Text("検索")
            }).padding(.leading, 20)
            Spacer()
            // 並べ替えボタン押した時のアクション
            Menu("並べ替え") {
                ForEach(Sort.allCases) { sort in
                    Button {
                        selectedSort = sort
                    } label: {
                        Text(sort.displayTitle)
                    }
                }
            }
            .padding(.trailing, 20)
        }
        .padding(.bottom, 40)
        VStack {
            // スペースを追加して、ナビゲーションバーとテキストフィールドの間に余白を作成
            HStack {
                
            }
            //            Spacer().frame(height: 40)
            // 検索結果をリスト形式で表示
            if (selectedSort == Sort.add) {
                List {
                    ForEach(datas.reversed()) { data in
                        VStack {
                            HStack {
                                Text(formatter.string(from: data.selectedDate))
                                Spacer()
                            }
                            HStack {
                                Text("\(data.transactionName)")
                                    .padding(.trailing, 8)
                                Spacer()
                                if data.isExpense {
                                    Text("- ¥\(data.amount)-")
                                        .foregroundColor(.black)
                                        .padding(.trailing, 8)
                                }
                                else {
                                    Text("+ ¥\(data.amount)-")
                                        .foregroundColor(.green)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    }
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            delete(data: datas[index])
                        }
                    })
                }
                .listStyle(.plain)
            } else {
                List {
                    ForEach(datas2) { data in
                        VStack {
                            HStack {
                                Text(formatter.string(from: data.selectedDate))
                                Spacer()
                            }
                            HStack {
                                Text("\(data.transactionName)")
                                    .padding(.trailing, 8)
                                Spacer()
                                if data.isExpense {
                                    Text("- ¥\(data.amount)-")
                                        .foregroundColor(.black)
                                        .padding(.trailing, 8)
                                }
                                else {
                                    Text("+ ¥\(data.amount)-")
                                        .foregroundColor(.green)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    }
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            delete(data: datas[index])
                        }
                    })
                }
                .listStyle(.plain)
            }
        }.navigationBarHidden(true)
    }
}

#Preview {
    AddHistoryView()
        .modelContainer(for: TransactionData.self) // データ保存用
}
