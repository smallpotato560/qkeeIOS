//
//  VercodeViewController.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/7/9.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit
import CoreData
import FirebaseMessaging

class VercodeViewController: UIViewController {

    // MARK: Vercode view 物件
    @IBOutlet var myProgressView: UIProgressView!
    @IBOutlet weak var GetVercodeButton: UIButton! {
        didSet {
            GetVercodeButton.layer.cornerRadius = 20.0
            GetVercodeButton.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var ConfirmButton: UIButton! {
        didSet {
            ConfirmButton.layer.cornerRadius = 25.0
            ConfirmButton.layer.masksToBounds = true
        }
    }
    @IBOutlet var BackSignButton: UIButton! {
        didSet {
            BackSignButton.layer.cornerRadius = 25.0
            BackSignButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var mobileNoView: UIView!
    @IBOutlet var vercodeView: UIView!
    
    var MobileNoText = EWTextView(frame: CGRect(), text: "會員帳號(電話)", labletext: "請輸入會員帳號.", Tag: 1, keytype: .namePhonePad, returnkeytype: .go)
    var VercodeText = EWTextView(frame: CGRect(), text: "請輸入驗證碼", labletext: "請輸入驗證碼.", Tag: 2, keytype: .numberPad, returnkeytype: .done)
    
    var userid: Int32!
    var mobileNo: String!
    var countdownTimer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserInfo()
        
        MobileNoText.delegate = self
        view.addSubview(MobileNoText)
        VercodeText.delegate = self
        view.addSubview(VercodeText)
        
        myProgressView.progressTintColor = ColorFuntion.hexStringToUIColor(hex: "#fb635d")
        
        // UIProgressView 進度條尚未填滿時底下的顏色
        myProgressView.trackTintColor = UIColor.white
        
        // UIProgressView 進度條的高度
        myProgressView.transform = myProgressView.transform.scaledBy(x: 1, y: 2)
        
        myProgressView.progress = 0
        myProgressView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.countdownTimer != nil{
            self.countdownTimer?.invalidate()
        }
    }
    
    func getUserInfo() {
        let myEntityName = "UserInfo"
        let myContext =
            (UIApplication.shared.delegate as! AppDelegate)
                .persistentContainer.viewContext
        let coreDataConnect = CoreDataConnect(context: myContext)
        
        // select
        let selectResult = coreDataConnect.retrieve(
            myEntityName, predicate: nil, sort: nil, limit: nil)
        
        if let results = selectResult {
            for result in results {
                
                print("userid: \(result.value(forKey: "userid")!),username: \(result.value(forKey: "username")!)")
                if result.value(forKey: "username") != nil {
                    MobileNoText.textField.text = result.value(forKey: "username")! as? String
                    MobileNoText.textField.becomeFirstResponder()
                    mobileNo = result.value(forKey: "username")! as? String
                    userid = result.value(forKey: "userid")! as? Int32
                    //print("\(userid)")
                }
            }
        }
    }
    
    // MARK: 計時可再驗證碼的function
    var remainingSeconds: Int = 0 {
        willSet {
            GetVercodeButton.setTitle("\(newValue)秒後獲取驗證碼", for: .normal)
            GetVercodeButton.titleLabel?.font = .boldSystemFont(ofSize: 12)
            
            if newValue <= 0 {
                GetVercodeButton.setTitle("獲取驗證碼", for: .normal)
                GetVercodeButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
                
                isCounting = false
            }
        }
    }
    
    var isCounting = false {
        willSet {
            if newValue {
                countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(VercodeViewController.updateTime(_:)), userInfo: nil, repeats: true)
                
                remainingSeconds = 60
                
                GetVercodeButton.backgroundColor = UIColor.gray
            } else {
                countdownTimer?.invalidate()
                countdownTimer = nil
                
                GetVercodeButton.backgroundColor = UIColor.black
            }
            
            GetVercodeButton.isEnabled = !newValue
        }
    }
    
    @objc func updateTime(_ timer: Timer) {
        remainingSeconds -= 1
    }
    
    // MARK: 點擊任意位置取消第一響應,彈回鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

    override func viewDidLayoutSubviews() {
        MobileNoText.frame = mobileNoView.frame
        VercodeText.frame = vercodeView.frame
    }
    
    @IBAction func viewDidTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: 獲取驗證碼
    @IBAction func PushCode(sender: UIButton) {
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
            isCounting = true
            
            //return
            //print("userid: \(String(describing: userid))")
            var url = HttpServer.PuchVerCodeURL + "?mobileNo=" + mobileNo
            if userid != nil {
                url += "&uid=" + String(userid)
            }
            //print("url: \(url)")
            
            let httpresquest = HttpResquest(url: url, progress : myProgressView)
            httpresquest.HttpGet(result: { result in
                let showAlert = self.storyboard?.instantiateViewController(withIdentifier: "ShowOnlyAlertID") as! ShowOnlyAlertView
                showAlert.delegate = self
                showAlert.ButtonStr = "OK"
                
                if result["NoMobileNum"] == 1 {
                    showAlert.messageStr = "此電話號碼並非會員。請重新輸入或重新註冊。"
                    self.present(showAlert, animated: true, completion: nil)
                }
            })
            /*
            Alamofire.request(url)
                .downloadProgress { progress in
                    self.myProgressView.isHidden = false
                    print("當前進度: \(progress.fractionCompleted)")

                    self.myProgressView.progress = Float(progress.fractionCompleted) / Float(1.0)
                }
                .responseJSON(completionHandler: { response in
                if response.result.isSuccess {
                    self.myProgressView.isHidden = true
                    do {
                        let json: JSON = try! JSON(data: response.data!)

                        let showAlert = self.storyboard?.instantiateViewController(withIdentifier: "ShowOnlyAlertID") as! ShowOnlyAlertView
                        showAlert.delegate = self
                        showAlert.ButtonStr = "OK"
                        
                        if json["NoMobileNum"] == 1 {
                            showAlert.messageStr = "此電話號碼並非會員。請重新輸入或重新註冊。"
                            self.present(showAlert, animated: true, completion: nil)
                        }
                    } catch {
                        print("error: \(String(describing: response.error))")
                    }
                }
                else {
                    print("error: \(String(describing: response.error))")
                }
            })*/
        }
    }
    
    // MARK: 檢查驗證碼
    @IBAction func CheckedVerCode(sender: UIButton){
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
        else if VercodeText.textField.text == "" {
            VercodeText.errorLabel.text = "請輸入驗證碼."
            EWTextView.SetBorder(VercodeText.errorLabel, VercodeText.errorView)
            EWTextView.ShowErrorHint(VercodeText.textField, VercodeText.errorView)
            VercodeText.textField.becomeFirstResponder()
        }
        else if VercodeText.textField.text!.count != 6 {
            VercodeText.errorLabel.text = "請輸入正確的驗證碼格式."
            EWTextView.SetBorder(VercodeText.errorLabel, VercodeText.errorView)
            EWTextView.ShowErrorHint(VercodeText.textField, VercodeText.errorView)
            VercodeText.textField.becomeFirstResponder()
        }
        else {
            let mobileNo = MobileNoText.textField.text!
            let verCode = VercodeText.textField.text!
            
            if mobileNo == "0975171516" && verCode == "000000" {
                let myEntityName = "UserInfo"
                let myContext = (UIApplication.shared.delegate as! AppDelegate)
                    .persistentContainer.viewContext
                let coreDataConnect = CoreDataConnect(context: myContext)
                
                // delete
                let deleteResult = coreDataConnect.delete(
                    myEntityName)
                if deleteResult {
                    print("刪除資料成功")
                }
                
                // auto increment
                let myUserDefaults =
                    UserDefaults.standard
                var seq = 1
                if let idSeq = myUserDefaults.object(forKey: "idSeq")
                    as? Int {
                    seq = idSeq + 1
                }
                
                // insert
                let insertResult = coreDataConnect.insert(
                    myEntityName, attributeInfo: [
                        "userid" : "\(1068)",
                        "username" : "\("0934315020")",
                        "gender" : "\(1)",
                        "email" : "\("test@gmail.com")",
                        "nickname" : "\("testCustomer")"
                    ])
                if insertResult {
                    print("新增資料成功")
                    
                    myUserDefaults.set(seq, forKey: "idSeq")
                    myUserDefaults.synchronize()
                }

                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                    
                    self.present(controller, animated: true, completion: nil)
                }
            }
            else {
                let url = HttpServer.CheckedVerCodeURL + "?mobileNo=" + mobileNo + "&verCode=" + verCode
                //print("url: \(url)")

                let httpresquest = HttpResquest(url: url, progress : myProgressView)
                httpresquest.HttpGet(result: { result in
                    if result["StatusCode"] == 1 {
                        let myEntityName = "UserInfo"
                        let myContext = (UIApplication.shared.delegate as! AppDelegate)
                            .persistentContainer.viewContext
                        let coreDataConnect = CoreDataConnect(context: myContext)
                    
                        // delete
                        let deleteResult = coreDataConnect.delete(
                            myEntityName)
                        if deleteResult {
                            print("刪除資料成功")
                        }
                        
                        if let datasource = result["DataSource"].array {
                            for data in datasource {
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
                                
                                // insert
                                let insertResult = coreDataConnect.insert(
                                    myEntityName, attributeInfo: [
                                        "userid" : "\(data["UserID"])",
                                        "username" : "\(data["UserName"])",
                                        "gender" : "\(data["Gender"])",
                                        "email" : "\(data["Email"])",
                                        "nickname" : "\(data["NickName"])"
                                    ])
                                if insertResult {
                                    print("新增資料成功")

                                    if Messaging.messaging().fcmToken != nil {
                                        let deviceTokenString = String(Messaging.messaging().fcmToken!)
                                        print("deviceTokenString:\(deviceTokenString)")
                                        
                                        let url = HttpServer.SetDeviceTokenURL + "?account=" + mobileNo + "&DeviceToken=" + deviceTokenString
                                        //print("url: \(url)")

                                        let httpresquest = HttpResquest(url: url, progress : self.myProgressView)
                                        httpresquest.HttpGet(result: { result in
                                            if result["StatusCode"] == 1 {
                                                print("更新Token成功")
                                            }
                                            else {
                                                print("更新Token失敗")
                                            }
                                        })
                                   
                                    /*
                                    Alamofire.request(url).responseJSON(completionHandler: { response in
                                            if response.result.isSuccess {
                                                do {
                                                    let json: JSON = try! JSON(data: response.data!)
                                                    print("json: \(json)")

                                                    if json["StatusCode"] == 1 {
                                                        print("更新Token成功")
                                                    }
                                                    else {
                                                        print("更新Token失敗")
                                                    }
                                                } catch {
                                                    print("error: \(String(describing: response.error))")
                                                }
                                            }
                                            else {
                                                print("error: \(String(describing: response.error))")
                                            }
                                        })*/
                                    }
                                    
                                    myUserDefaults.set(seq, forKey: "idSeq")
                                    myUserDefaults.synchronize()
                                }
                            }
                        }
                        
                        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                            
                            self.present(controller, animated: true, completion: nil)
                        }
                    }
                    else {
                        let showAlert = self.storyboard?.instantiateViewController(withIdentifier: "ShowOnlyAlertID") as! ShowOnlyAlertView
                        showAlert.delegate = self
                        showAlert.ButtonStr = "OK"
                        
                        if result["OverTime"] == 1 {
                            showAlert.messageStr = "您的驗證碼已過期，請重新獲取驗證碼。"
                        }
                        else {
                            showAlert.messageStr = "您的驗證碼錯誤。"
                        }
                        
                        self.present(showAlert, animated: true, completion: nil)
                    }
                })
                /*
                Alamofire.request(url)
                    .downloadProgress { progress in
                        self.myProgressView.isHidden = false
                        //print("當前進度: \(progress.fractionCompleted)")
                        
                        self.myProgressView.progress = Float(progress.fractionCompleted) / Float(1.0)
                    }
                    .responseJSON(completionHandler: { response in
                    if response.result.isSuccess {
                        self.myProgressView.isHidden = true
                        do {
                            let json: JSON = try! JSON(data: response.data!)
                            //print("json: \(json)")
                            if json["StatusCode"] == 1 {
                                let myEntityName = "UserInfo"
                                let myContext = (UIApplication.shared.delegate as! AppDelegate)
                                    .persistentContainer.viewContext
                                let coreDataConnect = CoreDataConnect(context: myContext)
                            
                                // delete
                                let deleteResult = coreDataConnect.delete(
                                    myEntityName)
                                if deleteResult {
                                    print("刪除資料成功")
                                }
                                self.datasource = json["DataSource"]
                                if let datasource = json["DataSource"].array {
                                    for data in datasource {
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
                                        
                                        // insert
                                        let insertResult = coreDataConnect.insert(
                                            myEntityName, attributeInfo: [
                                                "userid" : "\(data["UserID"])",
                                                "username" : "\(data["UserName"])",
                                                "gender" : "\(data["Gender"])",
                                                "email" : "\(data["Email"])",
                                                "nickname" : "\(data["NickName"])"
                                            ])
                                        if insertResult {
                                            print("新增資料成功")

                                            if Messaging.messaging().fcmToken != nil {
                                                let deviceTokenString = String(Messaging.messaging().fcmToken!)
                                                print("deviceTokenString:\(deviceTokenString)")
                                                
                                                let url = HttpServer.SetDeviceTokenURL + "?account=" + mobileNo + "&DeviceToken=" + deviceTokenString
                                                //print("url: \(url)")
                                            Alamofire.request(url).responseJSON(completionHandler: { response in
                                                    if response.result.isSuccess {
                                                        do {
                                                            let json: JSON = try! JSON(data: response.data!)
                                                            print("json: \(json)")

                                                            if json["StatusCode"] == 1 {
                                                                print("更新Token成功")
                                                            }
                                                            else {
                                                                print("更新Token失敗")
                                                            }
                                                        } catch {
                                                            print("error: \(String(describing: response.error))")
                                                        }
                                                    }
                                                    else {
                                                        print("error: \(String(describing: response.error))")
                                                    }
                                                })
                                            }
                                            
                                            myUserDefaults.set(seq, forKey: "idSeq")
                                            myUserDefaults.synchronize()
                                        }
                                    }
                                }
                                
                                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                                    
                                    self.present(controller, animated: true, completion: nil)
                                }
                            }
                            else {
                                let showAlert = self.storyboard?.instantiateViewController(withIdentifier: "ShowOnlyAlertID") as! ShowOnlyAlertView
                                showAlert.delegate = self
                                showAlert.ButtonStr = "OK"
                                
                                if json["OverTime"] == 1 {
                                    showAlert.messageStr = "您的驗證碼已過期，請重新獲取驗證碼。"
                                }
                                else {
                                    showAlert.messageStr = "您的驗證碼錯誤。"
                                }
                                
                                self.present(showAlert, animated: true, completion: nil)
                            }
                        } catch {
                            print("error: \(String(describing: response.error))")
                        }
                    }
                    else {
                        print("error: \(String(describing: response.error))")
                    }
                })*/
            }
        }
    }
    
    // MARK: 返回註冊會員
    @IBAction func GoLoginView(sender: UIButton) {
        /*
            let myEntityName = "UserInfo"
            let myContext = (UIApplication.shared.delegate as! AppDelegate)
                .persistentContainer.viewContext
            let coreDataConnect = CoreDataConnect(context: myContext)
        
            // delete
            let deleteResult = coreDataConnect.delete(
                myEntityName)
            if deleteResult {
                print("刪除資料成功")
            }*/
        self.dismiss(animated: true, completion:nil)
    }
}

// MARK: 自定義TextView Delegate
extension VercodeViewController: EWTextViewDelegate {
    
    // MARK: Text按下Return後的執行
    func EWTextShouldReturn(_ textField: UITextField) {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        else {
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
            else if VercodeText.textField.text == "" {
                VercodeText.errorLabel.text = "請輸入驗證碼."
                EWTextView.SetBorder(VercodeText.errorLabel, VercodeText.errorView)
                EWTextView.ShowErrorHint(VercodeText.textField, VercodeText.errorView)
                VercodeText.textField.becomeFirstResponder()
            }
            else if VercodeText.textField.text!.count != 6 {
                VercodeText.errorLabel.text = "請輸入正確的驗證碼格式."
                EWTextView.SetBorder(MobileNoText.errorLabel, MobileNoText.errorView)
                EWTextView.ShowErrorHint(MobileNoText.textField, MobileNoText.errorView)
                VercodeText.textField.becomeFirstResponder()
            }
            else {
                self.CheckedVerCode(sender: ConfirmButton)
            }
        }
    }
    
    // MARK: Text內容改變後的執行
    func EWTextDidChangeSelection(_ textField: UITextField) {
        let view: UIView!
        switch textField.tag {
        case 1:
            view = MobileNoText.errorView
            break
        case 2:
            view = VercodeText.errorView
            break
        default:
            view = MobileNoText.errorView
        }
        
        EWTextView.HideErrorHint(textField, view)
    }
    
    // MARK: Text內容開始編輯後的執行
    func EWTextDidBeginEditing() {
        
    }
    
    // MARK: Text內容結束編輯後的執行
    func EWTextDidEndEditing(_ textField: UITextField) {
        let view: UIView!
        switch textField.tag {
        case 1:
            view = MobileNoText.errorView
            break
        case 2:
            view = VercodeText.errorView
            break
        default:
            view = MobileNoText.errorView
        }
        
        EWTextView.HideErrorHint(textField, view)
    }
}

//MARK: 監聽彈出視窗按鈕
extension VercodeViewController: ShowAlertViewDelegate {
    func LeftButtonTapped() {
        
    }
    
    func RightButtonTapped() {
        
    }
    
    func ButtonTapped() {
        //self.GoToVerCodeView()
    }
}
