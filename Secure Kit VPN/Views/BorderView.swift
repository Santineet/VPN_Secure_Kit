//
//  BorderView.swift
//  Secure Kit VPN
//
//  Created by Luchik on 17.01.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class BorderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        applyStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        applyStyle()
    }
    
    private func applyStyle() {
        layer.borderColor = UIColor(rgb: 0x47A6D9).cgColor
        layer.borderWidth = 1.5
        layer.cornerRadius = 5.0
    }

}
