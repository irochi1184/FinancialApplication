//
//  HomeView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/29.
//

import SwiftUI
import Charts



struct FavoriteFruit {
    let name: String
    let count: Int
}

struct HomeView: View {
    
    init() {
        dateFormatter.dateFormat = "YYYY年MM月"
        dateFormatter.locale = Locale(identifier: "ja_jp")
    }
    
    @State private var favoriteFruits: [FavoriteFruit] = [
        .init(name: "りんご", count: 15),
        .init(name: "いちご", count: 12),
        .init(name: "さくらんぼ", count: 6),
        .init(name: "ぶどう", count: 5),
        .init(name: "バナナ", count: 4),
        .init(name: "オレンジ", count: 2)
    ]
    @State var showDatePicker = false
    @State var date = Date()
    @State var dateText = ""
    private let dateFormatter = DateFormatter()
    
    
    var body: some View {
        VStack {
            //            DatePicker.init("", selection: $date, displayedComponents: [.date])
            //                .labelsHidden()
            //                .datePickerStyle(.wheel)
            VStack {
                Button {
                    showDatePicker.toggle()
                } label: {
                    // Text(dateText)
                    Text(dateText.isEmpty ? "\(dateFormatter.string(from: date))" : dateText)
                        .onAppear {
                            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                self.date = Date()
                                dateText = "\(dateFormatter.string(from: date))"
                            }
                        }
                }
                
                
            }
            
            if showDatePicker {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showDatePicker = false
                    }
                DatePicker.init("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.wheel) // カレンダーを表示
                    .environment(\.locale, Locale(identifier: "ja_JP"))
            }
            
            Chart(favoriteFruits, id: \.name) { favoriteFruit in
                SectorMark(
                    angle: .value("count", favoriteFruit.count),innerRadius: .inset(30)
                )
                .foregroundStyle(by: .value("name", favoriteFruit.name))
            }
            .frame(width: 300, height: 300)
        }
    }
    
}


#Preview {
    HomeView()
}
