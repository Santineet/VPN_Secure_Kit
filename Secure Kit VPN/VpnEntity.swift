//
//  VpnEntity.swift
//  Secure Kit VPN
//
//  Created by Luchik on 17.01.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

class VpnEntity: Codable, DefaultsSerializable{
    var user, group, name, ip, flag, ikev2: String?
    var filteredName: String?
    var credentials: VPNCredentials?
    
    init(_ xmlData: [String : String]){
        if let user = xmlData["user"]{
            self.user = user.base64Decoded()!
        }
        
        if let group = xmlData["group"]{
            self.group = group.base64Decoded()!
        }
        
        if let name = xmlData["name"]{
            self.name = name.base64Decoded()!
            self.filteredName = name.base64Decoded()!
        }
        
        if let ip = xmlData["ip"]{
            self.ip = ip.base64Decoded()!
        }
        
        if let flag = xmlData["flag"]{
            self.flag = flag.base64Decoded()!
        }
        
        if let ikev2 = xmlData["ikev2"]{
            self.ikev2 = ikev2.base64Decoded()!
        }
    }
    
    public func isFavorite() -> Bool{
        return DataManager.getFavoriteVpnList().filter({ $0.name! == self.name! }).count != 0
    }
    
    public func toString() -> String{
        return "VpnEntity{user=\(user),group=\(group), ip=\(ip), flag=\(flag), ikev2=\(ikev2), credentials={user=\(credentials?.user), pass=\(credentials?.pass), exp=\(credentials?.exp))}}"
    }
}
struct VPNCredentials: Codable, DefaultsSerializable {
    let user, pass: String
    let exp: Int64
    let tariff: String
}
