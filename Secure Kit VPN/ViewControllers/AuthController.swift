//
//  ViewController.swift
//  Secure Kit VPN
//
//  Created by Luchik on 17.01.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import UIKit
import Alertift
import SwiftyUserDefaults
import Localize_Swift
import LGButton

class AuthController: UIViewController, UITextFieldDelegate{
    @IBAction func onPrivacy(_ sender: Any) {
                UIApplication.shared.open(URL(string: "https://thesafety.us/privacy-policy")!, options: [
                    :]
        , completionHandler: nil)
    }
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBAction func onSignIn(_ sender: Any) {
        if usernameField.text == nil || passwordField.text == nil{
            return
        }
        self.isConnectedToNetwork(){s in
            if s{
                DataManager.auth(login: self.usernameField.text!, password: self.passwordField.text!){
                    success in
                    if !success{
                        Alertift.alert(title: "Error!".localized(), message: "Invalid username or password".localized()).action(.default("Ok".localized())).show(on: self, completion: nil)
                    }
                    else{
                        Defaults[\.isAuthorized] = true
                        let vc: UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home") as! UINavigationController
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
            else{
                Alertift.alert(title: "Error!".localized(), message: "No internet access".localized())
                    .action(.default("Ok".localized()))
                .show(on: self, completion: nil)
            }
        }
    }
    
    @IBAction func onSite(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://thesafety.us/")!, options: [
            :]
, completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        signInBtn.titleString = "Sign in".localized()
        usernameField.clearButtonMode = .whileEditing
        passwordField.clearButtonMode = .whileEditing
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField{
            passwordField.becomeFirstResponder()
        }
        else{
            textField.resignFirstResponder()
        }
        return true
    }
    
   
    @IBAction func onRegister(_ sender: Any) {
        let vc: RegisterController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterController") as! RegisterController
        //vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBOutlet weak var signInBtn: LGButton!
}

