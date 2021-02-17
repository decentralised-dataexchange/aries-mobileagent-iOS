//
//  NotificationTableViewCell.swift
//  dataWallet
//
//  Created by Mohamed Rebin on 19/01/21.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var notificationType: UILabel!
    @IBOutlet weak var certName: UILabel!
    @IBOutlet weak var orgImage: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        orgImage.layer.cornerRadius = 35
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
