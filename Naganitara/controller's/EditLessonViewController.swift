//
//  EditLessonViewController.swift
//  Naganitara
//
//  Created by User on 26/04/2020.
//  Copyright © 2020 Naganitara. All rights reserved.
//

import UIKit
import AVKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import FirebaseStorage

class EditLessonViewController: UIViewController {

    @IBOutlet weak var headlineTF: UITextField!

    @IBOutlet weak var summaryTF: UITextField!

    @IBOutlet weak var commentsTF: UITextField!

    @IBOutlet weak var collectionView: UICollectionView!

    var studentTableView: UITableView? = nil

    let lessonDataSource = LessonDataSource.shared

    var images: [UIImage] = []
    var videoPlayer: AVPlayer?
    var videoPlayerLayer: AVPlayerLayer?

    let storage = Storage.storage()
    var ref: DatabaseReference!

    var headText: String?
    var summaryText: String?
    var commentsText: String?

    var fireTitle: String?
    var fireNum: Int?

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
        headlineTF.text = headText
        summaryTF.text = summaryText
        commentsTF.text = commentsText
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
    let db = Firestore.firestore()


    @IBAction func saveClass(_ sender: UIButton) {
        guard let user = Auth.auth().currentUser else {return}
        let lessonsCollectionRef = db.collection("userSs").document(user.uid).collection("lessons")
        lessonsCollectionRef.document(fireTitle!).delete()

        var count = 0
        for les in lessonDataSource.lessons{
            if les.num == fireNum!{
                lessonDataSource.lessons.remove(at: count)
            }
            count += 1
            print(count)
        }
        self.headText = headlineTF.text ?? ""
        self.summaryText = summaryTF.text ?? ""
        self.commentsText = commentsTF.text ?? ""

        var imgsRef:[String] = []
        let title = "\(fireNum!)\(headText!)) ( \( Date.init(timeIntervalSinceNow: 0).asString()) )"

        let storageRef = storage.reference().child("images/")
        
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
        lessonDataSource.lessons.insert(Lesson(titleI: self.headText!, numI: fireNum!, dateI: Date(timeIntervalSinceNow: 0).asString(), commentsI: self.commentsText!, summeryI: self.summaryText!, imagesUUIDI: imgsRef), at: 0)
            // upload lesson to firebase
        let lessonRef = lessonsCollectionRef.document(title)
            lessonRef.setData(["Lesson": headText!, "Summary": summaryText!, "Comments" : commentsText!, "ImagesURL": imgsRef, "Date": Date(timeIntervalSinceNow: 0).asString(), "Number": fireNum!])
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

extension EditLessonViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
}



