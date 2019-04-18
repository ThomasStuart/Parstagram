//
//  CommentCell.swift
//  Parstagram
//
//  Created by Thomas James Stuart on 4/17/19.
//  Copyright © 2019 Thomas James Stuart. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
