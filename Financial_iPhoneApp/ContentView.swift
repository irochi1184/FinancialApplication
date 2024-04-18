//
//  ContentView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/26.
//

import SwiftUI
import SwiftData

struct ContentView: View { //アプリ起動時の共有画面
    
    @State private var selectedTab: Tab = .home // 初期値をホームに設定
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color(0xfaf0e6, alpha:1.0))
        // TabViewの背景色(薄茶色)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(0xfaf0e6, alpha:1.0))
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black, .font : UIFont.systemFont(ofSize: 30)]
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
                HomeView() //タブ1番目
                    .tabItem { //見た目
                        Image(systemName: "house")
                        Text("ホーム")
                    }
                    .tag(Tab.home) // タグを設定
                
                CalendarView() //タブ2番目
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("カレンダー")
                    }
                    .tag(Tab.calendar) // タグを設定
                
                GraphView() //タブ3番目
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("レポート")
                    }
                    .tag(Tab.report) // タグを設定
                
                SearchView() //タブ4番目
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("検索")
                    }
                    .tag(Tab.search) // タグを設定
                
                SettingView() //タブ5番目
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("設定")
                    }
                    .tag(Tab.settings) // タグを設定
            }
            .accentColor(.green) //ここでタブのアクセント色の指定
            
            //タイトル
            .navigationTitle(title(for: selectedTab))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // タブに応じたタイトルを返す関数
    private func title(for tab: Tab) -> String {
        switch tab {
        case .home:
            return "ホーム"
        case .calendar:
            return "カレンダー"
        case .report:
            return "レポート"
        case .search:
            return "検索"
        case .settings:
            return "設定"
        }
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
