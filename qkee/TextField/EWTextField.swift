//
//  EWTextField.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/10/5.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit

protocol EWTextFieldDelegate: AnyObject {
    func EWTextDidBeginEditing()
    func EWTextDidEndEditing()
}

class EWTextField: UIView, UITextFieldDelegate {

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.setBottomBorder(color: UIColor.lightGray.cgColor, size: CGSize(width: 0.0, height: 1.0))
        }
    }
    
    weak var delegate: EWTextFieldDelegate?
    
    init(frame: CGRect, text: String, keytype: UIKeyboardType) {
        super.init(frame: frame)
        customInit()
        
        titleLabel.text = text
        textField.keyboardType = keytype
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    private func customInit() {
        Bundle.main.loadNibNamed("EWTextField", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func titleLabelMoveUp(textColor: UIColor) {
        UIView.animate(withDuration: 0.25) {
            self.titleLabel.font = UIFont.systemFont(ofSize: 12)
            self.titleLabel.transform = CGAffineTransform.init(translationX: 0, y: -35)
            self.titleLabel.textColor = textColor
        }
    }
    
    private func titleLabelMoveDown(textColor: UIColor) {
        UIView.animate(withDuration: 0.25) {
            self.titleLabel.font = UIFont.systemFont(ofSize: 20)
            self.titleLabel.transform = CGAffineTransform.identity
            self.titleLabel.textColor = textColor
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //print("Function: \(#function), line: \(#line)")
        //titleLabelMoveUp(textColor: <#UIColor#>, lineColor: <#UIColor#>, size: <#CGSize#>)
        
        if let delegate = delegate {
            delegate.EWTextDidBeginEditing()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //print("Function: \(#function), line:\(#line)")
        if textField.hasText {
        }
        else {
            //titleLabelMoveDown()
        }
        
        if let delegate = delegate {
            delegate.EWTextDidEndEditing()
            
        }
    }
}
