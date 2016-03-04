
//
//  ListTableViewCell.swift
//  MaybeWeather
//
//  Created by wtrience on 15/12/3.
//  Copyright © 2015年 wtrience. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    //MARK:Property
    
    @IBOutlet weak var areaName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
