//
//  HomeView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/02/29.
//

import SwiftUI
import Charts

struct Tab: Identifiable {
    var id: UUID = .init()
    let title: String
    let color: Color
}

private let tabs: [Tab] = [
    .init(title: "ホーム1", color: .cyan),
    .init(title: "ホーム2", color: .green)
]

struct FavoriteFruit {
    let name: String
    let count: Int
    var color: Color
}

struct HomeView: View {
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    @State private var selectedDate: Date = Date()
    @State private var selectedDateString: String = ""
    @State private var selectedDay: Date?
    
    @State private var favoriteFruits: [FavoriteFruit] = [
        .init(name: "月の限度額", count: 3, color: .blue),
        .init(name: "使用金額", count: 1, color: .gray)
    ]
    
    init() {
        formatter.dateFormat = "yyyy年 MM月"
    }
    
    @State private var isDatePickerVisible = false
    
    // 選択された年と月
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    
    // 表示する年の範囲
    private let minYear: Int = 2000
    private let maxYear: Int = 2024
    
    struct FloatingButton: View {
        var body: some View {
            VStack {  // --- 1
                Spacer()
                HStack { // --- 2
                    Spacer()
                    Button(action: {
                        // ここにボタンを押した時の処理
                        print("Tapped!!") // --- 3
                    }, label: {
                        //                    Image(systemName: "pencil")
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 24)) // --- 4
                    })
                    .frame(width: 60, height: 60)
                    .background(Color.blue)
                    .cornerRadius(30.0)
                    .shadow(color: .gray, radius: 3, x: 3, y: 3)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 16.0, trailing: 16.0)) // --- 5
                    
                }
            }
        }
    }
    
    @State private var selectedTabId: UUID? = tabs[0].id
    @Namespace private var tabNamespace
    
    var body: some View {
        VStack{
            
            HStack {
                Button(action: {
                    self.selectedDate = self.calendar.date(byAdding: .month, value: -1, to: self.selectedDate)!
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                // 選択された月の表示
                Button(action: {
                    // 月の表示部分がタップされたらDatePickerを表示する
                    self.isDatePickerVisible.toggle()
                }) {
                    Text(formatter.string(from: selectedDate))
                        .font(.title)
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    self.selectedDate = self.calendar.date(byAdding: .month, value: 1, to: self.selectedDate)!
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 0) {
                // Tab
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tabs) { tab in
                                Button {
                                    selectedTabId = tab.id
                                } label: {
                                    Text(tab.title)
                                        .bold()
                                }
                                .id(tab.id)
                                .padding()
                            }
                        }
                    }
                }
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        ForEach(tabs) { tab in
                            //ScrollView {
                            if tab.title == "ホーム1" {
                                ZStack {
                                    VStack {
                                        VStack {
                                            Divider()
                                            // スペースを追加
                                            Spacer().frame(height: 20)
                                            
                                            ZStack {
                                                Chart(favoriteFruits, id: \.name) { favoriteFruit in
                                                    SectorMark(
                                                        angle: .value("count", favoriteFruit.count),innerRadius: .inset(30)
                                                    )
                                                    .foregroundStyle(favoriteFruit.color)
                                                }.frame(height: 300)
                                                
                                                // 円グラフの中心に表示するテキスト
                                                Text("● ").foregroundColor(.gray).font(.caption) +
                                                Text("月の限度額：100,000円").font(.subheadline).foregroundColor(.black) +
                                                Text("\n● ").foregroundColor(.blue).font(.caption) +
                                                Text("　使用金額：75,000円").font(.subheadline).foregroundColor(.black)
                                                //.offset(y: -20) // テキストを上に20ポイント移動
                                            }
                                            .frame(width: 300, height: 300)
                                            
                                            Spacer().frame(height: 30)
                                            
                                            Text("使用内容").font(.headline).frame(maxWidth: 350, alignment: .leading)/*.offset(y: -20)*/
                                            Divider()
                                            
                                            ZStack {
                                                
                                                // リスト表示
                                                List {
                                                    HStack {
                                                        Text("\(formatter.string(from: selectedDate))")
                                                        Spacer()
                                                        Text("セブンイレブン")
                                                        Spacer()
                                                        Text("¥1,000-")
                                                    }
                                                    HStack {
                                                        Text("04月21日")
                                                        Spacer()
                                                        Text("セブンイレブンいい気分")
                                                        Spacer()
                                                        Text("¥100,000-")
                                                    }
                                                    HStack {
                                                        Text("04月21日")
                                                        Spacer()
                                                        Text("セブンイレブン")
                                                        Spacer()
                                                        Text("¥1,000-")
                                                    }
                                                    HStack {
                                                        Text("04月21日")
                                                        Spacer()
                                                        Text("セブンイレブン")
                                                        Spacer()
                                                        Text("¥1,000-")
                                                    }
                                                    HStack {
                                                        Text("04月21日")
                                                        Spacer()
                                                        Text("セブンイレブン")
                                                        Spacer()
                                                        Text("¥1,000-")
                                                    }
                                                    HStack {
                                                        Text("04月21日")
                                                        Spacer()
                                                        Text("セブンイレブン")
                                                        Spacer()
                                                        Text("¥1,000-")
                                                    }
                                                }
                                                .listStyle(.plain)
                                                FloatingButton()
                                                
                                                
                                            }/*.offset(y: -20)*/
                                            .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                                            
                                        }
                                        .padding(.bottom, 20) // 下部に余白を追加
                                        .sheet(isPresented: $isDatePickerVisible) {
                                            // 年月のピッカーを表示するためのシート
                                            VStack {
                                                // DatePickerを閉じるボタン
                                                Button(action: {
                                                    self.isDatePickerVisible = false
                                                    // 選択された年月からDateを生成
                                                    self.selectedDate = self.calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth)) ?? Date()
                                                }) {
                                                    Text("閉じる")
                                                        .foregroundColor(.blue)
                                                        .padding()
                                                }
                                                
                                                HStack {
                                                    // 年のピッカー
                                                    Picker(selection: $selectedYear, label: Text("")) {
                                                        ForEach(minYear...maxYear, id: \.self) { year in
                                                            Text("\(String(year))年").tag(year) // Stringに変換しないとカンマが入ってしまう
                                                        }
                                                    }
                                                    .pickerStyle(WheelPickerStyle())
                                                    .labelsHidden()
                                                    .frame(maxWidth: .infinity)
                                                    
                                                    // 月のピッカー
                                                    Picker("Month", selection: $selectedMonth) {
                                                        ForEach(1...12, id: \.self) { month in
                                                            Text("\(month)月")
                                                        }
                                                    }
                                                    .pickerStyle(WheelPickerStyle())
                                                    .frame(maxWidth: .infinity)
                                                    
                                                }.toolbar {
                                                    
                                                }
                                            }.presentationDetents([.height(280)]) // シートの高さ
                                        }
                                    }
                                }
                                //横幅めいいっぱい?
                                .containerRelativeFrame(.horizontal)
                                //}
                            }else{
                                Home2()
                            }
                            
                        }
                    }
                    //スワイプ途中で止めない
                    .scrollTargetLayout()
                }
                //スワイプ途中で止めない
                .scrollTargetBehavior(.viewAligned)
                //
                .scrollPosition(id: $selectedTabId)
            }
            //ボタンを押した時のアニメーション
            .animation(.easeInOut, value: selectedTabId)
        }
    }
}

struct Home2: View{
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    @State private var selectedDate: Date = Date()
    @State private var selectedDateString: String = ""
    @State private var selectedDay: Date?
    
    init() {
        formatter.dateFormat = "yyyy年 MM月"
    }
    
    @State private var isDatePickerVisible = false
    
    // 選択された年と月
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    
    // 表示する年の範囲
    private let minYear: Int = 2000
    private let maxYear: Int = 2024
    
    struct FloatingButton: View {
        var body: some View {
            VStack {  // --- 1
                Spacer()
                HStack { // --- 2
                    Spacer()
                    Button(action: {
                        // ここにボタンを押した時の処理
                        print("Tapped!!") // --- 3
                    }, label: {
                        //                    Image(systemName: "pencil")
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 24)) // --- 4
                    })
                    .frame(width: 60, height: 60)
                    .background(Color.blue)
                    .cornerRadius(30.0)
                    .shadow(color: .gray, radius: 3, x: 3, y: 3)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 16.0, trailing: 16.0)) // --- 5
                    
                }
            }
        }
    }
    
    @State private var selectedTabId: UUID? = tabs[0].id
    @Namespace private var tabNamespace
    
    @State private var favoriteFruits: [FavoriteFruit] = [
        .init(name: "食費", count: 1, color: .blue),
        .init(name: "固定費", count: 1, color: .gray),
        .init(name: "娯楽", count: 1, color: .red),
        .init(name: "日用雑貨", count: 1, color: .orange)
    ]
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    Divider()
                    // スペースを追加
                    Spacer().frame(height: 20)
                    
                    ZStack {
                        Chart(favoriteFruits, id: \.name) { favoriteFruit in
                            SectorMark(
                                angle: .value("count", favoriteFruit.count),innerRadius: .inset(30)
                            )
                            .foregroundStyle(favoriteFruit.color)
                        }.frame(height: 300)
                        
                        VStack {
                            
                            // 円グラフの中心に表示するテキスト
                            Text("●").foregroundColor(.blue).font(.caption) +
                            Text("食費：60000円").font(.subheadline).foregroundColor(.black)
                            Text("●").foregroundColor(.gray).font(.caption) +
                            Text("固定費：60000円").font(.subheadline).foregroundColor(.black)
                            Text("●").foregroundColor(.red).font(.caption) +
                            Text("娯楽：60000円").font(.subheadline).foregroundColor(.black)
                            Text("●").foregroundColor(.orange).font(.caption) +
                            Text("日用雑貨：60000円").font(.subheadline).foregroundColor(.black)
                            
                        }
//                        .offset(y: -50) // テキストを上に20ポイント移動
                    }
                    .frame(width: 300, height: 300)
                    
                    Spacer().frame(height: 30)
                    
                    Text("カテゴリ内容").font(.headline).frame(maxWidth: 350, alignment: .leading)/*.offset(y: -20)*/
                    Divider()
                    
                    ZStack {
                        
                        // リスト表示
                        List {
                            HStack {
                                Text("食費")
                                Spacer()
                                Text("¥60000")
                            }
                            HStack {
                                Text("固定費")
                                Spacer()
                                Text("¥60000")
                            }
                            HStack {
                                Text("娯楽")
                                Spacer()
                                Text("¥60000")
                            }
                            HStack {
                                Text("日用雑貨")
                                Spacer()
                                Text("¥60000")
                            }
                        }
                        .listStyle(.plain)
                        FloatingButton()
                        
                        
                    }/*.offset(y: -20)*/
                    .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    
                }
                .padding(.bottom, 20) // 下部に余白を追加
                .sheet(isPresented: $isDatePickerVisible) {
                    // 年月のピッカーを表示するためのシート
                    VStack {
                        // DatePickerを閉じるボタン
                        Button(action: {
                            self.isDatePickerVisible = false
                            // 選択された年月からDateを生成
                            self.selectedDate = self.calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth)) ?? Date()
                        }) {
                            Text("閉じる")
                                .foregroundColor(.blue)
                                .padding()
                        }
                        
                        HStack {
                            // 年のピッカー
                            Picker(selection: $selectedYear, label: Text("")) {
                                ForEach(minYear...maxYear, id: \.self) { year in
                                    Text("\(String(year))年").tag(year) // Stringに変換しないとカンマが入ってしまう
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            
                            // 月のピッカー
                            Picker("Month", selection: $selectedMonth) {
                                ForEach(1...12, id: \.self) { month in
                                    Text("\(month)月")
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(maxWidth: .infinity)
                            
                        }.toolbar {
                            
                        }
                    }.presentationDetents([.height(280)]) // シートの高さ
                }
            }
        }
        //横幅めいいっぱい?
        .containerRelativeFrame(.horizontal)
        //}
    }
}

#Preview {
    HomeView()
}
