//
//  ValidationFunction.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/10/20.
//  Copyright © 2019 Rooney. All rights reserved.
//

import Foundation

class VakudationFunction {

    static var emailReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    static var numberReg = "[0-9]"
    
    // MARK: Email驗證
    static func isValidEmail(Str: String) -> Bool {
        let validstr = NSPredicate(format:"SELF MATCHES %@", emailReg)
        return validstr.evaluate(with: Str)
    }
    
    // MARK: 數字驗證
    static func isValidNumber(Str: String) -> Bool {
        let validstr = NSPredicate(format:"SELF MATCHES %@", numberReg)
        return validstr.evaluate(with: Str)
    }
    // MARK: N位數字驗證
    static func isValidNumber(Str: String, Num: Int) -> Bool {
        let validstr = NSPredicate(format:"SELF MATCHES %@", numberReg + "{\(Num)}")
        return validstr.evaluate(with: Str)
    }
}
