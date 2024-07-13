//
//  FaceAuth.swift
//  Financial_iPhoneApp
//
//  Created by 有田健一郎 on 2024/07/13.
//

import Foundation
import LocalAuthentication

class FaceAuth {
    
    //認証のAPIを提供するLocalAuthenticationContext
    var context: LAContext = LAContext()
    
    //認証ポップアップに表示するメッセージ
    let reason = "FaceID"
    
    //FaceIDの処理
    func auth(complation:@escaping(Bool) -> Void) {
        
        //認証できるかのチェック
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil){
            
            //認証始め
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ){ success, error in
                
                //成功
                if success{
                    //successが分かってからクロージャを呼び出す
                    DispatchQueue.main.async {
                        complation(true)
                    }
                    
                    //失敗
                }else if let laError = error as? LAError{
                    
                    switch laError.code {
                        //認証失敗
                    case .authenticationFailed:
                        complation(false)
                        break
                        //ユーザーがキャンセルボタンを押した時
                    case .userCancel:
                        complation(false)
                        break
                        //アプリを閉じて失敗
                    case .systemCancel:
                        complation(false)
                        break
                        //パスコードがセットされてない
                    case .passcodeNotSet:
                        complation(false)
                        break
                        //パスコード認証がpolicyで許可されてない場合
                    case .userFallback:
                        complation(false)
                        break
                        //指紋認証の失敗上限
                    case .touchIDNotAvailable:
                        complation(false)
                        break
                        //指紋認証が許可されてない
                    case .touchIDNotEnrolled:
                        complation(false)
                        break
                        //指紋認証が登録されてない
                    case .touchIDLockout:
                        complation(false)
                        break
                        //アプリの内部によるキャンセル
                    case .appCancel:
                        complation(false)
                        break
                        //不明なエラー
                    case .invalidContext:
                        complation(false)
                        break
                        //よくわからん
                    case .notInteractive:
                        complation(false)
                        break
                        
                    @unknown default:
                        break
                    }
                }
            }
        }else {
            //生体認証ができない場合
        }
    }
}

