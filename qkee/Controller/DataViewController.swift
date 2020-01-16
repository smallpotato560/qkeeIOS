//
//  DataViewController.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/8/24.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class DataViewController: UIViewController, UITableViewDataSource {

    // MARK: - Properties
    @IBOutlet var tableView: UITableView!
    @IBOutlet var myProgressView: UIProgressView!
    var refreshControl: UIRefreshControl!
    
    var datasource : JSON!
    var userid: Int32!
    var mobileNo: String!
    //var MeetDatalist: [MeetData] = [MeetData(name: "上班", date: "2019-10-21 08:05:22"),MeetData(name: "下班", date: "2019-10-21 17:00:05"),
    //MeetData(name: "上班", date: "2019-10-22 08:05:22"),MeetData(name: "下班", date: "2019-10-22 17:00:05")]
    var MeetDatalist: [MeetData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the table view
        tableView.dataSource = self
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
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
        tableView.refreshControl = refreshControl
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
                                        let dataName = data["dataName"].string!
                                
                                        self.MeetDatalist.append(MeetData(name: name, date: time, mid: mid, vid: vid, dataName: dataName))
                                    }
                                }
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
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
                })
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
        
        let cellIdentifier = "dataCell"
         
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DataTableViewCell
        else {
            return UITableViewCell()
        }
        if(self.MeetDatalist.count > 0) {
            
            cell.DateLabel.text = MeetDatalist[indexPath.row].date
            cell.nameLabel.text = MeetDatalist[indexPath.row].name
            cell.mid = MeetDatalist[indexPath.row].mid
            
        }
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.black.cgColor
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow!
        print(MeetDatalist[indexPath.row].name)

        if let controller = segue.destination as? WebViewController, let indexPath = self.tableView.indexPathForSelectedRow {
            controller.urlStr = MeetDatalist[indexPath.row].name
        }
        
        /*第二種傳值方法
         if let row = tableView.indexPathForSelectedRow?.row{
         controller?.name = season[row]
         }
         */
    }
    // 點選 cell 後執行的動作
    func tableView(tableView: UITableView,
                   didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        print("B")
        print(indexPath.row)
        if(self.MeetDatalist.count > 0) {
            
            _ = MeetDatalist[indexPath.row].date
            let name = MeetDatalist[indexPath.row].name

            print("選擇的是 \(name)")
            
        }
    }
}
