//
//  HttpServer.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/7/5.
//  Copyright © 2019 Rooney. All rights reserved.
//

import Foundation

class HttpServer {

    static var ServerAddress = "http://www.qkee.com.tw/"
    static var LoginURL = ServerAddress + "Login.aspx"
    
    static var AddCustomerInfoURL = ServerAddress + "AddCustomerInfo.aspx"
    static var PuchVerCodeURL = ServerAddress + "PushVerCode.aspx"
    static var CheckedVerCodeURL = ServerAddress + "CheckedVerCode.aspx"
    static var CheckedAccountURL = ServerAddress + "CheckedAccount.aspx"
    static var GetCustomerInfoURL = ServerAddress + "GetCustomerInfo.aspx"
    static var GetUserDataListURL = ServerAddress + "GetUserDataList.aspx"
    static var GetUserDataDetailURL = ServerAddress + "GetUserDataDetail.aspx"
    static var PrivacyURL = ServerAddress + "Privacy.aspx"
    static var ActivityURL = ServerAddress + "Activity.aspx"
    static var SetDeviceTokenURL = ServerAddress + "SetDeviceToken.aspx"
}
