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
    
    @State private var isEditViewPresented = false // 編集画面の表示状態
    @State private var selectedTransaction: TransactionData? // 選択された取引データ
    @FocusState var iskeyPadActive: Bool // keyPad閉じる用
    
    @State private var searchText = "" // 検索テキストを保持する変数
    @State private var showDeleteAllAlert = false // 全件削除確認アラートの表示状態
    @State private var selectedSort = Sort.add // 並べ替えの選択状態
    
    let formatter = DateFormatter()
    
    init() {
        formatter.dateFormat = "yyyy年 MM月 dd日"
    }
    
    enum Sort: String, CaseIterable, Identifiable {
        case date = "日付順"
        case add = "追加順"
        
        var id: String { rawValue }
        
        var displayTitle: String {
            return "\(rawValue)"
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("全件削除") {
                    showDeleteAllAlert = true
                }
                .font(.title3)
                .foregroundStyle(.red)
                .padding(.leading, 20)
                .alert(isPresented: $showDeleteAllAlert) {
                    Alert(
                        title: Text("全てのデータを削除します。\nよろしいですか？"),
                        primaryButton: .destructive(Text("OK")) {
                            deleteAll()
                        },
                        secondaryButton: .cancel(Text("キャンセル"))
                    )
                }
                Spacer()
                // 「並べ替え」ボタンの追加
                Menu("並べ替え") {
                    ForEach(Sort.allCases) { sort in
                        Button {
                            selectedSort = sort
                        } label: {
                            Text(sort.displayTitle)
                        }
                    }
                }
                .font(.title3)
                .padding(.trailing, 20)
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
                            .focused($iskeyPadActive)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()  // 右寄せにする
                                    Button("閉じる") {
                                        iskeyPadActive = false  // フォーカスを外す
                                    }
                                }
                            }
                        
                        // 検索文字が空ではない場合は、クリアボタンを表示
                        if (!searchText.isEmpty) {
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
                        .contentShape(Rectangle()) // HStack全体をタップ可能にする
                        .onTapGesture {
                            selectedTransaction = item
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                delete(data: item)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }
                .id(UUID())
                .listStyle(.plain)
                .sheet(item: $selectedTransaction, onDismiss: {
                    isEditViewPresented = false
                }) { transaction in
                    DataEditView(transaction: $selectedTransaction)
                        .onDisappear {
                            if context.hasChanges {
                                do {
                                    try context.save()
                                } catch {
                                    print("Failed to save context: \(error.localizedDescription)")
                                }
                            }
                        }
                }
            }
        }
    }
    
    private var searchFiltered: [TransactionData] {
        let filtered = searchText.isEmpty ? datas : datas.filter {
            $0.transactionName.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
        
        switch selectedSort {
        case .add:
            return filtered.reversed()
        case .date:
            return filtered.sorted { $0.selectedDate < $1.selectedDate }
        }
    }
    
    // データの削除
    private func delete(data: TransactionData) {
        context.delete(data)
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
    
    // データの全件削除
    private func deleteAll() {
        for data in datas {
            context.delete(data)
        }
        do {
            try context.save()
        } catch {
            print("Failed to save context after deleting all items: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView(model: AppModel())
        .modelContainer(for: [CategoryData.self, TransactionData.self], inMemory: true)
}
