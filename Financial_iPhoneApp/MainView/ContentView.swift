//
//  ContentView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var dataStore = TransactionDataStore()
    @ObservedObject var model: AppModel
    @State private var selectedTab: Tab = .home
    
    init(model: AppModel) {
        self.model = model
        UITabBar.appearance().backgroundColor = UIColor(Color(0xfaf0e6, alpha: 1.0))
        
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
        NavigationStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .environmentObject(dataStore)
                    .tag(Tab.home)
                    .tabItem {
                        Image(systemName: "house")
                        Text("ホーム")
                    }
                
                CalendarView()
                    .tag(Tab.calendar)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("カレンダー")
                    }
                
                GraphView()
                    .tag(Tab.report)
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("レポート")
                    }
                
                SearchView()
                    .tag(Tab.search)
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("検索")
                    }
                
                SettingView()
                    .environmentObject(model)
                    .tag(Tab.settings)
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("設定")
                    }
            }
        }
    }
}

extension Color {
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
    ContentView(model: AppModel())
        .modelContainer(for: [CategoryData.self, TransactionData.self], inMemory: true)
}
