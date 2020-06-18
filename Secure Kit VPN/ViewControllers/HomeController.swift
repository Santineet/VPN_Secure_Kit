//
//  HomeController.swift
//  Secure Kit VPN
//
//  Created by Luchik on 18.01.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import Alertift
import SwiftyUserDefaults
import Localize_Swift
import SwiftDate

class HomeController: UIViewController, VPNManagerDelegate{
    @IBOutlet weak var vpnSubscriptionStack: UIStackView!
    @IBOutlet weak var vpnSubscriptionLabel: UILabel!
    @IBOutlet weak var chooseBtn: UIButton!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    let vpn = VPNManager.shared
    var policyState: Bool = false

    func VpnManagerConnectionFailed(error: VPNCollectionErrorType, localizedDescription: String) {
        print(localizedDescription)
    }
    
    func VpnManagerConnected() {
        self.progressView.status = .connected
        self.chooseStack.alpha = 0.0
        self.countryLabel.textColor = UIColor(rgb: 0x7ED321)
        self.powerView.image = UIImage(named: "PowerOff")
        self.shieldView.image = UIImage(named: "Shield2")
    }
    
    func VpnManagerDisconnected() {
        if self.progressView.status == .connecting{
            return
        }
        self.progressView.status = .disconnected
        self.chooseStack.alpha = 1.0
        self.countryLabel.textColor = UIColor(rgb: 0x4A4A4A)
        self.powerView.image = UIImage(named: "PowerOn")
        shieldView.image = UIImage(named: "Shield")
        print("VPN DISCONNECTED!")
    }
    
    func VpnManagerProfileSaved() {
        self.progressView.status = .connecting
        self.powerView.image = UIImage(named: "Power")
        self.countryLabel.textColor = UIColor(rgb: 0xFF9600)
        self.vpn.connect()
        self.chooseStack.alpha = 0.0
        print("VPN PROFILE SAVED!")

    }
    
    func VpnManagerProfileDeleted() {
        print("VPN PROFILE DELETED!")

    }
    
    @IBOutlet weak var powerView: UIImageView!
    @IBOutlet weak var shieldView: UIImageView!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var sitePaymentLabel: UILabel!
    
    private func requestSelectUser(){
        if !Defaults[\.privacyShown]{
            Defaults[\.privacyShown] = true
            let vc: PrivacyController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PrivacyController") as! PrivacyController
            vc.modalPresentationStyle = .fullScreen
            vc.dismissed = {
                self.requestSelectUser()
            }
            self.present(vc, animated: true, completion: nil)
            return
        }
        if Defaults[\.vpnList].count == 0 || Defaults[\.vpnUsers].count == 0{
            self.performSegue(withIdentifier: "SettingsSegue", sender: self)
            return
        }
        if Defaults[\.selectedVpnUser] != nil || Defaults[\.vpnUsers].count == 1 {
            updateBlockInfo()
            return
        }
            let sheet = Alertift.actionSheet(title: "Select login vpn".localized(), message: nil)
            for user in Defaults[\.vpnUsers]{
                sheet.action(.default(user.user)){
                    Defaults[\.selectedVpnUser] = user
                    self.updateBlockInfo()
                }
            }
            sheet.show(on: self, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavBarImage()
        requestSelectUser()
        sitePaymentLabel.text = "On the site we accept payments through various payment systems, including Bitcoin, PayPal, Yandex Money and others.".localized()
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        self.vpn.delegate = self
        self.chooseBtn.addTarget(self, action: #selector(self.onDisableImage), for: [.touchDown])
        self.chooseBtn.addTarget(self, action: #selector(self.onEnableImage), for: [.touchDragExit, .touchUpInside, .touchUpOutside, .touchCancel])
        //self.chooseBtn.addTarget(self, action: .pressed, forControlEvents: [.touchDown])
       // self.chooseBtn.addTarget(self, action: "released", forControlEvents: [.touchDragExit, .touchUpInside, .touchUpOutside, .touchCancel])
        policyStateValue()
    }
    
    @objc private func onDisableImage(){
        locationImage.alpha = 0.3
    }
    
    @objc private func onEnableImage(){
        locationImage.alpha = 1.0
    }
    
    @IBAction func onExit(_ sender: Any) {
        self.performSegue(withIdentifier: "SettingsSegue", sender: self)
    }
    
    @objc func didBecomeActive() {
        DataManager.auth(){
            success in
            self.requestSelectUser()
            self.updateBlockInfo()
            print("Vpns: \(Defaults[\.vpnList].count)")
        }
        print("did become active")
    }
    @IBAction func onRenew(_ sender: Any) {
        DataManager.buy(Defaults[\.selectedVpnUser]!.user){
            url in
            UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
        }
    }
    
    private func updateBlockInfo(){
        if Defaults[\.selectedVpnUser] == nil{
            return
        }
        vpnSubscriptionLabel.text = "VPN subscription expires".localized() + ": \(Date(milliseconds: Defaults[\.selectedVpnUser]!.exp).toFormat("dd.MM.yyyy"))"
        print(TimeInterval(Defaults[\.selectedVpnUser]!.exp) - Date().timeIntervalSince1970)
        vpnSubscriptionStack.isHidden = TimeInterval(Defaults[\.selectedVpnUser]!.exp) - Date().timeIntervalSince1970 > 7 * 24 * 60 * 60
    }

    @objc func willEnterForeground() {
        print("will enter foreground")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("My policy state is \(String(describing: policyState))")
        print("Status - \(self.vpn.status.rawValue)")
        self.countryLabel.isHidden = Defaults[\.lastVpn] == nil
        let vpnConnection = DataManager.getLastVpn()
        if vpnConnection != nil{
            countryLabel.text = vpnConnection!.name!
        }
        if self.vpn.status == .connected{
            self.chooseStack.alpha = 0.0
            self.progressView.status = .connected
        }
        else if self.vpn.status == .connecting{
            self.progressView.status = .connecting
        }
        else{
            self.chooseStack.alpha = 1.0
            self.progressView.status = .disconnected
        }
        progressView.onClick = {
            self.isConnectedToNetwork(){success in
                if success{
                    if vpnConnection != nil {
                        if self.policyState {
                            self.showAlert()
                        } else {
                            self.onProgressClick()
                            }
                        } else {
                            self.onVpnList(self)
                        }
                }
                else {
                    Alertift.alert(title: "Error!".localized(), message: "No internet access".localized())
                        .action(.default("Ok".localized()))
                        .show(on: self, completion: nil)
                }
            }
        }
        self.vpn.addObserver()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.vpn.removeObserver()

    }
    
    private func showAlert() {
        
        Alertift.alert(title: "", message: "By starting VPN you agree with Privacy policy".localized())
            .action(.default("Yes".localized())){
                self.policyState = false
                UserDefaults.standard.set(true, forKey: "policyState")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.onProgressClick()
                }
        }
            .action(.cancel("No".localized()))
            .show(on: self, completion: nil)
    }

    
    func policyStateValue() {
        
        let state = UserDefaults.standard.bool(forKey: "policyState")
                 if !state {
                  policyState = true
              } else {
                  policyState = false
              }
    }

    
    private func onProgressClick(){
        let vpnConnection: VpnEntity = DataManager.getLastVpn()!

        //Create your VPN Account and configurations
        var vpnAccount = VPNAccount(id: "", type: VPNProtocolType.IKEv2, title: vpnConnection.name!, server: vpnConnection.ip!, account: vpnConnection.credentials!.user, groupName: vpnConnection.group! == "1" ? "Standard VPN" : "Double VPN", remoteId: vpnConnection.ikev2!, alwaysOn: true)
        KeychainService().save(key: "vpnPassword", value: vpnConnection.credentials!.pass)
        vpnAccount.passwordRef = KeychainService().load(key: "vpnPassword")
        if self.vpn.status == .connected || self.vpn.status == .connecting{
            self.countryLabel.textColor = UIColor(rgb: 0x4A4A4A)
            self.vpn.disconnect()
            self.progressView.status = .disconnected
            self.chooseStack.alpha = 1.0
            self.powerView.image = UIImage(named: "PowerOn")
            self.shieldView.image = UIImage(named: "Shield")
            print("Start disconnecting")
        }
        else{
            self.vpn.save(vpnAccount)
            self.countryLabel.textColor = UIColor(rgb: 0xFF9600)
            print("Start connecting")
        }
    }
    
    @IBAction func onVpnList(_ sender: Any) {
        if Defaults[\.vpnList].count != 0{
            self.performSegue(withIdentifier: "VPNListSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "VPNListSegue"{
            if let vc = segue.destination as? VPNListController{
                vc.didSelectVpn = {
                    if self.policyState {
                        self.showAlert()
                    } else {
                       self.onProgressClick()
                    }
                }
            }
        }
    }
    func addNavBarImage() {
        let titleLbl = UILabel()
        titleLbl.text = "Secure Kit"
        titleLbl.textColor = UIColor.white
        titleLbl.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        let imageView = UIImageView(image: UIImage(named: "Eye"))
        let titleView = UIStackView(arrangedSubviews: [imageView, titleLbl])
        titleView.axis = .horizontal
        titleView.spacing = 5.0
        titleView.alignment = .center
        navigationItem.titleView = titleView
    }
    @IBOutlet weak var chooseStack: UIStackView!
}
