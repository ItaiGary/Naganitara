//
//  ViewController.swift
//  Naganitara
//
//  Created by User on 19/12/2019.
//  Copyright © 2019 Naganitara. All rights reserved.
//

import UIKit
import Firebase
import MessageUI


class Enter: UIViewController {
    
   
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    

    @IBAction func mail(_ sender: Any) {
        mailing()
//        UIApplication.shared.open(URL(string: "mailto:tiger2007@gmail.com")! as URL, options: [:], completionHandler: nil)
    }
    
    func mailing(){
            guard MFMailComposeViewController.canSendMail()else{
                    alertMail(title: "דוא״ל לא נפתח", messege: "tiger2007@gmail.com  💚  ")
                    print("cant send EMAIL ||||||||")
                    return
                }
                        let composer = MFMailComposeViewController()
                        composer.mailComposeDelegate = self
                        composer.setSubject("ייעוץ או קביעת שיעור גיטרה")
                    composer.setToRecipients(["mailto:tiger2007@gmail.com"])
                    present(composer, animated: true)
        }

    @IBAction func face(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://www.facebook.com/%D7%9E%D7%95%D7%A8%D7%94-%D7%92%D7%99%D7%98%D7%A8%D7%94-%D7%9B%D7%A4%D7%A8-%D7%95%D7%99%D7%AA%D7%A7%D7%99%D7%9F-%D7%A9%D7%93%D7%94-%D7%99%D7%A6%D7%97%D7%A7-%D7%90%D7%99%D7%AA%D7%99-%D7%92%D7%90%D7%A8%D7%99-562095870651974/")! as URL, options: [:], completionHandler: nil)
    }
    
    fileprivate let application = UIApplication.shared
    @IBAction func phone(_ sender: UIButton) {
            if let phoneURL = URL(string: "tell://0503250009"){
                if application.canOpenURL(phoneURL){
                    application.open(phoneURL, options: [:], completionHandler: nil)}
                    else{
                        print("pizdets no phoning while playing dood")
                        alertMail(title: "לא ניתן להתקשר", messege: "נסה לחייג אלי רגיל 050-3250009 :)")
                    }
            }
        }
    
    override func viewWillAppear(_ animated: Bool) {
        let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        styleButtons()
    }
    
    func alertMail(title: String, messege: String){
        let alert = UIAlertController(title: title, message: messege, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        let actionOk = UIAlertAction(title: "או קיי", style: .cancel) { (UIAlertAction) in
            print("actionOk")
            }
            alert.addAction(actionOk)
        }
            
    
    
    func styleButtons() {
        loginButton.layer.borderWidth = 2
        signupButton.layer.borderWidth = 2
        
        loginButton.layer.borderColor = UIColor.black.cgColor
        signupButton.layer.borderColor = UIColor.black.cgColor
        
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        signupButton.layer.cornerRadius = signupButton.frame.height / 2
        }
    }

extension  Enter: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let err = error{
                print("error |||||||| \(err)")
            }
            switch result {
            case .cancelled:
                print("email canceld")
            case .failed:
                print("email failed")
            case .saved:
                print("email saved")
            case .sent:
                print("email sent")
            }
        }
    }
