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
    @Query private var fetchedCategories: [CategoryData]
    @State private var categories: [CategoryData] = []
    @State private var newCategory: String = ""
    
    var body: some View {
        VStack {
            List {
                ForEach(categories) { category in
                    HStack {
                        Text(category.categoryName)
                        Spacer()
                    }
                }
                .onDelete(perform: deleteCategory)
                .onMove(perform: moveCategory)
                
                HStack {
                    TextField("新しいカテゴリー", text: $newCategory)
                    Button(action: addCategory) {
                        Text("追加")
                    }.buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("カテゴリー設定")
                    .foregroundColor(.black)
                    .font(.system(size: 20))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .onAppear {
            categories = fetchedCategories.sorted { $0.order < $1.order }
        }
    }
    
    private func addCategory() {
        if !newCategory.isEmpty {
            let newCategoryData = CategoryData(categoryName: newCategory, order: categories.count)
            context.insert(newCategoryData)
            categories.append(newCategoryData)
            newCategory = ""
            saveCategoryOrder()
        }
    }
    
    private func deleteCategory(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            context.delete(category)
            categories.remove(atOffsets: offsets)
        }
        saveCategoryOrder()
    }
    
    private func moveCategory(from source: IndexSet, to destination: Int) {
        categories.move(fromOffsets: source, toOffset: destination)
        saveCategoryOrder()
    }
    
    private func saveCategoryOrder() {
        for (index, category) in categories.enumerated() {
            category.order = index
        }
        do {
            try context.save()
        } catch {
            print("Failed to save category order: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CategoryData.self, TransactionData.self], inMemory: true)
}
