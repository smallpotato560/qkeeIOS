//
//  UserViewController.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/9/12.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit
import CoreData

class UserViewController: UIViewController {
    
    @IBOutlet var myProgressView: UIProgressView!
    
    // MARK: UserInfo View 物件
    @IBOutlet var mobileNoLabel: UILabel!
    @IBOutlet var nicknameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var sexLabel: UILabel!
    @IBOutlet var reloadButton: UIButton!
    
    // MARK: User View 物件
    @IBOutlet var FavoriteView: UIViewEffect!
    @IBOutlet var TermsView: UIViewEffect!
    @IBOutlet var LogoutView: UIViewEffect! {
        didSet {
            LogoutView.layer.addBorder(edge: .top, color: ColorFuntion.hexStringToUIColor(hex: "#4E5156"), thickness: 1)
        }
    }
    
    var userid: Int32!
    var mobileNo: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        getUserInfo()
        
        let favoriteTouch = UITapGestureRecognizer(target: self, action: #selector(FavoriteTouch));
        self.FavoriteView?.addGestureRecognizer(favoriteTouch)
        let termsTouch = UITapGestureRecognizer(target: self, action: #selector(TermsTouch));
        self.TermsView.addGestureRecognizer(termsTouch)
        let logoutTouch = UITapGestureRecognizer(target: self, action: #selector(LogoutTouch));
        self.LogoutView.addGestureRecognizer(logoutTouch)
        
        // UIProgressView 的進度條顏色
        myProgressView.progressTintColor = ColorFuntion.hexStringToUIColor(hex: "#fb635d")
        
        // UIProgressView 進度條尚未填滿時底下的顏色
        myProgressView.trackTintColor = UIColor.white
        
        // UIProgressView 進度條的高度
        myProgressView.transform = myProgressView.transform.scaledBy(x: 1, y: 2)
        
        myProgressView.progress = 0
        myProgressView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if userid == nil && mobileNo == nil {
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginView") {
                self.present(controller, animated: true, completion: nil)
                print("useridOrmobileNo=nil")
            }
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
                //print("\(result.value(forKey: "userid")!). \(result.value(forKey: "username")!)")
                if result.value(forKey: "username") != nil && result.value(forKey: "userid") as! Int > 0 {
                    userid = result.value(forKey: "userid")! as? Int32
                    mobileNo = result.value(forKey: "username")! as? String
                    mobileNoLabel.text = mobileNo
                    nicknameLabel.text = result.value(forKey: "nickname")! as? String
                    emailLabel.text = result.value(forKey: "email")! as? String
                    
                    let gender = result.value(forKey: "gender")! as? Int32
                    if gender == 0 {
                        sexLabel.text = "女"
                    }
                    else {
                        sexLabel.text = "男"
                    }
                }
            }
        }
    }
    
    // MARK: 返回標記   
    @IBAction func unSegueBack(segue: UIStoryboardSegue)
    {
        
    }
    
    // MARK: 我的最愛事件
    @objc func FavoriteTouch(gesture: UITapGestureRecognizer){
        print("我的最愛")
    }
    
    // MARK: 服務條款事件
    @objc func TermsTouch(){
        //print("服務條款")
        
        let urlStr = "http://www.qkee.com.tw/privacy.aspx"
        if let controller = storyboard?.instantiateViewController(withIdentifier: "WebView")
            as? WebViewController {
            controller.urlStr = urlStr
            present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: 登出事件
    @objc func LogoutTouch(){
        //print("登出")
        
        let showAlert = self.storyboard?.instantiateViewController(withIdentifier: "ShowTwoAlertID") as! ShowTwoAlertView
        showAlert.providesPresentationContextTransitionStyle = true
        showAlert.definesPresentationContext = true
        showAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        showAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        showAlert.delegate = self
        showAlert.messageStr = "您確認要退出會員狀態嗎？"
        //showAlert.LeftButtonStr = "CANCEL"
        showAlert.RightButtonStr = "OK"
        self.present(showAlert, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("按下")
        if let touch = touches.first {
            if touch.view == self.FavoriteView || touch.view == self.TermsView || touch.view == self.LogoutView {
                touch.view?.backgroundColor = ColorFuntion.hexStringToUIColor(hex: "b6b6b6")
            }
        }
        
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("event canceled!")
        if let touch = touches.first {
            touch.view?.backgroundColor = ColorFuntion.hexStringToUIColor(hex: "2F3136")
        }
    }
    
    @IBAction func reloadUserInfo(sender: UIButton){
        
        let url = HttpServer.GetCustomerInfoURL + "?uid=\(userid!)&mobileNo=\(mobileNo!)"
        //print("url: \(url)")
        
        let httpresquest = HttpResquest(url: url, progress : myProgressView)
        httpresquest.HttpGet(result: { result in
            if result["StatusCode"] == 1 {
                if let datasource = result["DataSource"].array {
                    for data in datasource {
                        let myEntityName = "UserInfo"
                        let myContext =
                            (UIApplication.shared.delegate as! AppDelegate)
                                .persistentContainer.viewContext
                        let coreDataConnect = CoreDataConnect(context: myContext)
                        
                        // update
                        let predicate = "userid = '\(self.userid!)'"
                        let updateResult = coreDataConnect.update(
                          myEntityName,
                          predicate: predicate,
                          attributeInfo: [
                              "username" : "\(data["UserName"])",
                              "gender" : "\(data["Gender"])",
                              "email" : "\(data["Email"])",
                              "nickname" : "\(data["NickName"])"
                          ])

                        self.mobileNoLabel.text = data["UserName"].string!
                        self.nicknameLabel.text = data["NickName"].string!
                        self.emailLabel.text = data["Email"].string!
                        let gender = data["Gender"].int!
                        if gender == 0 {
                            self.sexLabel.text = "女"
                        }
                        else {
                            self.sexLabel.text = "男"
                        }
                        if updateResult {
                            print("更新資料成功")

                            self.myProgressView.isHidden = true
                            // select
                            let selectResult = coreDataConnect.retrieve(
                                myEntityName, predicate: nil, sort: nil, limit: nil)
                            
                            if let results = selectResult {
                                for _ in results {
                                    //print("\(result.value(forKey: "username")!)")
                                    //print("\(result.value(forKey: "gender")!)")
                                    //print("\(result.value(forKey: "email")!)")
                                    //print("\(result.value(forKey: "nickname")!)")
                                }
                            }
                        }
                    }
                }
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
                do {
                    let json: JSON = try! JSON(data: response.data!)
                    self.myProgressView.isHidden = true
                    if json["StatusCode"] == 1 {
                        //self.datasource = json["DataSource"]
                        if let datasource = json["DataSource"].array {
                            for data in datasource {
                                let myEntityName = "UserInfo"
                                let myContext =
                                    (UIApplication.shared.delegate as! AppDelegate)
                                        .persistentContainer.viewContext
                                let coreDataConnect = CoreDataConnect(context: myContext)
                                
                                // update
                                let predicate = "userid = '\(self.userid!)'"
                                let updateResult = coreDataConnect.update(
                                  myEntityName,
                                  predicate: predicate,
                                  attributeInfo: [
                                      "username" : "\(data["UserName"])",
                                      "gender" : "\(data["Gender"])",
                                      "email" : "\(data["Email"])",
                                      "nickname" : "\(data["NickName"])"
                                  ])

                                self.mobileNoLabel.text = data["UserName"].string!
                                self.nicknameLabel.text = data["NickName"].string!
                                self.emailLabel.text = data["Email"].string!
                                let gender = data["Gender"].int!
                                if gender == 0 {
                                    self.sexLabel.text = "女"
                                }
                                else {
                                    self.sexLabel.text = "男"
                                }
                                if updateResult {
                                    print("更新資料成功")

                                    self.myProgressView.isHidden = true
                                    // select
                                    let selectResult = coreDataConnect.retrieve(
                                        myEntityName, predicate: nil, sort: nil, limit: nil)
                                    
                                    if let results = selectResult {
                                        for result in results {
                                            //print("\(result.value(forKey: "username")!)")
                                            //print("\(result.value(forKey: "gender")!)")
                                            //print("\(result.value(forKey: "email")!)")
                                            //print("\(result.value(forKey: "nickname")!)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else {
                        print("A")
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

//MARK: View 設定編框
extension UIView {
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }}
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }}
}

//MARK: 設定邊框
extension CALayer{
    func addBorder(edge:UIRectEdge, color:UIColor, thickness:CGFloat){
        
        let borders = CALayer()
        
        switch edge {
        case .top:
            borders.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness);
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
        
        self.addSublayer(borders);
    }
}

//MARK: 監聽彈出視窗按鈕
extension UserViewController: ShowAlertViewDelegate {
    func ButtonTapped() {
    }
    
    func LeftButtonTapped() {
        print("cancelButtonTapped")
    }
    
    func RightButtonTapped() {
        //print("oklButtonTapped")
        self.dismiss(animated: true, completion: nil)
        let myEntityName = "UserInfo"
        let myContext =
            (UIApplication.shared.delegate as! AppDelegate)
                .persistentContainer.viewContext
        let coreDataConnect = CoreDataConnect(context: myContext)
        
        // delete
        let predicate = "userid = \(self.userid!)"
        let deleteResult = coreDataConnect.delete(
            myEntityName, predicate: predicate)
        if deleteResult {
            print("刪除資料成功")
            
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginView") {
                self.present(controller, animated: true, completion: nil)
                print("Logout")
            }
        }
    }
}
