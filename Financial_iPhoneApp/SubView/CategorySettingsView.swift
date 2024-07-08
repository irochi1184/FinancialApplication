//
//  CategorySettingsView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/08.
//

import Foundation
import SwiftData
import SwiftUI

struct CategorySettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var categories: [CategoryData]
    @State private var newCategory: String = ""
    
    var body: some View {
        VStack {
            EditButton()
            List {
                ForEach(categories) { category in
                    HStack {
                        Text(category.categoryName)
                        Spacer()
                    }
                }
                .onDelete(perform: deleteCategory(at:))
                
                HStack {
                    TextField("新しいカテゴリー", text: $newCategory)
                    Button(action: addCategory) {
                        Text("追加")
                    }.buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .navigationTitle("カテゴリー設定")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func addCategory() {
        if !newCategory.isEmpty {
            let newCategoryData = CategoryData(categoryName: newCategory)
            context.insert(newCategoryData)
            newCategory = ""
        }
    }
    
    private func deleteCategory(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            context.delete(category)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CategoryData.self, TransactionData.self], inMemory: true)
}
