//
//  String.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/8/24.
//  Copyright © 2019 Rooney. All rights reserved.
//

import Foundation

extension String {
    
    //MARK: 返回第一次出现的指定子字符串在此字符串中的索引
    //（如果backwards参数设置为true，则返回最后出现的位置）
    func positionOf(sub:String, backwards:Bool = false)->Int {
        var pos = -1
        if let range = range(of:sub, options: backwards ? .backwards : .caseInsensitive, range:nil, locale:nil) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
    
    func backurl(url: String) -> String {
        var urlStr: String!
        
        let infexof = url.positionOf(sub: "?")
        if (infexof >= 0) {
            urlStr = url + "&"
        }
        else {
            urlStr = url + "?"
        }
        return urlStr
    }
}
