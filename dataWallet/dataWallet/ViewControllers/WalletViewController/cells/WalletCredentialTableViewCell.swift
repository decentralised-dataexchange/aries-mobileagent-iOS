//
//  WalletCredentialTableViewCell.swift
//  Alamofire
//
//  Created by Mohamed Rebin on 10/12/20.
//

import UIKit

class WalletCredentialTableViewCell: UITableViewCell {

    @IBOutlet weak var certLogo: UIImageView!
    @IBOutlet weak var certName: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var baseCardView: UIView!
    @IBOutlet weak var stripView: UIView!
    @IBOutlet weak var orgName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.baseCardView.layer.cornerRadius = 20
        self.certLogo.layer.cornerRadius = 30
        self.baseCardView.backgroundColor = .white
//        self.stripView.backgroundColor = AriesMobileAgent.themeColor.withAlphaComponent(0.5).inverse()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
