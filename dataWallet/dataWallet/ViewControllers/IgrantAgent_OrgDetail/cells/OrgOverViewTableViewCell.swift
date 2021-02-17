
//
//  OrgOverViewTableViewCell.swift
//  iGrant
//
//  Created by Ajeesh T S on 25/03/18.
//  Copyright © 2018 iGrant.com. All rights reserved.
//

import UIKit

class OrgOverViewTableViewCell: UITableViewCell {
    @IBOutlet weak var overViewLbl: ExpandableLabel!
    @IBOutlet weak var dataHeader: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
//        overViewLbl.collapsedAttributedLink = NSAttributedString(string: ")
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "Read More")
        let colorRange = NSMakeRange(0,"Read More".count)
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red:0.59, green:0.59, blue:0.61, alpha:1), range:colorRange)
        overViewLbl.collapsedAttributedLink = attributeString
        
        let readLessattributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "Read Less")
        let colorRangeReadLess = NSMakeRange(0,"Read Less".count)
        readLessattributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red:1, green:0.53, blue:0.54, alpha:1), range:colorRangeReadLess)

        overViewLbl.expandedAttributedLink = readLessattributeString

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
