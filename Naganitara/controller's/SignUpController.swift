//
//  SignUpController.swift
//  Naganitara
//
//  Created by User on 23/12/2019.
//  Copyright © 2019 Naganitara. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpController:UIViewController{

    
    @IBOutlet weak var nameTextfield: UITextField!
    
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var codeTF: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!

   

    override func viewWillAppear(_ animated: Bool) {
        let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
        }
    }
//    override func viewWillDisappear(_ animated: Bool) {
//        Auth.auth().removeStateDidChangeListener(handle!)
//    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load from defaults
        guard let name = UserDefaults.standard.string(forKey: "studentName") else {return}

        guard let email = UserDefaults.standard.string(forKey: "studentEmail") else {return}

        /*    !  UPGRADE  !
                                     */
        
        nameTextfield.text = name
        emailTF.text = email
    }
    
    func validation () -> String? {
        if nameTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            codeTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
            
            {
                return "👈 נא לכתוב שם, דוא״ל וסיסמה בעלת 6 תווים לפחות"
            }
        
        /*let cleandCode = codeTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isPasswordValid(cleandCode) == false{
            return "על הסיסמה להיות בעלת 6 תווים"
        }*/
        return nil
    }
    /*
     regular expression for a valid pass
     
     func isPasswordValid(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])[A-Za-z]{6,}")
        return passwordTest.evaluate(with: password)
    }
    */
    func showError (_ messege:String){
        errorLabel.text = messege
        errorLabel.alpha = 0.88
    }
    @IBAction func conformation(_ sender: Any) {
            let error = validation()
            if error != nil {
            showError(error!)
        }else {
            let name = nameTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let code = codeTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().createUser(withEmail: email, password: code) { (result, err) in
                //check for err
                if err != nil{
                    let e = err?.localizedDescription
                    print(e!)
                    self.showError(e! + "שגיאה ביצירת משתמש")
                }
                else{
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = name

                changeRequest?.commitChanges { error in
                    if error == nil {
                        print("User display name changed!")
                        self.dismiss(animated: false, completion: nil)
                    } else {
                        print("Error: \(error!.localizedDescription)")
                    }
                }
                    let db = Firestore.firestore()
                    db.collection("userSs").document(result!.user.uid).setData(["name": name, "uid": result!.user.uid, "email": email]) { (error) in
                        
                        if error != nil {
                            
                            self.showError("שגיאת שמירת נתונים")
                        }
                    }
                }
                transitionToStudentZone()
        }

                func transitionToStudentZone(){
                if let name = nameTextfield.text{
                    UserDefaults.standard.set(nameTextfield.text, forKey: "studentName")
                    UserDefaults.standard.set(emailTF.text, forKey: "studentEmail")
                   
                        //1) init the student vc
                        guard let vc = storyboard?.instantiateViewController(identifier: "studentZone") else {return}
            
                        //get the nav of the parent
                        if let nav = presentingViewController as? UINavigationController{
                            //nav -> show the student vc from part 2
                            nav.show(vc, sender: name)
                            dismiss(animated: true)
                    }
                }
            }
        }
    }
}
