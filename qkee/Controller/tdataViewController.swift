//
//  tdataViewController.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/10/25.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class tdataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var myView: UIView!
    @IBOutlet var titleView: UIView!
    @IBOutlet var myProgressView: UIProgressView!
    
    var myTableView: UITableView!
    var refreshControl: UIRefreshControl!
    var datasource : JSON!
    var userid: Int32!
    var mobileNo: String!
    var MeetDatalist: [MeetData] = []
    var path: NSIndexPath = NSIndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView高度 = myview(螢幕高度-114) - tabbar高度
        let myTableViewHeight = myView.bounds.height - (self.tabBarController?.tabBar.frame.height)!
        
        self.myTableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: myTableViewHeight), style: .plain)
        
        self.myTableView.delegate = self
        
        self.myTableView.dataSource = self
        
        self.myTableView.register(UINib(nibName: "DataCell", bundle: nil), forCellReuseIdentifier: "DataCell")
        
        self.myTableView.backgroundColor = ColorFuntion.hexStringToUIColor(hex: "#2F3136")
        
        myTableView.rowHeight = 64
        
        myTableView.separatorStyle = .none
        
        
        if #available(iOS 11.0, *) {
            myTableView.contentInsetAdjustmentBehavior = .never
            if #available(iOS 13.0, *) {
                myTableView.automaticallyAdjustsScrollIndicatorInsets = false
            } else {
                // Fallback on earlier versions
            }
        } else {
            // Fallback on earlier versions
        }
        myView.addSubview(self.myTableView)
        
        getUserInfo()
        downloadJSON()
        
        
        
        // UIProgressView 的進度條顏色
        myProgressView.progressTintColor = ColorFuntion.hexStringToUIColor(hex: "#fb635d")
        
        // UIProgressView 進度條尚未填滿時底下的顏色
        myProgressView.trackTintColor = UIColor.white
        
        myProgressView.transform = myProgressView.transform.scaledBy(x: 1, y: 2)
        
        myProgressView.progress = 0
        myProgressView.isHidden = true
        
        
        //添加刷新
        refreshControl = UIRefreshControl()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl?.attributedTitle = NSAttributedString(string: "更新資料", attributes: attributes)
        refreshControl?.tintColor = UIColor.white
        refreshControl?.backgroundColor = UIColor.black
        refreshControl?.addTarget(self, action: #selector(downloadJSON), for: UIControl.Event.valueChanged)
        myTableView.refreshControl = refreshControl
        
        titleView.layer.addBorder(edge: .bottom, color: ColorFuntion.hexStringToUIColor(hex: "#2a293b"), thickness: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if userid == nil && mobileNo == nil {
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginView") {
                self.present(controller, animated: true, completion: nil)
                print("useridOrmobileNo=nil")
            }
        }
    }
    
    @objc func downloadJSON() {
        if userid != nil && mobileNo != nil {
        MeetDatalist = []
        let url = HttpServer.GetUserDataListURL + "?mobileNo=" + mobileNo + "&PageIndex=1&PageSize=3"
            //print("url: \(url)")

            let httpresquest = HttpResquest(url: url, progress : myProgressView)
            httpresquest.HttpGet(result: { result in
                //print("json\(result)")
                if result["StatusCode"] == 1 {
                    if let datasource = result["DataSource"].array {
                        for data in datasource {
                            let time = data["Time"].string!
                            let name = data["MeetingName"].string!
                            let mid = data["MeetingID"].int!
                            let vid = data["VendorID"].int!
                            let dataName = data["DataName"].string!
                    
                            self.MeetDatalist.append(MeetData(name: name, date: time, mid: mid, vid: vid, dataName: dataName))
                        }
                    }
                    
                        
                    DispatchQueue.main.async {
                        if self.MeetDatalist.count > 8 {
                            //self.MeetDatalist.append(MeetData(name: "", date: "", mid: 0, vid: 0, dataName: ""))
                        }
                        self.myTableView.reloadData()
                        self.refreshControl!.endRefreshing()
                    }
                    
                    print("data count:\(self.MeetDatalist.count)")
                }
            })
           
            /*
            Alamofire.request(url)
                .downloadProgress { progress in
                    self.myProgressView.isHidden = false
                    //print("當前進度: \(progress.fractionCompleted)")

                    self.myProgressView.progress = Float(progress.fractionCompleted) / Float(1)
                }
                .responseJSON(completionHandler: { response in
                    self.myProgressView.isHidden = true
                    if response.result.isSuccess {
                        do {
                            let json: JSON = try! JSON(data: response.data!)
                            if json["StatusCode"] == 1 {
                                if let datasource = json["DataSource"].array {
                                    for data in datasource {
                                        let time = data["Time"].string!
                                        let name = data["MeetingName"].string!
                                        let mid = data["MeetingID"].int!
                                        let vid = data["VendorID"].int!
                                        let dataName = data["DataName"].string!
                                
                                        self.MeetDatalist.append(MeetData(name: name, date: time, mid: mid, vid: vid, dataName: dataName))
                                    }
                                }
                                
                                    
                                DispatchQueue.main.async {
                                    if self.MeetDatalist.count > 8 {
                                        //self.MeetDatalist.append(MeetData(name: "", date: "", mid: 0, vid: 0, dataName: ""))
                                    }
                                    self.myTableView.reloadData()
                                    self.refreshControl!.endRefreshing()
                                }
                                
                                print("data count:\(self.MeetDatalist.count)")
                            }
                            else {
                                
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
                if result.value(forKey: "username") != nil {
                    mobileNo = result.value(forKey: "username")! as? String
                    userid = result.value(forKey: "userid")! as? Int32
                    //print("\(userid)")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MeetDatalist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: DataTableViewCell = myTableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! DataTableViewCell
        
        if(self.MeetDatalist.count > 0) {
            if indexPath.row == 0 {
                cell.layer.addBorder(edge: .bottom, color: ColorFuntion.hexStringToUIColor(hex: "#2a293b"), thickness: 1)
            }
            else if indexPath.row == self.MeetDatalist.count - 1 {
                cell.layer.addBorder(edge: .bottom, color: ColorFuntion.hexStringToUIColor(hex: "#2a293b"), thickness: 2)
            }
            else {
                cell.layer.addBorder(edge: .top, color: ColorFuntion.hexStringToUIColor(hex: "#2a293b"), thickness: 1)
                cell.layer.addBorder(edge: .bottom, color: ColorFuntion.hexStringToUIColor(hex: "#2a293b"), thickness: 1)
            }
            
            
            cell.DateLabel.text = MeetDatalist[indexPath.row].date
            cell.nameLabel.text = MeetDatalist[indexPath.row].name
            cell.mid = MeetDatalist[indexPath.row].mid
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //pragma mark - 三个系统代理必须全部实现！
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        //showMenu = true
        //path = indexPath as NSIndexPath
        
        //cell中需要重写canBecomeFirstResponder
        //let cell: DataTableViewCell = tableView.cellForRow(at: indexPath) as! DataTableViewCell
        
        //cell.contentView.backgroundColor = UIColor.black
            
        //需要成为第一响应者
        //cell.becomeFirstResponder()
        print("mid: \(MeetDatalist[indexPath.row].mid)")
        if MeetDatalist[indexPath.row].mid != 0 && MeetDatalist[indexPath.row].vid != 0{
            print(MeetDatalist[indexPath.row].name)
            let mid = MeetDatalist[indexPath.row].mid
            let vid = MeetDatalist[indexPath.row].vid
            let dataName = MeetDatalist[indexPath.row].dataName

            let urlStr = HttpServer.GetUserDataDetailURL + "?mid=\(mid)&vid=\(vid)&dataName=\(dataName)"
            if let controller = storyboard?.instantiateViewController(withIdentifier: "WebView")
                as? WebViewController {
                controller.urlStr = urlStr
                present(controller, animated: true, completion: nil)
            }
        }
        
        
        
        
        /*
        let menu: UIMenuController = UIMenuController.shared
        
        //这里的frame影响箭头的位置
        var rect: CGRect = cell.frame
        
        rect.size.width = 200
        
        menu.setTargetRect(rect, in: tableView)
        
        let item: UIMenuItem = UIMenuItem(title: "删除", action: #selector(tdataViewController.delMenuPress(menu:)))
        let copyItem: UIMenuItem = UIMenuItem(title: "拷贝", action: #selector(tdataViewController.delMenuPress(menu:)))
        
        menu.menuItems = [item,copyItem]
        
        menu.setMenuVisible(true, animated: true)
        */
        return true
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        return false
    }
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            
            print("copy")
        }
    }
    @objc func delMenuPress(menu: UIMenuController) {
        
        print("删除成功")
        
        self.myTableView.reloadData()
    }
    
}
