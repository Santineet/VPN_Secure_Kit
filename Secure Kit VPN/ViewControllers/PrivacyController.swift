//
//  PrivacyController.swift
//  Secure Kit VPN
//
//  Created by Luchik on 17.02.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import LGButton
import SwiftyUserDefaults

class PrivacyController: UIViewController{
    @IBAction func onClose(_ sender: Any) {
        Defaults[\.isAuthorized] = false
        Defaults[\.vpnFavoriteList] = []
        Defaults[\.lastVpn] = nil
        Defaults[\.userCredentials] = nil
        Defaults[\.vpnUsers] = []
        Defaults[\.selectedVpnUser] = nil
        Defaults[\.privacyShown] = false
        VPNManager.shared.removeProfile()
        let vc: AuthController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthController") as! AuthController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func onContinue(_ sender: Any) {
        self.dismiss(animated: true){
            self.dismissed!()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        //self.dismissed!()
    }
    var dismissed: (() -> Void)?
    @IBOutlet weak var continueBtn: LGButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        contentLabel.text = "Secure Kit does not store logs of online activity and connections, so it is impossible to correlate users and their actions on the network. We only collect information about your subscription necessary to activate your account, including email address and billing information.".localized()
        titleLabel.text = "How Secure Kit keeps privacy".localized()
        continueBtn.titleString = "Continue".localized()
    }
}
