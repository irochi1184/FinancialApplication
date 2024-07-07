//
//  ContentView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/26.
//

import SwiftUI
import SwiftData

struct ContentView: View { //アプリ起動時の共有画面
    @StateObject private var dataStore = TransactionDataStore() // データストアを作成
    @State private var selectedTab: Tab = .home // 初期値をホームに設定
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color(0xfaf0e6, alpha: 1.0))
        // TabViewの背景色(薄茶色)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(0xfaf0e6, alpha: 1.0))
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 30)]
        appearance.titlePositionAdjustment.vertical = 5
        appearance.accessibilityFrame = CGRect(x: 20, y: 20, width: 20, height: 100)
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    enum Tab {
        case home, calendar, report, search, settings
    }
    
    var body: some View {
        // プラスボタン実装
        NavigationStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .environmentObject(dataStore) // 環境オブジェクトとして提供
                    .tag(Tab.home) // タグを設定
                    .tabItem {
                        Image(systemName: "house")
                        Text("ホーム")
                    }
                
                CalendarView() // タブ2番目
                    .tag(Tab.calendar) // タグを設定
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("カレンダー")
                    }
                
                GraphView() // タブ3番目
                    .tag(Tab.report) // タグを設定
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("レポート")
                    }
                
                SearchView() // タブ4番目
                    .tag(Tab.search) // タグを設定
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("検索")
                    }
                
                SettingView() // タブ5番目
                    .tag(Tab.settings) // タグを設定
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("設定")
                    }
            }
            //.accentColor(.green) //ここでタブのアクセント色の指定
        }
    }
}

extension Color { // Colorオブジェクトの拡張(Hex値を使用するため)
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
        .modelContainer(for: TransactionData.self) // データ保存用
}
