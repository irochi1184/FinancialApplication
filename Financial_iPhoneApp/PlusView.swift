//
//  PlusView.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/04/20.
//

import SwiftUI
import UIKit

struct PlusView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isDatePickerVisible = false
    @State private var selectedDate = Date()
    @State private var amount = ""
    @State private var description = ""
    @State private var category = ""
    @State private var selectedImage: UIImage?
    
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
        formatter.dateFormat = "yyyy年 MM月 dd日"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    // 月の表示部分がタップされたらDatePickerを表示する
                    self.isDatePickerVisible.toggle()
                }) {
                    Text(formatter.string(from: selectedDate))
                        .foregroundStyle(.blue)
                    Image(systemName: "calendar")
                }
                
                TextField("金額", text: $amount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .padding()
                
                TextField("内容", text: $description)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("カテゴリー", text: $category)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack {
                    Spacer()
                    Button(action: {
                        // 「写真を撮る」ボタンのアクション
                        self.openCamera()
                    }) {
                        Image(systemName: "camera")
                        Text("写真で読み込む")
                    }
                    Spacer()
                    Button(action: {
                        // 「追加」ボタンのアクション
                        // ここでデータを保存するなどの処理を行う
                        self.presentationMode.wrappedValue.dismiss() // PlusViewを閉じる
                    }) {
                        Text("追加")
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("追加")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                                    Button("戻る") {
                self.presentationMode.wrappedValue.dismiss() // PlusViewを閉じる
            })
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
    
    func numberOfDays(in month: Int) -> Int {
        let dateComponents = DateComponents(year: selectedYear, month: month)
        if let date = calendar.date(from: dateComponents),
           let range = calendar.range(of: .day, in: .month, for: date) {
            return range.count
        }
        return 31 // デフォルトでは31日を返す
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
    PlusView()
}
