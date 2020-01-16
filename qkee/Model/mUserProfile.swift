//
//  mUserProfile.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/7/4.
//  Copyright © 2019 Rooney. All rights reserved.
//

import Foundation

class mUserProfile {

    var userID: Int
    var nickName: String
    var userName: String
    var mobileNum: String
    var email: String
    var email2: String?
    var email3: String?
    var lineID: String?
    var skypeID: String?
    var wechatID: String?
    var facebookID: String?
    var instagramID: String?
    var address: String
    var locationAddress: String?
    var gender: Int
    var locationAddressResult: String?
    var DeviceID: String
    
    init(userID:Int, nickName: String, userName: String, mobileNum: String, email: String, address: String, gender: Int = -1, DeviceID: String = "") {
        self.userID = userID
        self.nickName = nickName
        self.userName = userName
        self.mobileNum = mobileNum
        self.email = email
        self.address = address
        self.gender = gender
        self.DeviceID = DeviceID
    }
    
    convenience init() {
        self.init(userID: 0, nickName: "", userName: "", mobileNum: "", email: "", address: "")
    }
}
