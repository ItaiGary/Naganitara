//
//  LessonViewController.swift
//  Naganitara
//
//  Created by User on 23/12/2019.
//  Copyright © 2019 Naganitara. All rights reserved.

import UIKit
import AVKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import FirebaseStorage

class LessonViewController: UIViewController {

    @IBOutlet weak var headlineTF: UITextField!
       
    @IBOutlet weak var summary: UITextField!
       
    @IBOutlet weak var commentsTF: UITextField!
       
    @IBOutlet weak var collectionView: UICollectionView!
    
    var studentTableView: UITableView? = nil
    
    let lessonDataSource = LessonDataSource.shared
       
    var images: [UIImage] = []
    var videoPlayer: AVPlayer?
    var videoPlayerLayer: AVPlayerLayer?
    
    let storage = Storage.storage()
    var ref: DatabaseReference!
    let db = Firestore.firestore()

    var imgsRef:[String] = []
    var headText: String!
    var summaryText: String!
    var commentsText: String!
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpVideo()
            let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        collectionView.dataSource = self;
        collectionView.delegate = self;
    }

    @IBAction func takePhoto(_ sender: Any) {
        let imagePickerVC = UIImagePickerController()
          
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePickerVC.sourceType = .camera
        }
        imagePickerVC.allowsEditing = true
        imagePickerVC.delegate = self 
        present(imagePickerVC, animated: true)
    }

    var local = UserDefaults.standard.mutableArrayValue(forKey: "LessonsTitles")

    @IBAction func saveClass(_ sender: UIButton) {
        checkForDublicate()

        self.headText = headlineTF.text ?? ""
        self.summaryText = summary.text ?? ""
        self.commentsText = commentsTF.text ?? ""

        let title = "\(lessonDataSource.lessons.count + 1)\(headText!)) ( \( Date.init(timeIntervalSinceNow: 0).asString()) )"

        guard let user = Auth.auth().currentUser else {return}
        let storageRef = storage.reference().child("images/")
        let lessonsCollectionRef = db.collection("userSs").document(user.uid).collection("lessons")
        let lessonRef = lessonsCollectionRef.document(title)

        for img in images{
            let currentImage = img
            let uuidStr = "\(UUID().uuidString).jpeg"
            
            let storeImage = storageRef.child("\(uuidStr)")
            storeImage.putData(currentImage.jpegData(compressionQuality: 100) ?? Data(), metadata: nil) { (metadata, error) in
                if let error = error {
                        Swift.print("\(error) ||||||||| NO METADATA")
                    }else{
                        Swift.print(metadata as Any)
                        }
                    }
            imgsRef.append(uuidStr.description)
        }

        lessonDataSource.lessons.insert(Lesson(titleI: self.headText, numI: lessonDataSource.lessons.count + 1, dateI: Date(timeIntervalSinceNow: 0).asString(), commentsI: self.commentsText, summeryI: self.summaryText, imagesUUIDI: imgsRef), at: 0)
        
            // upload lesson to firebase
            lessonRef.setData(["Lesson": headText.description, "Summary": summaryText.description, "Comments" : commentsText.description, "ImagesURL": imgsRef, "Date": Date(timeIntervalSinceNow: 0).asString(), "Number": lessonDataSource.lessons.count])

            studentTableView?.reloadData()
            transitionToStudentZone()
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
        func checkForDublicate(){
        for itarator in lessonDataSource.lessons {
            print(itarator.title.description)
                if itarator.title.description == headlineTF.text && itarator.date == Date(timeIntervalSinceNow: 0).asString(){
                    alertLesExist()
                    return
                }
            }
        }
    }

//delegate
extension LessonViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Cell", for: indexPath) as! CollectionViewCell1
             
               cell.notesImage.image = images[indexPath.item]
               cell.layer.borderWidth = 1
               
           return cell
       }
       
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Info", info)
        
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            images.append(img)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        else if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            images.append(img)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        else {return}
        
        picker.dismiss(animated: true)
    }
        func setUpVideo(){
            let bundlePath = Bundle.main.path(forResource: "patiphone", ofType: "mp4")
            
            let url = URL(fileURLWithPath: bundlePath!)
            // add player item
            let item = AVPlayerItem(url: url)
            // add player
            videoPlayer = AVPlayer(playerItem: item)
            // add player layer
            videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
            // adjust size & frame
            videoPlayerLayer?.frame = CGRect(x:0, y: 0, width: self.view.frame.size.width*4, height:self.view.frame.size.height)
            videoPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            view.layer.insertSublayer(videoPlayerLayer!, at: 1)
            // add to a view & play it
            videoPlayer?.playImmediately(atRate: 0.6)
        }
        func alertLesExist(){
            let alert = UIAlertController.init(title: "שיעור קיים", message: "שיעור עם הכותרת והתאריך הזה כבר קיים, כתוב כותרת אחרת או ערוך את השיעור שכבר קיים", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction.init(title: "סבבה", style: .cancel, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
}



