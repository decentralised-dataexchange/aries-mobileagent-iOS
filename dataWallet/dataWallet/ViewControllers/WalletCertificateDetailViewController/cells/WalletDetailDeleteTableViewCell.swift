//
//  WalletDetailDeleteTableViewCell.swift
//  dataWallet
//
//  Created by Mohamed Rebin on 22/01/21.
//

import UIKit

class WalletDetailDeleteTableViewCell: UITableViewCell {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        baseView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
