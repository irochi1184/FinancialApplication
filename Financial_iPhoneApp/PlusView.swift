//
//  PlusView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/04/20.
//

import SwiftUI
import SwiftData
import UIKit

struct PlusView: View {
    
    // CRUD処理下準備
    @Environment(\.modelContext) private var context
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: TransactionDataStore // データの変更を監視
    @Query private var datas: [TransactionData]
    
    
    @State private var isDatePickerVisible = false
    
    @State private var isExpense = true           // 項目（true = 支出、false = 収入）
    @State private var transactionName = String() // 取引名
    @State private var selectedDate = Date()      // 日付
    @State private var amount = String()          // 金額
    @State private var category = String()        // カテゴリー
    @State private var memo = String()            // メモ
    @State var menuExpanded: Bool = false         // 詳細を隠す
    @State private var selectedImage: UIImage?
    
    // エラーメッセージ表示用
    @State private var errorMessage: String?
    
    // 選択された年と月
    @State private var selectedDay: Int = Calendar.current.component(.day, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    
    // 表示する年の範囲
    private let minYear: Int = 2000
    private let maxYear: Int = 2024
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    init() {
        // 背景色
        UISegmentedControl.appearance().backgroundColor = UIColor(Color.gray.opacity(0.1))
        // 選択項目の背景色
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.green)
        // 選択項目の文字色
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        
        formatter.dateFormat = "yyyy年 MM月 dd日"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack (spacing : 0){
                    HStack {
                        Button("戻る") {
                            self.presentationMode.wrappedValue.dismiss() // PlusViewを閉じる
                        }.padding(.leading, 20)
                        Spacer()
                        Text("追加")
                            .padding(.trailing, 50)
                            .font(.title3)
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    .background(Color.white)
                    .zIndex(1)
                    
                    Divider()
                    
                    ScrollView {
                        VStack {
                            // --------------- 写真で読み込む --------------- //
                            Button(action: {
                                // 「写真を撮る」ボタンのアクション
                                self.openCamera()
                            }) {
                                HStack {
                                    Image(systemName: "camera")
                                    Text("写真で読み込む")
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.green)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8) // 枠線の角丸
                                    .stroke(.green, lineWidth: 0.5)) // 枠線の色と太さ
                            }
                            .padding()
                            .padding(.bottom, 10)
                            .padding(.top, 20)
                            
                            // --------------- 取引名 --------------- //
                            Text("取引名")
                                .bold()
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 15)
                            TextField("入力", text: $transactionName)
                                .textFieldStyle(RoundedBorderTextFieldStyle()) // 枠線
                                .padding([.leading, .bottom, .trailing], 15) // 左、下、右に余白
                                .padding(.bottom, 10)
                            
                            // --------------- 日付 --------------- //
                            Text("日付")
                                .bold()
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 15)
                            HStack {
                                Button(action: {
                                    // 日付の表示部分がタップされたらDatePickerを表示する
                                    self.isDatePickerVisible.toggle()
                                }) {
                                    Text(formatter.string(from: selectedDate))
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    Image(systemName: "calendar")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(7)
                            }
                            .overlay(RoundedRectangle(cornerRadius: 4) // 枠線の角丸
                                .stroke(.gray, lineWidth: 0.18)) // 枠線の色と太さ
                            .padding([.leading, .bottom, .trailing], 15) // 左、下、右に余白
                            .padding(.bottom, 10)
                            
                            // --------------- 金額 --------------- //
                            Text("金額 (円)")
                                .bold()
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 15)
                            TextField("金額 (円)", text: $amount)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle()) // 枠線
                                .padding([.leading, .bottom, .trailing], 15) // 左、下、右に余白
                                .padding(.bottom, 10)
                                .onChange(of: amount) { newValue, old in
                                    var filteredValue = newValue.filter { "0123456789".contains($0) }
                                    if filteredValue.starts(with: "0") {
                                        filteredValue = String(filteredValue.dropFirst())
                                    }
                                    amount = filteredValue
                                }
                            
                            // --------------- カテゴリー選択 --------------- //
                            Text("カテゴリー選択")
                                .bold()
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 15)
                            HStack {
                                NavigationLink(destination: CategorySelectionView(selectedCategory: $category)) {
                                    Text(category.isEmpty ? "選択" : category)
                                        .foregroundColor(.gray.opacity(0.6))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding(7)
                            }
                            .overlay(RoundedRectangle(cornerRadius: 4) // 枠線の角丸
                                .stroke(.gray, lineWidth: 0.18)) // 枠線の色と太さ
                            .padding([.leading, .bottom, .trailing], 15) // 左、下、右に余白
                            .padding(.bottom, 15) // 下に余白
                            
                            // --------------- 詳細（メモ） --------------- //
                            HStack {
                                Text("詳細")
                                    .bold()
                                    .foregroundColor(.gray)
                                    .padding(.leading, 15)
                                Image(systemName: menuExpanded ? "chevron.down" : "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    menuExpanded.toggle()
                                }
                            }
                            
                            if menuExpanded {
                                VStack {
                                    TextField("メモ", text: $memo, axis: .vertical)
                                        .textFieldStyle(.roundedBorder)
                                        .padding([.top], 15)
                                }
                                .padding([.leading, .bottom, .trailing], 15) // 左、下、右に余白
                            }
                            
                            // エラーメッセージ表示
                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                            
                            Button(action: {
                                // エラーメッセージをクリア
                                errorMessage = nil
                                
                                // 入力チェック
                                var errorMessages = [String]()
                                
                                if transactionName.isEmpty {
                                    errorMessages.append("取引名が未入力です。")
                                }
                                if amount.isEmpty {
                                    errorMessages.append("金額が未入力です。")
                                }
                                if category.isEmpty {
                                    errorMessages.append("カテゴリーが未選択です。")
                                }
                                
                                if !errorMessages.isEmpty {
                                    // エラーメッセージを結合して表示
                                    errorMessage = errorMessages.joined(separator: "\n")
                                } else {
                                    // エラーメッセージをクリア
                                    errorMessage = nil
                                    // データを保存するなどの処理を行う
                                    add(ex: isExpense, tn: transactionName, sd: selectedDate, am: amount, ca: category, me: memo)
                                    isExpense = false
                                    transactionName = String()
                                    selectedDate = Date()
                                    amount = String()
                                    category = String()
                                    memo = String()
                                    menuExpanded = false
                                    self.presentationMode.wrappedValue.dismiss() // PlusViewを閉じる
                                }
                            }) {
                                Text("追加")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.green)
                                    .cornerRadius(8)
                            }
                            .padding(10)
                            .padding(.top, 30)
                            
                            Spacer()
                            
                        }
                    }
                }
                .navigationBarHidden(true)
            }
            .sheet(isPresented: $isDatePickerVisible) {
                DayPickerView(
                    isDatePickerVisible: $isDatePickerVisible,
                    selectedYear: $selectedYear,
                    selectedMonth: $selectedMonth,
                    selectedDay: $selectedDay,
                    minYear: minYear,
                    maxYear: maxYear,
                    onDateSelected: {
                        self.selectedDate = self.calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: selectedDay)) ?? Date()
                    }
                )
            }
        }
    }
    
    func openCamera() {
        let picker = UIImagePickerController()
        let coordinator = Coordinator(parent: self) // Coordinatorクラスのインスタンスを生成
        picker.delegate = coordinator // CoordinatorをUIImagePickerControllerのdelegateに設定
        picker.sourceType = .camera
        picker.allowsEditing = false
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(picker, animated: true, completion: nil)
            }
        }
    }
    
    private func add(ex: Bool, tn: String, sd: Date, am: String, ca: String, me: String) {
        let data = TransactionData(isExpense: ex, transactionName: tn, selectedDate: sd, amount: am, category: ca, memo: me)
        context.insert(data)
        dataStore.datas.append(data) // データストアを更新
    }
}

extension PlusView {
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: PlusView
        
        init(parent: PlusView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let pickedImage = info[.originalImage] as? UIImage {
                // ここで取得した画像を使って何か処理を行います
                parent.selectedImage = pickedImage // 選択された画像をセットします
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TransactionData.self) // データ保存用
}
