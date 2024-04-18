//
//  SearchView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/29.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = "" // 検索テキストを保持する変数
    @State private var searchResult: [String] = [] // 検索結果を保持する配列
    
    var body: some View {
        VStack {
            // スペースを追加して、ナビゲーションバーとテキストフィールドの間に余白を作成
            Spacer().frame(height: 30)
            // 検索テキストボックスと検索ボタンを横並びに配置
            HStack {
                TextField("検索", text: $searchText) // 検索テキストボックス
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    // 検索ボタンがタップされたときの処理
                    // ここでは検索テキストが空でない場合に検索を実行すると仮定しています
                    performSearch()
                }) {
                    Image(systemName: "magnifyingglass") // 虫眼鏡アイコン
                        .font(.system(size: 20))
                        .padding(.horizontal)
                }
            }
            
            // 検索結果をリスト形式で表示
            List(searchResult, id: \.self) { result in
                Text(result)
                    .padding()
            }
            .padding(.top)
        }
    }
    
    // 検索を実行する関数
    private func performSearch() {
        // ここで実際の検索処理を行うと仮定
        // 今回は単純に検索テキストを使ってダミーの検索結果を生成しています
        searchResult = generateDummySearchResult(for: searchText)
    }
    
    // ダミーの検索結果を生成する関数
    private func generateDummySearchResult(for searchText: String) -> [String] {
        // ダミーの検索結果を生成して返す
        // ここでは検索テキストと同じ文字列に"Result"を追加したものを5つ生成しています
        return (1...5).map { searchText + " Result \($0)" }
    }
}

#Preview {
    SearchView()
}
