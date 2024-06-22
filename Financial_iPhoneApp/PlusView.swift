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
    @Query private var datas: [TransactionData]
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isDatePickerVisible = false
    
    @State private var isExpense = true           // 項目（true = 支出、false = 収入）
    @State private var transactionName = String() // 取引名
    @State private var selectedDate = Date()      // 日付
    @State private var amount = String()          // 金額
    @State private var category = String()        // カテゴリー
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
            VStack {
                // スペースを追加して、ナビゲーションバーとテキストフィールドの間に余白を作成
                Spacer().frame(height: 20)
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
                Spacer()
                
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
                
                // --------------- 項目選択 --------------- //
//                Text("項目")
//                    .bold()
//                    .foregroundColor(.gray)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.leading, 15)
//                Section {
//                    Picker(selection: $isExpense, label: Text("項目")) {
//                        Text("支出").tag(true)
//                        Text("收入").tag(false)
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                }
//                .padding([.leading, .bottom, .trailing], 15) // 左、下、右に余白
//                .padding(.bottom, 10)
                
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
                    .onChange(of: amount) { oldValue, newValue in
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
                .padding(.bottom, 30)
                
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
                        add(ex: isExpense, tn: transactionName, sd: selectedDate, am: amount, ca: category)
                        isExpense = false
                        transactionName = String()
                        selectedDate = Date()
                        amount = String()
                        category = String()
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
                
                Spacer()
                
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isDatePickerVisible) {
            // 年月のピッカーを表示するためのシート
            VStack {
                // DatePickerを閉じるボタン
                Button(action: {
                    self.isDatePickerVisible = false
                    // 選択された年月からDateを生成
                    self.selectedDate = self.calendar.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: selectedDay)) ?? Date()
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
                    .frame(maxWidth: .infinity)
                    
                    // 月のピッカー
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text("\(month)月")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)
                    
                    // 日のピッカー
                    Picker("Day", selection: $selectedDay) {
                        ForEach(1...numberOfDays(in: selectedMonth), id: \.self) { day in
                            Text("\(day)日")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)
                }
            }.presentationDetents([.height(280)]) // シートの高さ
        }
    }
    
    struct CategorySelectionView: View {
        @Binding var selectedCategory: String
        @Environment(\.dismiss) var dismiss
        let categories = ["食費", "雑費", "家賃", "娯楽費", "電気代", "水道代", "交通費", "書籍代"] // Example categories
        
        var body: some View {
            List {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        dismiss() // カテゴリーをチェックしたら自動的に前のViewに戻る
                    }) {
                        HStack {
                            Text(category)
                            if selectedCategory == category {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                Spacer()
                Text("新規追加")
            }
        }
    }
    
    func numberOfDays(in month: Int) -> Int {
        let dateComponents = DateComponents(year: selectedYear, month: month)
        if let date = calendar.date(from: dateComponents),
           let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        }
        return 31 // デフォルトでは31日を返す
    }
    
    // カメラ起動
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
    
    // データの追加
    private func add(ex: Bool, tn: String, sd: Date, am: String, ca: String) {
        print(ex, tn, sd, am, ca) // true とりひき 2024-05-12 15:00:00 +0000 300 カテゴリ1
        let data = TransactionData(isExpense: ex, transactionName: tn, selectedDate: sd, amount: am, category: ca)

        context.insert(data)
        print("insert成功した！！！！")
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
