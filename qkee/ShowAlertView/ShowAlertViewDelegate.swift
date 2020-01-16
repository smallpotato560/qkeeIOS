//
//  AlertViewDelegate.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/9/24.
//  Copyright © 2019 Rooney. All rights reserved.
//

protocol ShowAlertViewDelegate: AnyObject {
    //func okButtonTapped(selectedOption: String, textFieldValue: String)
    
    func ButtonTapped()
    
    func LeftButtonTapped()
    
    func RightButtonTapped()
}
