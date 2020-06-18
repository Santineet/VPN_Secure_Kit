//
//  DataManager.swift
//  Secure Kit VPN
//
//  Created by Luchik on 17.01.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyXMLParser
import SwiftyUserDefaults

class DataManager{
    public static let API_URL = "https://msftnsci.com/"
    
    public static func register(email: String, password: String, handler: @escaping ((_ success: Bool, _ text: String) -> Void)){
        AF.request(URL(string: API_URL + "connect?ver=\(getAppVersion())&os=ios&email=\(email)&pass=\(password)&id=\(KeychainService().getUUID()!)&act=reg")!, method: .post).responseString(completionHandler: {
            response in
            let value = response.value!
            if value.contains("email-exist".base64Encoded()!){
                handler(false, "Such email already exist")
            }
            else if value.contains("forbidden-symbols".base64Encoded()!){
                handler(false, "Remove forbidden symbols")
            } else {
                let xml = try! XML.parse(response.value!)
                if let freevpn = xml["root", "freevpn"].text, freevpn.base64Decoded()! == "true"{
                    handler(true, "freevpn")
                }
                else{
                    handler(true, "")
                }
            }
            print(response.value!)
        })
    }
    
    public static func buy(_ loginVpn: String, handler: @escaping ((_ url: String) -> Void)){
        AF.request(URL(string: API_URL + "connect?ver=\(getAppVersion())&loginvpn=\(loginVpn)&os=ios&login=\(Defaults[\.userCredentials]!.login)&pass=\(Defaults[\.userCredentials]!.password)&act=buy")!, method: .post).responseString(completionHandler: {
            response in
            let xml = try! XML.parse(response.value!)
            if let url = xml["root", "link"].text {
                handler(url.base64Decoded()!)
            }
        })
    }
    
    public static func buySubscription(_ receipt: String, secretKey: String, handler: @escaping ((_ success: Bool) -> Void)) {
        let login = Defaults[\.userCredentials]!.login
        let password = Defaults[\.userCredentials]!.password
        guard var urlComponets = URLComponents(string: API_URL + "connect") else { return }
        urlComponets.queryItems = [
            URLQueryItem(name: "ver", value: getAppVersion()),
            URLQueryItem(name: "os", value: "ios"),
            URLQueryItem(name: "login", value: login),
            URLQueryItem(name: "pass", value: password),
            URLQueryItem(name: "act", value: "inappbuyvpn")
        ]
        guard let url = urlComponets.url else { return }
        print(url)
        
        let params: Parameters = ["receipt": receipt, "secretkey": secretKey]
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        AF.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseString (completionHandler: {
            response in
            guard let value = response.value else { return }
            let xml = try! XML.parse(value)
            if let auth = xml["root", "auth"].text, auth.base64Decoded()! == "true"{
                handler(true)
            } else {
                handler(false)
            }
        })
    }
    
    public static func renewSubscription(_ receipt: String, secretKey: String, handler: @escaping ((_ success: Bool) -> Void)) {
        let login = Defaults[\.userCredentials]!.login
        let password = Defaults[\.userCredentials]!.password
        guard var urlComponets = URLComponents(string: API_URL + "connect") else { return }
        let loginVPN = Defaults[\.selectedVpnUser]!.user
        print(loginVPN)
        urlComponets.queryItems = [
            URLQueryItem(name: "ver", value: getAppVersion()),
            URLQueryItem(name: "os", value: "ios"),
            URLQueryItem(name: "login", value: login),
            URLQueryItem(name: "pass", value: password),
            URLQueryItem(name: "act", value: "inappbuyvpn"),
            URLQueryItem(name: "loginvpn", value: "\(loginVPN)")
        ]
        
        guard let url = urlComponets.url else { return }
        let params: Parameters = ["receipt": receipt, "secretkey": secretKey]
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        AF.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseString (completionHandler: {
            response in
            guard let value = response.value else { return }
            print(value)
            let xml = try! XML.parse(value)
            if let transaction = xml["root", "transaction"].text,
                   transaction.base64Decoded()! == "true" {
                handler(true)
            } else {
                handler(false)
            }
        })
    }
    
    public static func auth(handler: @escaping ((_ success: Bool) -> Void)){
        if Defaults[\.userCredentials] == nil{
            return
        }
        let login = Defaults[\.userCredentials]!.login
        let password = Defaults[\.userCredentials]!.password
        AF.request(URL(string: API_URL + "connect?ver=\(getAppVersion())&os=ios&login=\(login)&pass=\(password)&act=wizardsetup")!, method: .post).responseString(completionHandler: {
            response in
            print(response.value as Any)
            
            guard let value = response.value else { return }
            let xml = try! XML.parse(value)
            var vpnList: [VpnEntity] = []
            if let auth = xml["root", "auth"].text, auth.base64Decoded()! == "true" {
                var credentials: [VPNCredentials] = []
                for file in xml["root", "file"] {
                    credentials.append(VPNCredentials(
                        user: file.attributes["user"]!.base64Decoded()!,
                        pass: file.attributes["pass"]!.base64Decoded()!,
                        exp: Int64(file.attributes["exp"]!.base64Decoded()!)!,
                        tariff: file.attributes["tariff"]!.base64Decoded()!
                    ))
                }

                Defaults[\.vpnUsers] = credentials
                if credentials.count == 1 {
                    Defaults[\.selectedVpnUser] = credentials[0]
                } else {
                    let selectedVpnUser = Defaults[\.selectedVpnUser]
                    if let updatedVpnUser = credentials.first(where: { $0.user == selectedVpnUser?.user }) {
                        Defaults[\.selectedVpnUser] = updatedVpnUser
                    }
                }
                
                for vpn in xml["root", "vpn"] {
                    let vpnEntity = VpnEntity(vpn.attributes)
                    vpnEntity.credentials = credentials.filter({ $0.user == vpnEntity.user! })[0]
                    vpnList.append(vpnEntity)
                    print(vpnEntity.toString())
                }
                Defaults[\.vpnList] = vpnList
                handler(true)
            }
            else{
                handler(false)
            }
        })
    }
    
    public static func auth(login: String, password: String, handler: @escaping ((_ success: Bool) -> Void)){
        AF.request(URL(string: API_URL + "connect?ver=\(getAppVersion())&os=ios&login=\(login)&pass=\(password)&act=wizardsetup")!, method: .post).responseString(completionHandler: {
            response in
            guard let value = response.value else { return }
            let xml = try! XML.parse(value)
            var vpnList: [VpnEntity] = []
            if let auth = xml["root", "auth"].text, auth.base64Decoded()! == "true" {
                Defaults[\.userCredentials] = UserCredentials(login: login,
                                                              password: password)
                var credentials: [VPNCredentials] = []
                for file in xml["root", "file"] {
                    credentials.append(VPNCredentials(
                        user: file.attributes["user"]!.base64Decoded()!,
                        pass: file.attributes["pass"]!.base64Decoded()!,
                        exp: Int64(file.attributes["exp"]!.base64Decoded()!)!,
                        tariff: file.attributes["tariff"]!.base64Decoded()!))
                }
                Defaults[\.vpnUsers] = credentials
                if credentials.count == 1 {
                    Defaults[\.selectedVpnUser] = credentials[0]
                }
                for vpn in xml["root", "vpn"] {
                    let vpnEntity = VpnEntity(vpn.attributes)
                    vpnEntity.credentials = credentials.filter({ $0.user == vpnEntity.user! })[0]
                    vpnList.append(vpnEntity)
                    print(vpnEntity.toString())
                }
                Defaults[\.vpnList] = vpnList
                handler(true)
            }
            else{
                handler(false)
            }
        })
    }
        
    public static func getLastVpn() -> VpnEntity?{
        return Defaults[\.lastVpn]
    }
    
    public static func saveLastVpn(_ lastVpn: VpnEntity){
        Defaults[\.lastVpn] = lastVpn
    }
    
    public static func getVpnList() -> [VpnEntity]{
        return Defaults[\.vpnList].filter({ $0.credentials!.user == Defaults[\.selectedVpnUser]!.user })
    }
    
    public static func getFavoriteVpnList() -> [VpnEntity]{
        return Defaults[\.vpnFavoriteList]
    }
    
    public static func addToFavorite(_ vpn: VpnEntity){
        if !vpn.isFavorite(){
            Defaults[\.vpnFavoriteList].append(vpn)
        }
        else{
            Defaults[\.vpnFavoriteList] = Defaults[\.vpnFavoriteList].filter({ $0.name! != vpn.name! })
        }
    }
    
    private static func getAppVersion() -> String{
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
}
