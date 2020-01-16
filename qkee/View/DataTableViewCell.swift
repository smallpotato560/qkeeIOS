//
//  DataTableViewCell.swift
//  qkee
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/8/26.
//  Copyright © 2019 Rooney. All rights reserved.
//

import UIKit

class DataTableViewCell: UITableViewCell {
    
    @IBOutlet var customView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var DateLabel: UILabel!
    var mid: Int!
    var vid: Int!
    var datatName: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
