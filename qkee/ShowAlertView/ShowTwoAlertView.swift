//
//  ShowTwoAlertView.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/9/24.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit

class ShowTwoAlertView: UIViewController {

    //MARK: 控件
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var DialogView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var LeftButton: UIButton!
    @IBOutlet weak var RightButton: UIButton!
    
    //MARK: 變數
    var delegate: ShowAlertViewDelegate?
    var messageStr: String!
    var LeftButtonStr = "CANCEL"
    var RightButtonStr = "OK"
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewTouch = UITapGestureRecognizer(target: self, action: #selector(ViewCancelTouch));
        self.DialogView.addGestureRecognizer(viewTouch)
        
        messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        messageLabel.numberOfLines = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //設定view
        setupView()
        animateView()
        
        messageLabel.text = messageStr!
        LeftButton.setTitle(LeftButtonStr, for:.normal)
        RightButton.setTitle(RightButtonStr, for:.normal)
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 10
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    //MARK: 點其他地方取消Alert
    @objc func ViewCancelTouch(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: 按下左邊按鈕
    @IBAction func onTapLeftButton(_ sender: Any) {
        delegate?.LeftButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: 按下右邊按鈕
    @IBAction func onTapRightButton(_ sender: Any) {
        delegate?.RightButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
}
