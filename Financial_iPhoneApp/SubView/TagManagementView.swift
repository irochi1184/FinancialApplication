//
//  TagManagementView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/09/01.
//

import SwiftUI

struct TagManagementView: View {
    @Binding var searchTags: [String] // 設定ビューから受け取ったタグリスト
    
    @AppStorage("searchTags") private var searchTagsString: String = "" // タグリストを保存するための文字列
    @State private var newTag: String = "" // 新しいタグを入力するためのテキストフィールド
    @FocusState var iskeyPadActive: Bool // キーボードのフォーカス状態
    
    var body: some View {
        VStack {
            List {
                ForEach(searchTags.indices, id: \.self) { index in
                    HStack {
                        Text(searchTags[index])
                        Spacer()
                    }
                }
                .onDelete(perform: deleteTag)
                .onMove(perform: moveTag)
                
                HStack {
                    TextField("新しいタグ", text: $newTag)
                        .focused($iskeyPadActive)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()  // 右寄せにする
                                Button("閉じる") {
                                    iskeyPadActive = false  // フォーカスを外す
                                }
                            }
                        }
                    Button(action: addTag) {
                        Text("追加")
                    }.buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("タグ管理")
                    .foregroundColor(.black)
                    .font(.system(size: 20))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .onAppear(perform: loadTags)
    }
    
    // タグを追加する関数
    private func addTag() {
        if !newTag.isEmpty {
            searchTags.append(newTag)
            newTag = ""
            saveTags()
        }
    }
    
    // タグを削除する関数
    private func deleteTag(at offsets: IndexSet) {
        searchTags.remove(atOffsets: offsets)
        saveTags()
    }
    
    // タグを移動する関数
    private func moveTag(from source: IndexSet, to destination: Int) {
        searchTags.move(fromOffsets: source, toOffset: destination)
        saveTags()
    }
    
    // タグを保存する関数
    private func saveTags() {
        if let encodedTags = try? JSONEncoder().encode(searchTags) {
            searchTagsString = String(data: encodedTags, encoding: .utf8) ?? ""
        }
    }
    
    // タグを読み込む関数
    private func loadTags() {
        if let data = searchTagsString.data(using: .utf8),
           let decodedTags = try? JSONDecoder().decode([String].self, from: data) {
            searchTags = decodedTags
        }
    }
}

#Preview {
    TagManagementView(searchTags: .constant(["食費", "交通費", "エンタメ"]))
}
