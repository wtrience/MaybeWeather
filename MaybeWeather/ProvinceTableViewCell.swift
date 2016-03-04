//
//  ProvinceTableViewCell.swift
//  MaybeWeather
//
//  Created by wtrience on 15/12/5.
//  Copyright © 2015年 wtrience. All rights reserved.
//

import UIKit

class ProvinceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var provinceName: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
