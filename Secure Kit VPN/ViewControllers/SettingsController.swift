//
//  SettingsController.swift
//  Secure Kit VPN
//
//  Created by Luchik on 05.02.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import QuickTableViewController
import Alertift
import SwiftyUserDefaults
import SwiftDate
import PKHUD

class SettingsController: QuickTableViewController{
    
    private var productName: String {
        let product = getProductFromId(id: Defaults[\.selectedVpnUser]!.tariff)
        return "\(product.title)"
    }
    
    private func reloadData(){
        self.navigationItem.hidesBackButton = Defaults[\.vpnList].count == 0 || Defaults[\.vpnUsers].count == 0
        if Defaults[\.selectedVpnUser] == nil{
            tableContents = [
                Section(title: "", rows: [
                    NavigationRow(text: "Lite VPN", detailText: .value1("$19/" + "Month".localized()), action: { _ in
                        self.buyVPN(.LiteVPN)
                    }),
                    NavigationRow(text: "Standard VPN", detailText: .value1("$39/" + "Month".localized()), action: { _ in
                        self.buyVPN(.StandardVPN)
                    }),
                    NavigationRow(text: "Double VPN", detailText: .value1("$49/" + "Month".localized()), action: { _ in
                        self.buyVPN(.DoubleVPN)
                    }),
                    NavigationRow(text: "Perfect VPN", detailText: .value1("$59/" + "Month".localized()), action: { _ in
                        self.buyVPN(.PerfectVPN)
                    }),
                ]),
                Section(title: "", rows: [
                    TapActionRow(text: "Sign out".localized(), customization: { cell, _ in
                        cell.textLabel?.textColor = .red
                    }, action: { _ in
                        Alertift.alert(title: "Logout".localized(), message: "Do you really want to leave?".localized())
                            .action(.default("Yes".localized())){
                                Defaults[\.isAuthorized] = false
                                Defaults[\.vpnFavoriteList] = []
                                Defaults[\.lastVpn] = nil
                                Defaults[\.userCredentials] = nil
                                Defaults[\.vpnUsers] = []
                                Defaults[\.selectedVpnUser] = nil
                                Defaults[\.privacyShown] = false
                                UserDefaults.standard.set(false, forKey: "policyState")
                                VPNManager.shared.removeProfile()
                                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthController")
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true, completion: nil)
                        }
                        .action(.cancel("No".localized())){
                            self.reloadData()
                        }
                        .show(on: self, completion: nil)
                    })
                ])
            ]
            return
        }
        if Defaults[\.vpnUsers].count > 1 {
            tableContents = [
                Section(title: "", rows: [
                    NavigationRow(text: "Login VPN".localized(), detailText: .value1(Defaults[\.selectedVpnUser]!.user), icon: nil, action: { _ in
                        let sheet = Alertift.actionSheet(title: "Select login vpn".localized(), message: nil)
                        for user in Defaults[\.vpnUsers]{
                            sheet.action(.default(user.user)){
                                Defaults[\.selectedVpnUser] = user
                                self.reloadData()
                            }
                        }
                        sheet.action(.cancel("Cancel".localized()))
                        sheet.show(on: self, completion: nil)
                    }),
                    NavigationRow(text: "VPN subscription expires".localized() + ": \(Date(milliseconds: Defaults[\.selectedVpnUser]!.exp).toFormat("dd.MM.yyyy"))", detailText: .none, icon: nil),
                    NavigationRow(text: "Renew subscription".localized() , detailText: .value1(productName), action: { _ in
                        HUD.show(.progress)
                        let product = self.getProductFromId(id: Defaults[\.selectedVpnUser]!.tariff)
                        IAPManager.shared.purchase(productWith: product.rawValue, isRenewed: true)
                    })
                ]),
                Section(title: "", rows: [
                    NavigationRow(text: "Lite VPN", detailText: .value1("$19/" + "Month".localized()), action: { _ in
                        self.buyVPN(.LiteVPN)
                    }),
                    NavigationRow(text: "Standard VPN", detailText: .value1("$39/" + "Month".localized()), action: { _ in
                        self.buyVPN(.StandardVPN)
                    }),
                    NavigationRow(text: "Double VPN", detailText: .value1("$49/" + "Month".localized()), action: { _ in
                        self.buyVPN(.DoubleVPN)
                    }),
                    NavigationRow(text: "Perfect VPN", detailText: .value1("$59/" + "Month".localized()), action: { _ in
                        self.buyVPN(.PerfectVPN)
                    })
                ]),
                Section(title: "", rows: [
                    TapActionRow(text: "Sign out".localized(), customization: { cell, _ in
                        cell.textLabel?.textColor = .red
                    }, action: { _ in
                        Alertift.alert(title: "Logout".localized(), message: "Do you really want to leave?".localized())
                            .action(.default("Yes".localized())){
                                Defaults[\.isAuthorized] = false
                                Defaults[\.vpnFavoriteList] = []
                                Defaults[\.lastVpn] = nil
                                Defaults[\.userCredentials] = nil
                                Defaults[\.vpnUsers] = []
                                Defaults[\.selectedVpnUser] = nil
                                Defaults[\.privacyShown] = false
                                UserDefaults.standard.set(false, forKey: "policyState")
                                VPNManager.shared.removeProfile()
                                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthController")
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true, completion: nil)
                        }
                        .action(.cancel("No".localized())){
                            self.reloadData()
                        }
                        .show(on: self, completion: nil)
                    })
                ])
            ]
        } else{
            tableContents = [
                Section(title: "", rows: [
                    NavigationRow(text: "VPN subscription expires".localized() + ": \(Date(milliseconds: Defaults[\.selectedVpnUser]!.exp).toFormat("dd.MM.yyyy"))", detailText: .none, icon: nil),
                    NavigationRow(text: "Renew subscription", detailText: .value1(Defaults[\.selectedVpnUser]!.tariff), action: { _ in
                        self.buyVPN(.StandardVPN)
                    })
                ]),
                Section(title: "", rows: [
                    NavigationRow(text: "Lite VPN", detailText: .value1(getProductPrice(.LiteVPN) ), action: { _ in
                        self.buyVPN(.LiteVPN)
                    }),
                    NavigationRow(text: "Standard VPN", detailText: .value1(getProductPrice(.StandardVPN)), action: { _ in
                        self.buyVPN(.StandardVPN)
                    }),
                    NavigationRow(text: "Double VPN", detailText: .value1(getProductPrice(.DoubleVPN)), action: { _ in
                        self.buyVPN(.DoubleVPN)
                    }),
                    NavigationRow(text: "Perfect VPN", detailText: .value1(getProductPrice(.PerfectVPN)), action: { _ in
                        self.buyVPN(.PerfectVPN)
                    })
                ]),
                Section(title: "", rows: [
                    TapActionRow(text: "Sign out".localized(), customization: { cell, _ in
                        cell.textLabel?.textColor = .red
                    }, action: { _ in
                        Alertift.alert(title: "Logout".localized(), message: "Do you really want to leave?".localized())
                            .action(.default("Yes".localized())){
                                Defaults[\.isAuthorized] = false
                                Defaults[\.vpnFavoriteList] = []
                                Defaults[\.lastVpn] = nil
                                Defaults[\.userCredentials] = nil
                                Defaults[\.vpnUsers] = []
                                Defaults[\.selectedVpnUser] = nil
                                Defaults[\.privacyShown] = false
                                UserDefaults.standard.set(false, forKey: "policyState")
                                VPNManager.shared.removeProfile()
                                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthController")
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true, completion: nil)
                        }
                        .action(.cancel("No".localized())){
                            self.reloadData()
                        }
                        .show(on: self, completion: nil)
                    })
                ])
            ]
        }
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotificationCenter()
        self.reloadData()
    }
    
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(successfulPurchase), name: NSNotification.Name(IAPManager.purchaseSuccessNotificationIdentifire), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseError), name: NSNotification.Name(IAPManager.purchaseErrorNotificationIdentifire), object: nil)
    }
  
    private func getProductFromId(id: String) -> IAPProducts {
        switch id {
        case "5":
            return .LiteVPN
        case "2":
            return .StandardVPN
        case "3":
            return .DoubleVPN
        case "4":
            return .PerfectVPN
        default:
            return .LiteVPN
        }
    }
    
    func getProductPrice(_ product: IAPProducts) -> String {
        let price = IAPManager.shared.priceOf(productWith: product.rawValue)
        return "\(price)/" + "Month".localized()
    }
    
    @objc private func successfulPurchase() {
        DispatchQueue.main.async {
            HUD.hide()
        }
        reloadSubscriptionData()
    }
    
    @objc private func purchaseError() {
        HUD.hide()
    }
    
    //IAP deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func reloadSubscriptionData() {
        DataManager.auth() {
            success in
            self.reloadData()
        }
    }
    
    private func buyVPN(_ product: IAPProducts) {
        HUD.show(.progress)
        IAPManager.shared.purchase(productWith: product.rawValue, isRenewed: false)
    }
    
    private func showMessage(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
