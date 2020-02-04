//
//  CSLTagListCell.swift
//  CS108iOSClient
//
//  Created by Lam Ka Shun on 18/2/2019.
//  Copyright © 2019 Convergence Systems Limited. All rights reserved.
//

class CSLTagListCell: UITableViewCell {
    
    @IBOutlet weak var lbCellEPC: UILabel!
    @IBOutlet weak var lbCellBank: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
