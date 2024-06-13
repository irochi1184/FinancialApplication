//
//  Data.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/06/13.
//

import Foundation
import SwiftData

@Model
final class TransactionData {
    var isExpense: Bool
    var transactionName: String
    var selectedDate: Date
    var amount: String
    var category: String
    
    init(isExpense: Bool, transactionName: String, selectedDate: Date, amount: String, category: String) {
        print("Initializing Data with values: \(isExpense), \(transactionName), \(selectedDate), \(amount), \(category)")
        self.isExpense = isExpense
        self.transactionName = transactionName
        self.selectedDate = selectedDate
        self.amount = amount
        self.category = category
    }
}
