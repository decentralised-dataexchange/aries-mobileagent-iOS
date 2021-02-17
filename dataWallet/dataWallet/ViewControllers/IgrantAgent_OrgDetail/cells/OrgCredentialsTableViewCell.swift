//
//  OrgCredentialsTableViewCell.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 26/12/20.
//

import UIKit

class OrgCredentialsTableViewCell: UITableViewCell {
    @IBOutlet weak var dataName: UILabel!
    @IBOutlet weak var dataVersion: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var addCredential: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
