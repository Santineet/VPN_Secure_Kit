//
//  IAPProducts.swift
//  Secure Kit VPN
//
//  Created by Mairambek on 4/19/20.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation

enum IAPProducts: String {
    case LiteVPN = "litevpn.5"
    case StandardVPN = "standardvpn.2"
    case DoubleVPN = "doublevpn.3"
    case PerfectVPN = "perfectvpn.4"
    var title: String {
        switch self {
        case .LiteVPN:
            return "LiteVPN"
        case .StandardVPN:
            return "StandardVPN"
        case .DoubleVPN:
            return "DoubleVPN"
        case .PerfectVPN:
            return "PerfectVPN"
        }
    }
    var id: String {
        switch self {
        case .LiteVPN:
            return "5"
        case .StandardVPN:
            return "2"
        case .DoubleVPN:
            return "3"
        case .PerfectVPN:
            return "4"
        }
    }
}
