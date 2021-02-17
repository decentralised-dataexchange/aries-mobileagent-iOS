//
//  CertificateWithDataTableViewCell.swift
//  dataWallet
//
//  Created by Mohamed Rebin on 22/01/21.
//

import UIKit

class CertificateWithDataTableViewCell: UITableViewCell,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var certName: UILabel!
    var certData: [SearchCertificateAttribute] = [] {
        didSet {
            certAttributeTableView.reloadData()
        }
    }
    @IBOutlet weak var certAttributeTableView: AGTableView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var addButton: UIButton!
    var showValues = true

    override func awakeFromNib() {
        super.awakeFromNib()
        certAttributeTableView.delegate = self
        certAttributeTableView.dataSource = self
        baseView.layer.cornerRadius = 20
        certAttributeTableView.estimatedRowHeight(40)
        certAttributeTableView.rowHeight = UITableView.automaticDimension;
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        UIView.performWithoutAnimation {
           self.superTableView?.beginUpdates()
            self.layoutIfNeeded()
           self.superTableView?.endUpdates()
        }
    }
    
    override func layoutSubviews() {
           super.layoutSubviews()
           self.certAttributeTableView.layoutSubviews()
       
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.contentView.layoutIfNeeded()
        self.contentView.updateConstraints()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return certData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ExchangeDataPreviewTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "ExchangeDataPreviewTableViewCell") as? ExchangeDataPreviewTableViewCell
        let attribute = certData[indexPath.row]
        cell?.attrName.text = attribute.name ?? ""
        if showValues {
            cell?.attrValue.isHidden = false
            cell?.attrValue.text = attribute.value ?? ""
        } else {
            cell?.attrValue.isHidden = true
        }
        if indexPath.row == (tableView.numberOfRows(inSection: indexPath.section) - 1) {
            cell?.separatorInset = UIEdgeInsets(top: 0, left: cell?.bounds.size.width ?? 0, bottom: 0, right: 0)
        }
        cell?.selectionStyle = .none
        return cell ?? ExchangeDataPreviewTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}


class MyOwnTableView: UITableView {
   override var intrinsicContentSize: CGSize {
       self.layoutIfNeeded()
       return self.contentSize
   }

   override var contentSize: CGSize {
       didSet{
           self.invalidateIntrinsicContentSize()
       }
   }

   override func reloadData() {
       super.reloadData()
       self.invalidateIntrinsicContentSize()
   }
}

