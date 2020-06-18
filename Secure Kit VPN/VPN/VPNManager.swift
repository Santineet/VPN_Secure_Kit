//
//  VPNManager.swift
//  Secure Kit VPN
//
//  Created by Luchik on 18.01.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import NetworkExtension

public class VPNManager {
    public var delegate : VPNManagerDelegate?
    
    private var manager: NEVPNManager {
        return NEVPNManager.shared()
    }
    
    
    public static var shared = VPNManager()
    
    public var status: NEVPNStatus {
        return manager.connection.status
    }
    
    public init(){
        self.manager.loadFromPreferences(completionHandler: {_ in
            print("Status VPN - \(self.manager.connection.status.rawValue)")
        })
        NotificationCenter.default.addObserver(self, selector: #selector(self.onUpdateVpnStatus(_:)), name: .NEVPNStatusDidChange, object: nil)
    }

    @objc private func onUpdateVpnStatus(_ notification: NSNotification){
        let nevpnconn = notification.object as! NEVPNConnection
        let status = nevpnconn.status
        if delegate == nil{
            return
        }
         if status == .disconnected{
             self.delegate!.VpnManagerDisconnected()
         }
         else if status == .connected{
             self.delegate!.VpnManagerConnected()
         }
    }
    
    public func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.onUpdateVpnStatus(_:)), name: .NEVPNStatusDidChange, object: nil)
    }
    
    public func removeObserver(){
        NotificationCenter.default.removeObserver(self, name: .NEVPNStatusDidChange, object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: .NEVPNStatusDidChange, object: nil)
    }
        
    public func save(_ account: VPNAccount) {
        print("Saving!")
        manager.loadFromPreferences(completionHandler: { error in
            self.save(account, saveAndConnect: false)
        })
    }
    
    public func saveAndConnect(_ account: VPNAccount) {
        manager.loadFromPreferences { error in
            if(error != nil){
                self.save(account, saveAndConnect: true)
            }else{
                self.connect()
            }
        }
    }
    
    public func removePreferences(){
        manager.removeFromPreferences{
            error in
            print(error)
        }
    }
    
    private func save(_ account: VPNAccount , saveAndConnect : Bool) {
        var nevProtocol: NEVPNProtocol
        
        if account.type == .IPSec {
            let p = NEVPNProtocolIPSec()
            p.useExtendedAuthentication = true
            p.localIdentifier = account.groupName ?? "VPNTest"
            p.remoteIdentifier = account.remoteID
            if let secret = account.secretRef {
                p.authenticationMethod = .sharedSecret
                p.sharedSecretReference = secret
            } else {
                p.authenticationMethod = .none
            }
            nevProtocol = p
        } else {
            let p = NEVPNProtocolIKEv2()
            p.useExtendedAuthentication = true
            p.localIdentifier = account.groupName ?? "VPNTest"
            p.remoteIdentifier = account.remoteID
            if let secret = account.secretRef {
                p.authenticationMethod = .none
                p.sharedSecretReference = secret
            } else {
                p.authenticationMethod = .none
            }
            p.deadPeerDetectionRate = NEVPNIKEv2DeadPeerDetectionRate.medium
            p.ikeSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256
            p.ikeSecurityAssociationParameters.integrityAlgorithm = .SHA384
            p.childSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256
            p.childSecurityAssociationParameters.integrityAlgorithm = .SHA384
            nevProtocol = p
        }
        
        nevProtocol.disconnectOnSleep = !account.alwaysOn
        nevProtocol.serverAddress = account.server
        
        if let username = account.account {
            nevProtocol.username = username
        }
        
        if let password = account.passwordRef {
            nevProtocol.passwordReference = password
        }
        
        print("\(nevProtocol.passwordReference) - username")
        manager.localizedDescription = account.groupName
        manager.protocolConfiguration = nevProtocol
        manager.isEnabled = true
        
        configOnDemand()
        
        manager.saveToPreferences { error in
            if let err = error {
                self.delegate?.VpnManagerConnectionFailed(error: VPNCollectionErrorType.UnkownError, localizedDescription: "Failed to save profile: \(err.localizedDescription)")
            } else {
                if(saveAndConnect){
                    self.delegate?.VpnManagerProfileSaved()
                    self.connect()
                }else{
                    self.delegate?.VpnManagerProfileSaved()
                }
            }
        }
    }
    
    public func connect() {
        manager.loadFromPreferences { error in
            print(error?.localizedDescription)
            do {
                try self.manager.connection.startVPNTunnel()
                //self.delegate?.VpnManagerConnected()
            } catch NEVPNError.configurationInvalid {
                //self.delegate?.VpnManagerConnectionFailed(error: VPNCollectionErrorType.ConfigurationInvalid, localizedDescription: "Configuration Invalid")
            } catch NEVPNError.configurationDisabled {
                //self.delegate?.VpnManagerConnectionFailed(error: VPNCollectionErrorType.ConfigurationDisabled, localizedDescription: "Configuration Disabled")
            } catch let error as NSError {
                NotificationCenter.default.post(
                    name: NSNotification.Name.NEVPNStatusDidChange,
                    object: nil
                )
                //self.delegate?.VpnManagerConnectionFailed(error: VPNCollectionErrorType.UnkownError, localizedDescription: error.localizedDescription)
            }
        }
    }
    
    public func configOnDemand() {
        manager.onDemandRules = [NEOnDemandRule]()
        manager.isOnDemandEnabled = false
    }
    
    public func disconnect() {
        manager.connection.stopVPNTunnel()
        //self.delegate?.VpnManagerDisconnected()
    }
    
    public func removeProfile() {
        // The first removing disable on demand feature of the VPN
        manager.removeFromPreferences { _ in
            // This one actually remove the VPN profile
            self.manager.removeFromPreferences { _ in
                self.delegate?.VpnManagerProfileDeleted()
            }
        }
    }
}
public protocol VPNManagerDelegate {
    func VpnManagerConnectionFailed(error : VPNCollectionErrorType , localizedDescription : String)
    func VpnManagerConnected()
    func VpnManagerDisconnected()
    func VpnManagerProfileSaved()
    func VpnManagerProfileDeleted()
}
public struct VPNAccount {
    public var ID: String = ""
    public var type: VPNProtocolType = .IPSec
    public var title: String = ""
    public var server: String = ""
    public var account: String?
    public var groupName: String?
    public var remoteID: String?
    public var alwaysOn = true
    public var passwordRef: Data?
    public var secretRef: Data?
    
    
    public init(id : String , type : VPNProtocolType,title : String,server : String , account : String , groupName : String , remoteId : String , alwaysOn : Bool){
        self.ID = id
        self.type = type
        self.title = title
        self.server = server
        self.account = account
        self.groupName = groupName
        self.remoteID = remoteId
        self.alwaysOn = alwaysOn
    }
}
public enum VPNCollectionErrorType {
    case ConfigurationInvalid
    case ConfigurationDisabled
    case UnkownError
}
public enum VPNProtocolType {
    case IPSec
    case IKEv2
}
