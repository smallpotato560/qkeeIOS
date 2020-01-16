//
//  LoginView.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/10/13.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData
import UserNotifications

class LoginView: UIViewController, UITextFieldDelegate, SSRadioButtonControllerDelegate  {
    
    // MARK: Login view 物件
    @IBOutlet var CheckedUserNameButton: UIButton! {
        didSet {
            CheckedUserNameButton.layer.cornerRadius = 20.0
            CheckedUserNameButton.layer.masksToBounds = true
        }
    }
    @IBOutlet var LoginButton: UIButton! {
        didSet {
            LoginButton.layer.cornerRadius = 25.0
            LoginButton.layer.masksToBounds = true
        }
    }
    @IBOutlet var SignButton: UIButton! {
        didSet {
            SignButton.layer.cornerRadius = 25.0
            SignButton.layer.masksToBounds = true
        }
    }
    @IBOutlet var manButton: UIButton!
    @IBOutlet var womenButton: UIButton!
    
    @IBOutlet var mobileNoText: UITextField!
    
    @IBOutlet var NameText: UITextField! {
        didSet {
            NameText.tag = 2
            NameText.delegate = self
            NameText.setBottomBorder(color: UIColor.lightGray.cgColor, size: CGSize(width: 0.0, height: 1.0))
            
            NameText.attributedPlaceholder = NSAttributedString(string:
            "名字", attributes:
                [NSAttributedString.Key.foregroundColor:UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        }
    }
    @IBOutlet var EmailText: UITextField! {
        didSet {
            EmailText.tag = 3
            EmailText.delegate = self
            EmailText.setBottomBorder(color: UIColor.lightGray.cgColor, size: CGSize(width: 0.0, height: 1.0))
            
            EmailText.attributedPlaceholder = NSAttributedString(string:
            "信箱", attributes:
                [NSAttributedString.Key.foregroundColor:UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        }
    }
    
    
    var radioButtonController: SSRadioButtonsController?
    var sex : String!
    var tokenString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        radioButtonController = SSRadioButtonsController(buttons: manButton, womenButton)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true
        
        mobileNoText.delegate = self
    }
    
    func didSelectButton(selectedButton: UIButton?)
    {
        sex = radioButtonController?.selectedButton()?.currentTitle
        //print(" \(sex!)" )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITextFieldDelegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        else {
            self.SignCustomer(sender: SignButton)
        }
        
        return true
    }
    
    // MARK: 進入編輯狀態
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.setBottomBorder(color: UIColor.black.cgColor, size: CGSize(width: 0.0, height: 2.0))
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.setClearButton(textfield: textField, color: .black)
    }
    
    // MARK: 結束編輯狀態
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.setBottomBorder(color: UIColor.lightGray.cgColor, size: CGSize(width: 0.0, height: 1.0))
    }
    
    // MARK: 點擊空白處鍵盤消失
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken)
    }
    
    // MARK: 檢查帳號
    @IBAction func CheckedUserName(sender: UIButton) {
        //print("pushvercode")
        if mobileNoText.text == "" {
            let alert = UIAlertController(title: "電話請勿為空", message: "請重新輸入", preferredStyle: .alert)
            let ok = UIAlertAction(title: "好", style: .default, handler: nil)
            
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        else {
            let mobileNo = mobileNoText.text!
            
            let url = HttpServer.CheckedAccountURL + "?account=" + mobileNo
            //print("url: \(url)")
            Alamofire.request(url).responseJSON(completionHandler: { response in
                if response.result.isSuccess {
                    do {
                        let json: JSON = try! JSON(data: response.data!)
                        //print("json: \(json)")
                        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                        if json["StatusCode"] == 1 {
                            alert.message = "此帳號已被使用。"
                        }
                        else {
                            alert.message = "此帳號可以使用。"
                        }
                        let ok = UIAlertAction(title: "好", style: .default, handler: nil)
                        
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    } catch {
                        print("error: \(String(describing: response.error))")
                    }
                }
                else {
                    print("error: \(String(describing: response.error))")
                }
            })
        }
    }
    
    @IBAction func unSegueBack(segue: UIStoryboardSegue)
    {
        
    }
    
    // MARK: 註冊帳號
    @IBAction func SignCustomer(sender: UIButton) {
        //print("pushvercode")
        if mobileNoText.text == "" {
            let alert = UIAlertController(title: "電話請勿為空", message: "請重新輸入", preferredStyle: .alert)
            let ok = UIAlertAction(title: "好", style: .default, handler: nil)
            
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        else if NameText.text == "" {
            let alert = UIAlertController(title: "暱稱請勿為空", message: "請重新輸入", preferredStyle: .alert)
            let ok = UIAlertAction(title: "好", style: .default, handler: nil)
            
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        else if EmailText.text == "" {
            let alert = UIAlertController(title: "信箱請勿為空", message: "請重新輸入", preferredStyle: .alert)
            let ok = UIAlertAction(title: "好", style: .default, handler: nil)
            
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        else {
            let mobileNo = mobileNoText.text!
            let name = NameText.text!
            let email = EmailText.text!
            
            let url = HttpServer.AddCustomerInfoURL + "?account=" + mobileNo + "&name=" + name + "&email=" +  email + "&gender=" + String(sex) + "&DeviceToken=" + tokenString
            print("url: \(url)")
            Alamofire.request(url).responseJSON(completionHandler: { response in
                if response.result.isSuccess {
                    do {
                        let json: JSON = try! JSON(data: response.data!)
                        //print("json: \(json)")
                        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                        if json["StatusCode"] == 1 {
                            alert.message = "此帳號已被使用。"
                        }
                        else {
                            alert.message = "此帳號可以使用。"
                        }
                        let ok = UIAlertAction(title: "好", style: .default, handler: nil)
                        
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    } catch {
                        print("error: \(String(describing: response.error))")
                    }
                }
                else {
                    print("error: \(String(describing: response.error))")
                }
            })
        }
    }
    
    // MARK: 已有會員
    @IBAction func GoVercodeView(sender: UIButton) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "VercodeView") {
            self.present(controller, animated: true, completion: nil)
        }
    }
}

extension UISearchBar {

    func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }

}
