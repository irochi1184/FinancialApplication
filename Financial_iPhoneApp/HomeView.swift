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
    @State private var favoriteFruits: [FavoriteFruit] = [
        .init(name: "りんご", count: 15),
        .init(name: "いちご", count: 12),
        .init(name: "さくらんぼ", count: 6),
        .init(name: "ぶどう", count: 5),
        .init(name: "バナナ", count: 4),
        .init(name: "オレンジ", count: 2)
    ]
    
    var body: some View {
        VStack {
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
