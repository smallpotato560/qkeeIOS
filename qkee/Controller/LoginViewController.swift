//
//  LoginViewController.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/9/15.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import FirebaseMessaging

class LoginViewController: UIViewController, UITextFieldDelegate, SSRadioButtonControllerDelegate  {
    
    // MARK: Login view 物件
    @IBOutlet var myProgressView: UIProgressView!
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
    
    @IBOutlet var mobileNoView: UIView!
    @IBOutlet var nameView: UIView!
    @IBOutlet var emailView: UIView!
    
    var radioButtonController: SSRadioButtonsController?
    var sex = "1"
    var tokenString = ""
    var SignStatus = false
    
    var MobileNoText = EWTextView(frame: CGRect(), text: "會員帳號(電話)", labletext: "請輸入會員帳號.", Tag: 1, keytype: .namePhonePad, returnkeytype: .go)
    let NameText = EWTextView(frame: CGRect(), text: "名字", labletext: "請輸入名字.", Tag: 2, keytype: .default, returnkeytype: .go)
    let EmailText = EWTextView(frame: CGRect(), text: "信箱", labletext: "請輸入信箱.", Tag: 3, keytype: .emailAddress, returnkeytype: .done)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        radioButtonController = SSRadioButtonsController(buttons: manButton, womenButton)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true
        
        MobileNoText.delegate = self
        view.addSubview(MobileNoText)
        NameText.delegate = self
        view.addSubview(NameText)
        EmailText.delegate = self
        view.addSubview(EmailText)
        
        myProgressView.progressTintColor = ColorFuntion.hexStringToUIColor(hex: "#fb635d")
        
        // UIProgressView 進度條尚未填滿時底下的顏色
        myProgressView.trackTintColor = UIColor.white
        
        // UIProgressView 進度條的高度
        myProgressView.transform = myProgressView.transform.scaledBy(x: 1, y: 2)
        
        myProgressView.progress = 0
        myProgressView.isHidden = true
        
        if Messaging.messaging().fcmToken != nil {
            tokenString = String(Messaging.messaging().fcmToken!)
        }
    }
    
    func didSelectButton(selectedButton: UIButton?)
    {
        sex = (radioButtonController?.selectedButton()?.currentTitle)!
        //print(" \(sex)" )
    }
    
    // MARK: 點擊任意位置取消第一響應,彈回鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

    override func viewDidLayoutSubviews() {
        MobileNoText.frame = mobileNoView.frame
        NameText.frame = nameView.frame
        EmailText.frame = emailView.frame
    }

    @IBAction func viewDidTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: 檢查帳號
    @IBAction func CheckedUserName(sender: UIButton) {
        //print("pushvercode")
        if MobileNoText.textField.text == "" {
            MobileNoText.errorLabel.text = "請輸入會員帳號."
            EWTextView.SetBorder(MobileNoText.errorLabel, MobileNoText.errorView)
            EWTextView.ShowErrorHint(MobileNoText.textField, MobileNoText.errorView)
            MobileNoText.textField.becomeFirstResponder()
        }
        else if MobileNoText.textField.text!.count < 10 {
            MobileNoText.errorLabel.text = "請輸入正確的帳號格式."
            EWTextView.SetBorder(MobileNoText.errorLabel, MobileNoText.errorView)
            EWTextView.ShowErrorHint(MobileNoText.textField, MobileNoText.errorView)
            MobileNoText.textField.becomeFirstResponder()
        }
        else {
            let mobileNo = MobileNoText.textField.text!
            
            let url = HttpServer.CheckedAccountURL + "?account=" + mobileNo
            //print("url: \(url)")
            
            let httpresquest = HttpResquest(url: url, progress : myProgressView)
            httpresquest.HttpGet(result: { result in
                do {
                    let showAlert = self.storyboard?.instantiateViewController(withIdentifier: "ShowOnlyAlertID") as! ShowOnlyAlertView
                    showAlert.delegate = self
                    showAlert.ButtonStr = "OK"
                    
                    if result["StatusCode"] == 1 {
                        showAlert.messageStr = "此帳號已經被使用了。"
                    }
                    else {
                        showAlert.messageStr = "此帳號可以使用。"
                    }

                    self.SignStatus = false
                    self.present(showAlert, animated: true, completion: nil)
                } catch {
                    print("檢查帳號 do get json error: \(String(describing: result.error))")
                }
            })
            /*
            Alamofire.request(url)
            .downloadProgress { progress in
                self.myProgressView.isHidden = false
                print("檢查帳號當前進度: \(progress.fractionCompleted)")

                self.myProgressView.progress = Float(progress.fractionCompleted) / Float(1.0)
            }
            .responseJSON(completionHandler: { response in
                if response.result.isSuccess {
                    self.myProgressView.isHidden = true
                    do {
                        let json: JSON = try! JSON(data: response.data!)
                        //print("json: \(json)")

                        let showAlert = self.storyboard?.instantiateViewController(withIdentifier: "ShowOnlyAlertID") as! ShowOnlyAlertView
                        showAlert.delegate = self
                        showAlert.ButtonStr = "OK"
                        
                        if json["StatusCode"] == 1 {
                            showAlert.messageStr = "此帳號已經被使用了。"
                        }
                        else {
                            showAlert.messageStr = "此帳號可以使用。"
                        }

                        self.SignStatus = false
                        self.present(showAlert, animated: true, completion: nil)
                    } catch {
                        print("檢查帳號 do get json error: \(String(describing: response.error))")
                    }
                }
                else {
                    print("檢查帳號 get url error: \(String(describing: response.error))")
                }
            })*/
        }
    }
    
    @IBAction func unSegueBack(segue: UIStoryboardSegue)
    {
        
    }
    
    // MARK: 註冊帳號
    @IBAction func SignCustomer(sender: UIButton) {
        let mobileNo = MobileNoText.textField.text!
        let name = NameText.textField.text!
        let email = EmailText.textField.text!
        
        if MobileNoText.textField.text == "" {
            MobileNoText.errorLabel.text = "請輸入會員帳號."
            EWTextView.SetBorder(MobileNoText.errorLabel, MobileNoText.errorView)
            EWTextView.ShowErrorHint(MobileNoText.textField, MobileNoText.errorView)
            MobileNoText.textField.becomeFirstResponder()
        }
        else if MobileNoText.textField.text!.count < 10 {
            MobileNoText.errorLabel.text = "請輸入正確的帳號格式."
            EWTextView.SetBorder(MobileNoText.errorLabel, MobileNoText.errorView)
            EWTextView.ShowErrorHint(MobileNoText.textField, MobileNoText.errorView)
            MobileNoText.textField.becomeFirstResponder()
        }
        else if NameText.textField.text == "" {
            EWTextView.ShowErrorHint(NameText.textField, NameText.errorView)
            NameText.textField.becomeFirstResponder()
        }
        else if EmailText.textField.text == "" {
            EmailText.errorLabel.text = "請輸入信箱."
            EWTextView.SetBorder(EmailText.errorLabel, EmailText.errorView)
            EWTextView.ShowErrorHint(EmailText.textField, EmailText.errorView)
            EmailText.textField.becomeFirstResponder()
        }
        else if !VakudationFunction.isValidEmail(Str: EmailText.textField.text!) {
            EmailText.errorLabel.text = "請輸入正確格式Email."
            EWTextView.SetBorder(EmailText.errorLabel, EmailText.errorView)
            EWTextView.ShowErrorHint(EmailText.textField, EmailText.errorView)
            EmailText.textField.becomeFirstResponder()
        }
        else {
            let url = HttpServer.AddCustomerInfoURL + "?account=\(mobileNo)&name=\(name)&email=\(email)&gender=\(sex)&DeviceToken=\(tokenString)"
            //print("url: \(url)")
            //let para = ["account": mobileNo, "name": name, "email": email, "gender": sex, "DeviceToken": tokenString]
            
            let httpresquest = HttpResquest(url: url, progress : myProgressView)
            httpresquest.HttpGet(result: { result in
                do {
                    let showAlert = self.storyboard?.instantiateViewController(withIdentifier: "ShowOnlyAlertID") as! ShowOnlyAlertView
                    showAlert.delegate = self
                    showAlert.ButtonStr = "OK"
                    
                    if result["StatusCode"] == 1 {
                        self.SignStatus = true
                        showAlert.messageStr = "註冊會員成功。"
                    }
                    else {
                        if result["CheckedAccount"] == 1 {
                            showAlert.messageStr = "此帳號已經被使用了。"
                        }
                        else {
                            showAlert.messageStr = "註冊會員失敗。"
                        }
                    }
                    self.present(showAlert, animated: true, completion: nil)
                } catch {
                    print("註冊 do get json error: \(String(describing: result.error))")
                }
            })
            /*
            Alamofire.request(url ,parameters: para)
            .downloadProgress { progress in
                self.myProgressView.isHidden = false
                print("註冊當前進度: \(progress.fractionCompleted)")

                self.myProgressView.progress = Float(progress.fractionCompleted) / Float(1.5)
            }
            .responseJSON(completionHandler: { response in
                if response.result.isSuccess {
                    self.myProgressView.isHidden = true
                    do {
                        let json: JSON = try! JSON(data: response.data!)
                        //print("json: \(json)")

                        let showAlert = self.storyboard?.instantiateViewController(withIdentifier: "ShowOnlyAlertID") as! ShowOnlyAlertView
                        showAlert.delegate = self
                        showAlert.ButtonStr = "OK"
                        
                        if json["StatusCode"] == 1 {
                            self.SignStatus = true
                            showAlert.messageStr = "註冊會員成功。"
                        }
                        else {
                            if json["CheckedAccount"] == 1 {
                                showAlert.messageStr = "此帳號已經被使用了。"
                            }
                            else {
                                showAlert.messageStr = "註冊會員失敗。"
                            }
                        }
                        self.present(showAlert, animated: true, completion: nil)
                    } catch {
                        print("註冊 do get json error: \(String(describing: response.error))")
                    }
                }
                else {
                    print("get url error: \(String(describing: response.error))")
                }
            })*/
        }
    }
    
    // MARK: 已有會員，前往驗證碼頁面
    @IBAction func GoVercodeView(sender: UIButton) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "VercodeView") {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func GoToVerCodeView() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "VercodeView") as? VercodeViewController {
            
            let myEntityName = "UserInfo"
            let myContext =
                (UIApplication.shared.delegate as! AppDelegate)
                    .persistentContainer.viewContext
            let coreDataConnect = CoreDataConnect(context: myContext)
            
            // auto increment
            let myUserDefaults =
                UserDefaults.standard
            var seq = 1
            if let idSeq = myUserDefaults.object(forKey: "idSeq")
                as? Int {
                seq = idSeq + 1
            }
            
            var mobileNo: String!
            let selectResult = coreDataConnect.retrieve(
                myEntityName, predicate: nil, sort: nil, limit: nil)
            
            if let results = selectResult {
                for result in results {
                    print("userid: \(result.value(forKey: "userid")!),username: \(result.value(forKey: "username")!)")
                    if result.value(forKey: "username") != nil {
                        mobileNo = result.value(forKey: "username")! as? String
                    }
                }
            }
            
            if mobileNo == "" || mobileNo == nil {
                // insert
                let insertResult = coreDataConnect.insert(
                    myEntityName, attributeInfo: [
                        "username" : "\(MobileNoText.textField.text!)"
                    ])
                if insertResult {
                    print("新增資料成功")
                    
                    myUserDefaults.set(seq, forKey: "idSeq")
                    myUserDefaults.synchronize()
                }
            }
            present(controller, animated: true, completion: nil)
        }
    }
}

extension LoginViewController: EWTextViewDelegate {
    func EWTextShouldReturn(_ textField: UITextField) {
        
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        else {
            self.SignCustomer(sender: SignButton)
        }
    }
    
    func EWTextDidChangeSelection(_ textField: UITextField) {
        let view: UIView!
        switch textField.tag {
        case 1:
            view = MobileNoText.errorView
            break
        case 2:
            view = NameText.errorView
            break
        case 3:
            view = EmailText.errorView
            break
        default:
            view = MobileNoText.errorView
        }
        
        EWTextView.HideErrorHint(textField, view)
    }
    
    func EWTextDidBeginEditing() {
        
    }
    
    func EWTextDidEndEditing(_ textField: UITextField) {
        let view: UIView!
        switch textField.tag {
        case 1:
            view = MobileNoText.errorView
            break
        case 2:
            view = NameText.errorView
            break
        case 3:
            view = EmailText.errorView
            break
        default:
            view = MobileNoText.errorView
        }
        
        EWTextView.HideErrorHint(textField, view)
    }
}

//MARK: 監聽彈出視窗按鈕
extension LoginViewController: ShowAlertViewDelegate {
    func LeftButtonTapped() {
        
    }
    
    func RightButtonTapped() {
        
    }
    
    func ButtonTapped() {
        if SignStatus {
            self.dismiss(animated: true, completion: nil)
            self.GoToVerCodeView()
        }
    }
}
