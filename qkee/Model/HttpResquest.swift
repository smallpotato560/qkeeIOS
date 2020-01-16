//
//  HttpResquest.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/7/4.
//  Copyright © 2019 Rooney. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class HttpResquest{
    var result: JSON!
    var url: String
    var myProgress: UIProgressView
    
    init(url: String, progress: UIProgressView) {
        self.url = url;
        self.myProgress = progress;
    }
    
    func HttpGet(result: @escaping(_ result: JSON) -> ()) {
        Alamofire.request(url)
            .downloadProgress { progress in
                self.myProgress.isHidden = false
                //print("當前進度: \(progress.fractionCompleted)")

                self.myProgress.progress = Float(progress.fractionCompleted) / Float(1)
            }
            .responseJSON(completionHandler: { response in
                self.myProgress.isHidden = true
                if response.result.isSuccess {
                    let json: JSON = try! JSON(data: response.data!)
                    result(json)
                } else {
                    print("error: \(String(describing: response.error))")
                    let json: JSON = try! JSON(data: response.error as! Data)

                    result(json)
                }
            })
    }
    
    func HttpPost(result: @escaping(_ result: JSON) -> ()) {
        Alamofire.request(url, method: .post)
            .downloadProgress { progress in
                self.myProgress.isHidden = false
                //print("當前進度: \(progress.fractionCompleted)")

                self.myProgress.progress = Float(progress.fractionCompleted) / Float(1)
            }
            .responseJSON(completionHandler: { response in
                self.myProgress.isHidden = true
                if response.result.isSuccess {
                    let json: JSON = try! JSON(data: response.data!)
                    result(json)
                } else {
                    print("error: \(String(describing: response.error))")
                    let json: JSON = try! JSON(data: response.error as! Data)

                    result(json)
                }
            })
    }
}
