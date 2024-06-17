//
//  SearchView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/29.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    
    // CRUD処理下準備
    @Environment(\.modelContext) private var context
    @Query private var datas: [TransactionData]
    
    // データの削除
    private func delete(data: TransactionData) {
        context.delete(data)
    }
    
    @State private var searchText = "" // 検索テキストを保持する変数
    
    let formatter = DateFormatter()
    
    init() {
        formatter.dateFormat = "yyyy年 MM月 dd日"
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                NavigationStack {
                    NavigationLink("追加履歴", destination: AddHistoryView())
                        .font(.title3)
                        .padding(.trailing, 20)
                }
            }
            // スペースを追加して、ナビゲーションバーとテキストフィールドの間に余白を作成
            Spacer().frame(height: 20)
            // 検索テキストボックスと検索ボタンを横並びに配置
            VStack {
                ZStack {
                    // 背景
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 239 / 255,
                                    green: 239 / 255,
                                    blue: 241 / 255))
                        .frame(height: 36)
                    
                    HStack(spacing: 6) {
                        Spacer()
                            .frame(width: 0)
                        
                        // 虫眼鏡
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        // テキストフィールド
                        TextField("Search", text: $searchText)
                        
                        // 検索文字が空ではない場合は、クリアボタンを表示
                        if !searchText.isEmpty {
                            Button {
                                searchText.removeAll()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 6)
                        }
                    }
                }
                .padding(.horizontal)
            }
            Spacer().frame(height: 20)
            // 検索結果をリスト形式で表示
            NavigationStack {
                List {
                    ForEach(searchFiltered, id: \.self) { item in // フィルタリングされたリストを表示
                        VStack(alignment: .leading) {
                            Text(formatter.string(from: item.selectedDate))
                            HStack {
                                Text(item.transactionName)
                                Spacer()
                                Text(item.category)
                            }
                            HStack {
                                Spacer()
                                Text("\(item.amount)円")
                            }
                        }
                    }.onDelete(perform: { indexSet in
                        for index in indexSet {
                            delete(data: datas[index])
                        }
                    })
                }
                .listStyle(.plain)
            }
        }
    }
    
    private var searchFiltered: [TransactionData] {
        // MARK: 大文字小文字を区別する
        return searchText.isEmpty ? datas : datas.filter {
            $0.transactionName.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }
}

//#Preview {
//    SearchView()
//}

#Preview {
    ContentView()
        .modelContainer(for: TransactionData.self) // データ保存用
}
