//
//  BasePageVC.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/12/30.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit

class BasePageVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: 取得用戶的手機號碼＆用戶編號
    func getUserInfo()->(mobileNo: String, userid: Int) {
        
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
                    let mobileNo = result.value(forKey: "username")! as! String
                    let userid = result.value(forKey: "userid")! as! Int
                    return (mobileNo , userid)
                    //print("userid:\(userid)")
                }
            }
        }
        return("", 0)
    }
    
    //MARK: 假如沒有用戶編號，跳轉回登錄頁面
    func CheckUserID(userid: Int) {
        if userid == 0 {
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginView") {
                self.present(controller, animated: true, completion: nil)
                print("useridOrmobileNo=nil")
            }
        }
    }
}
