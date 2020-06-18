//
//  RegisterController.swift
//  Secure Kit VPN
//
//  Created by Luchik on 04.02.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit
import LGButton
import Localize_Swift
import Alertift
import SwiftyUserDefaults

class RegisterController: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var creatingAccBtn: UIButton!
    @IBOutlet weak var signUpBtn: LGButton!
    @IBAction func onPrivacy(_ sender: Any) {
               UIApplication.shared.open(URL(string: "https://thesafety.us/privacy-policy")!, options: [
                    :]
        , completionHandler: nil)
    }
    @IBAction func onSignUp(_ sender: Any) {
        if emailTextField.text == nil || passwordTextField.text == nil{
            return
        }
        DataManager.register(email: emailTextField.text!, password: passwordTextField.text!){
            (success, text) in
            if !success{
                Alertift.alert(title: "Error!".localized(), message: text.localized())
                    .action(.default("Ok".localized()))
                    .show(on: self, completion: nil)
            }
            else{
                if text == "freevpn"{
                    Alertift.alert(title: "Congratulations!".localized(), message: "Вы получили бесплатный VPN на 7 дней.".localized())
                        .action(.default("Ok".localized())){
                            DataManager.auth(login: self.emailTextField.text!, password: self.passwordTextField.text!){
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
                        .show(on: self, completion: nil)
                }
                else{
                    Alertift.alert(title: nil, message: "You have already got free VPN earlier on this device. You can buy VPN subscription.".localized())
                        .action(.default("Ok".localized())){
                            DataManager.auth(login: self.emailTextField.text!, password: self.passwordTextField.text!){
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
                    .show(on: self, completion: nil)
                }
            }
        }
    }
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        emailTextField.clearButtonMode = .whileEditing
        passwordTextField.clearButtonMode = .whileEditing
        print("UUID: \(KeychainService().getUUID())")
        signUpBtn.titleString = "Sign up".localized()
        creatingAccBtn.titleLabel?.lineBreakMode = .byWordWrapping
        creatingAccBtn.titleLabel?.numberOfLines = 2
        creatingAccBtn.titleLabel?.textAlignment = .center
    }
    
    @IBAction func onAuth(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }
        else{
            textField.resignFirstResponder()
        }
        return true
    }
}
