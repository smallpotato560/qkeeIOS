//
//  MeetData.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/9/9.
//  Copyright © 2019 Rooney. All rights reserved.
//

import Foundation

class MeetData {
    
    var name: String
    var date: String
    var mid: Int
    var vid: Int
    var dataName: String
    
    init(name: String, date: String, mid: Int, vid: Int, dataName: String) {
        self.name = name
        self.date = date
        self.mid = mid
        self.vid = vid
        self.dataName = dataName
    }
}
