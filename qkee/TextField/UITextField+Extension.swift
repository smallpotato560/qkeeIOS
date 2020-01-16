//
//  UITextField+Extension.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/10/5.
//  Copyright © 2019 Rooney. All rights reserved.
//

import Foundation
import UIKit
var maxTextNumberDefault = 15

extension UITextField {
    /// 使用runtime給textField添加最大輸入數屬性,默認15
    var maxTextNumber: Int {
        set {
            objc_setAssociatedObject(self, &maxTextNumberDefault, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            if let max = objc_getAssociatedObject(self, &maxTextNumberDefault) as? Int {
                return max
            }
            return 15
        }
    }
    /// 添加判斷數量方法
    func addChangeTextTarget() {
        self.addTarget(self, action: #selector(changeText), for: .editingChanged)
    }
    @objc func changeText() {
        //判斷是不是在拼音狀態,拼音狀態不截取文本
        if let positionRange = self.markedTextRange {
            guard self.position(from: positionRange.start, offset: 0) != nil else {
                checkTextFieldText()
                return
            }
        } else {
            checkTextFieldText()
        }
    }
    /// 判斷已輸入字數是否超過設置的最大數.如果是則截取
    func checkTextFieldText() {
        guard (self.text?.length)! <= maxTextNumber  else {
            self.text = (self.text?.stringCut(end: maxTextNumber))!
            return
        }
    }
}

extension String {

    var length: Int {
        ///更改成其他的影響含有emoji協議的簽名
        return self.utf16.count
    }

    /// 截取第一個到第任意位置
    ///
    /// - Parameter end: 結束的位值
    /// - Returns: 截取後的字符串
    func stringCut(end: Int) -> String {
        if !(end <= count) { return self }
        let sInde = index(startIndex, offsetBy: end)
        return String(self[..<sInde])
    }
}
