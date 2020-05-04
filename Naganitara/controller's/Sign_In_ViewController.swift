//
//  Sign_In_ViewController.swift
//  Naganitara
//
//  Created by User on 08/01/2020.
//  Copyright © 2020 Naganitara. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class Sign_In_ViewController: UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var codeTF: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()


         guard let email = UserDefaults.standard.string(forKey: "studentEmail") else {return}
        
         emailTF.text = email
    }

    var studentTableView: UITableView? = nil
    var lessonDataSource = LessonDataSource.shared


    func validation () -> String? {
            if
                emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                    codeTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
            {
                return "יש למלא נכון את 👾 הפרטים "
        }
        return nil
    }
    func showError (_ messege:String){
        errorLabel.text = messege
        errorLabel.alpha = 0.88
    }
    @IBAction func conformation(_ sender: UIButton) {
        let error = validation()
        if error != nil{
            showError(error!)
        }
        else {
            Auth.auth().signIn(withEmail: emailTF.text!, password: codeTF.text!) { (result, err) in
                if err != nil{
                    let e = err?.localizedDescription
                    print(e!)
                    self.showError(e! + "תקלה:")
                    return
                }
                    let dbRef = Firestore.firestore()
                    let name = Auth.auth().currentUser?.displayName
                    guard let user = Auth.auth().currentUser else {return}
                    dbRef.collection("userSs").document(user.uid).collection("lessons").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        self.lessonDataSource.lessons.removeAll()
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")

                        let title = document.get("Lesson") as! String
                        let summery = document.get("Summary") as! String
                        let comments = document.get("Comments") as! String
                        let date = document.get("Date") as! String
                        let num = document.get("Number")
                        let imgs = document.get("ImagesURL") as! [String]

                            self.lessonDataSource.lessons.insert(Lesson(titleI: title.description , numI: num as! Int, dateI: date.description, commentsI: comments.description, summeryI: summery.description, imagesUUIDI: imgs), at: 0)
                    }
                    self.transitionToStudentZone()
                }
            }
                UserDefaults.standard.set(name, forKey: "studentName")
                UserDefaults.standard.set(self.emailTF.text, forKey: "studentEmail")
            }
        }
    }
    func transitionToStudentZone(){
         guard let vc = storyboard?.instantiateViewController(identifier: "studentZone") else {return}
                //get the nav of the parent
                if let nav = presentingViewController as? UINavigationController{
                   let name = UserDefaults.standard.dictionary(forKey: "studentName")
                   //nav -> show the student vc from part 2
                   nav.show(vc, sender: name)
                }
             dismiss(animated: true)
         }
     }


