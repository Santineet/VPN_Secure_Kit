//
//  VpnHeader.swift
//  Secure Kit VPN
//
//  Created by Luchik on 28.01.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit

class VpnHeader: UIView {
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var sectionArrow: UIImageView!
    
    public var onClick: (() -> Void)?
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        backgroundColor = .clear
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        backgroundColor = .clear
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
    }
    
    func xibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask =
            [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = .clear
        addSubview(view)
        contentView = view
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onSectionClicked)))
    }
    
    @objc private func onSectionClicked(){
        self.onClick!()
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "VpnHeader", bundle: bundle)
        return nib.instantiate(
            withOwner: self,
            options: nil).first as? UIView
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
    }
    
    var contentView: UIView?
}
