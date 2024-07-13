//
//  passCheck.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/13.
//

import Foundation

class passCheck: ObservableObject {
    @Published var firstCheck:[String?] = [nil, nil, nil, nil]
    @Published var secondCheck:[String?] = [nil, nil, nil, nil]
    @Published var passText:String = "パスワードを忘れると復元できません\n忘れないようご注意ください"
}

