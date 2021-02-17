//
//  ExchangeDataPreviewTableViewCell.swift
//  AriesMobileAgent-iOS
//
//  Created by Mohamed Rebin on 16/12/20.
//

import UIKit

class ExchangeDataPreviewTableViewCell: UITableViewCell {

    @IBOutlet weak var attrValue: UILabel!
    @IBOutlet weak var attrName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
