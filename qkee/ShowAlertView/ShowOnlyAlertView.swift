//
//  ShowOnlyAlertView.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/9/24.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit

class ShowOnlyAlertView: UIViewController {

    //MARK: 控件
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var DialogView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var Button: UIButton!
    
    //MARK: 變數
    var delegate: ShowAlertViewDelegate?
    var messageStr: String!
    var ButtonStr = "OK"
    let alertViewGrayColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
    
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
        
        messageLabel.text = messageStr
        Button.setTitle(ButtonStr, for:.normal)
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 5
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
    @IBAction func onTapButton(_ sender: Any) {
        delegate?.ButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
}
