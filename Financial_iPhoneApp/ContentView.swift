//
//  ContentView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color(0xfaf0e6, alpha:1.0))
        // TabViewの背景色(薄茶色)
    }
    
    var body: some View {
        
        TabView{
            HomeView() //タブ1番目
                .tabItem {
                    Image(systemName: "house")
                    Text("ホーム")
                }
            CalenderView() //タブ2番目
                .tabItem {
                    Image(systemName: "calendar")
                    Text("カレンダー")
                }
            GraphView() //タブ3番目
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("レポート")
                }
            SearchView() //タブ4番目
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("検索")
                }
            SettingView() //タブ5番目
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("設定")
                }
        }
        .accentColor(.blue) //ここでタブのアクセント色の指定
        
    }
}

extension Color { //Colorオブジェクトの拡張(Hex値を使用するため)
    init(_ hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

#Preview {
    ContentView()
}
