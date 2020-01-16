//
//  UIViewEffect.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/9/15.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit

class UIViewEffect : UIView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("按下")
        if let touch = touches.first {
            touch.view!.backgroundColor = .red
        }
        
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("event canceled!")
        if let touch = touches.first {
            touch.view?.backgroundColor = ColorFuntion.hexStringToUIColor(hex: "2F3136")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            _ = touch.location(in: self)
            // do something with your currentPoint
        }
        
        self.backgroundColor = .red//Color when UIView is clic
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            
            self.backgroundColor = .white//Color when UIView is not clicked.
        }
    }
}
