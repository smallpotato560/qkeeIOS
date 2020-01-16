//
//  EWTextView.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/10/13.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit

protocol EWTextViewDelegate: AnyObject {
    func EWTextDidBeginEditing()
    func EWTextDidEndEditing(_ textField: UITextField)
    func EWTextShouldReturn(_ textField: UITextField)
    func EWTextDidChangeSelection(_ textField: UITextField)
}

class EWTextView: UIView, UITextFieldDelegate {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.setBottomBorder(color: UIColor.lightGray.cgColor, size: CGSize(width: 0.0, height: 1.0))
        }
    }
    
    @IBOutlet var errorView: UIView!
    @IBOutlet var errorLabel: UILabel!
    
    weak var delegate: EWTextViewDelegate?
    
    init(frame: CGRect, text: String, labletext: String, Tag: Int, keytype: UIKeyboardType, returnkeytype: UIReturnKeyType) {
        super.init(frame: frame)
        customInit()

        titleLabel.text = text
        textField.tag = Tag
        textField.keyboardType = keytype
        textField.returnKeyType = returnkeytype
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        var image = UIImage(named: "ic_error_white_24dp")
        image = resizeImage(image: image!,newWidth:25)
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .red
        textField.rightView = imageView
        
        errorLabel.text = labletext
        
        //print("labelwidth:\(textSize.width)")
        errorView.addBorder(edge: .top, color: .red, thickness: 2.0, label: errorLabel, isClearn: false)
        errorView.tag = Tag
        errorView.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    private func customInit() {
        Bundle.main.loadNibNamed("EWTextView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.bringSubviewToFront(titleLabel)
    }
    
    static func SetBorder(_ label: UILabel, _ view: UIView) {
        //print("labelwidth:\(textSize.width)")
        view.addBorder(edge: .top, color: .red, thickness: 2.0, label: label, isClearn: false)
    }
    
    static func ShowErrorHint(_ textField: UITextField, _ view: UIView) {
        textField.rightViewMode = .always
        view.isHidden = false
    }
    
    static func HideErrorHint(_ textField: UITextField, _ view: UIView) {
        textField.rightViewMode = .never
        view.isHidden = true
    }
    private func titleLabelMoveUp() {
        UIView.animate(withDuration: 0.25) {
            self.titleLabel.font = UIFont.systemFont(ofSize: 12)
            self.titleLabel.transform = CGAffineTransform.init(translationX: 0, y: -35)
            self.titleLabel.textColor = .black
        }
    }
    
    private func titleLabelMoveDown() {
        UIView.animate(withDuration: 0.25) {
            self.titleLabel.font = UIFont.systemFont(ofSize: 20)
            self.titleLabel.transform = CGAffineTransform.identity
            self.titleLabel.textColor = .lightGray
        }
    }
    
    // MARK: 取得文字的寬度
    public func getSizeFromString(string:String, withFont font:UIFont)->CGSize{
        let textSize = NSString(string: string ).size(
            withAttributes: [ NSAttributedString.Key.font:font ])

            return textSize
    }
    
    // MARK: 進入編輯狀態
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //print("Function: \(#function), line: \(#line)")
        titleLabelMoveUp()
        textField.setBottomBorder(color: UIColor.black.cgColor, size: CGSize(width: 0.0, height: 2.0))
        
        if let delegate = delegate {
            delegate.EWTextDidBeginEditing()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let delegate = delegate {
            delegate.EWTextShouldReturn(textField)
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.setClearButton(textfield: textField, color: .black)
        
        if let delegate = delegate {
            delegate.EWTextDidChangeSelection(textField)
        }
    }
    
    // MARK: 結束編輯狀態
    func textFieldDidEndEditing(_ textField: UITextField) {
        //print("Function: \(#function), line:\(#line)")
        textField.setBottomBorder(color: UIColor.lightGray.cgColor, size: CGSize(width: 0.0, height: 1.0))
        if textField.hasText {
            titleLabel.textColor = .lightGray
            //underlineView.backgroundColor = .black
        }
        else {
            titleLabelMoveDown()
        }
        
        if let delegate = delegate {
            delegate.EWTextDidEndEditing(textField)
            
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
          
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
          
        return newImage!
    }
}

//MARK: 擴展UIText
extension UITextField {
    
    // MARK: 設定邊框為底線
    func setBottomBorder(color: CGColor, size: CGSize) {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = color
        self.layer.shadowOffset = size
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
    // MARK: 設定清除按鈕顏色
    func setClearButton(textfield: UITextField, color: UIColor) {
        let clearButton = textfield.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = color
    }
}

var oldlabelWidth: CGFloat!
extension UIView {
    func addBorder(edge:UIRectEdge, color:UIColor, thickness:CGFloat, label: UILabel, isClearn: Bool){
        //print("width:\(bounds.size.width)")
        
        let textSize = NSString(string: label.text! ).size(
            withAttributes: [ NSAttributedString.Key.font:label.font! ])
        
        let labelWidth = textSize.width + 10.2
        
        
        //* 路径
        var borderPath: UIBezierPath?
        
        let borders = CAShapeLayer()
        layer.mask = borders
        borderPath = UIBezierPath()

        
        if !isClearn {
            //print("Clearn")
            if oldlabelWidth == nil {
                //print("oldlabelWidth=0")
                oldlabelWidth = labelWidth
            }
            
            switch edge {
            case .top:
                
                borders.frame = bounds
                
                // 設置path起點
                borderPath?.move(to: CGPoint(x: 0, y: -5))

                // 到右上角
                borderPath?.addLine(to: CGPoint(x: oldlabelWidth, y: -5))
                
                // 到右下角
                borderPath?.addLine(to: CGPoint(x: oldlabelWidth, y: 0))
                
                // 到左下角
                borderPath?.addLine(to: CGPoint(x: 0, y: 0))
                
                // 回到起點
                borderPath?.addLine(to: CGPoint(x: 0, y: -5))
                borders.frame = CGRect(x: 0, y: 0, width: oldlabelWidth, height: thickness);
                
                borders.path = borderPath?.cgPath
                
                borders.fillColor = UIColor.white.cgColor
                borders.backgroundColor = UIColor.white.cgColor;
                
                break
            case .bottom:
                borders.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness);
            case .left:
                borders.frame = CGRect(x: 0, y: 0 + thickness, width: thickness, height: frame.height - thickness * 2);
            case .right:
                borders.frame = CGRect(x: frame.width - thickness, y: 0 + thickness, width: thickness, height: frame.height - thickness * 2);
            default:
                break
            }
            
            self.layer.addSublayer(borders);
            
            addBorder(edge: edge, color: color, thickness: thickness, label: label, isClearn: true)
        }
        else {
            //print("NoClearn")
            oldlabelWidth = labelWidth
            
            switch edge {
            case .top:
                
                borders.frame = bounds
                
                // 設置path起點
                borderPath?.move(to: CGPoint(x: 0, y: 0))

                // 箭頭
                borderPath?.addLine(to: CGPoint(x: labelWidth - 12, y: 0))
                borderPath?.addLine(to: CGPoint(x: labelWidth - 8, y: -5))
                borderPath?.addLine(to: CGPoint(x: labelWidth - 4, y: 0))

                // 到右上角
                borderPath?.addLine(to: CGPoint(x: labelWidth, y: 0))
                
                borders.path = borderPath?.cgPath
                
                borders.frame = CGRect(x: 0, y: 0, width: labelWidth, height: thickness);
                borders.fillColor = color.cgColor
                break
            case .bottom:
                borders.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness);
            case .left:
                borders.frame = CGRect(x: 0, y: 0 + thickness, width: thickness, height: frame.height - thickness * 2);
            case .right:
                borders.frame = CGRect(x: frame.width - thickness, y: 0 + thickness, width: thickness, height: frame.height - thickness * 2);
            default:
                break
            }
            
            borders.backgroundColor = color.cgColor;
            
            self.layer.addSublayer(borders);
        }
    }
}
