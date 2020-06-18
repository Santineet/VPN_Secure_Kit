//
//  VpnCell.swift
//  Secure Kit VPN
//
//  Created by Luchik on 20.01.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import UIKit

class VpnCell: UITableViewCell {
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var vpnCountry: UILabel!
    @IBOutlet weak var star: UIImageView!
    
    private var vpn: VpnEntity?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @objc private func onRate(){
        DataManager.addToFavorite(vpn!)
        star.image = UIImage(named: vpn!.isFavorite() ? "star-filled" : "star")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        star.isUserInteractionEnabled = true
        star.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onRate)))
        // Configure the view for the selected state
    }
    
    public func initData(_ vpn: VpnEntity){
        self.vpn = vpn
        flag.image = UIImage(named: vpn.flag!)
        star.image = UIImage(named: vpn.isFavorite() ? "star-filled" : "star")
        vpnCountry.text = vpn.filteredName!
    }
    
    public func hideSeparator(){
        subviews.forEach { (view) in
            if type(of: view).description() == "_UITableViewCellSeparatorView" {
                view.isHidden = true
            }
        }
    }
    
    public func showSeparator(){
        subviews.forEach { (view) in
            if type(of: view).description() == "_UITableViewCellSeparatorView" {
                view.isHidden = false
            }
        }
    }
}
