//
//  LessonViewController.swift
//  Naganitara
//
//  Created by User on 23/12/2019.
//  Copyright © 2019 Naganitara. All rights reserved.
//

import UIKit
import AVKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import FirebaseStorage

class LessonViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        
            let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                
            self.setUpVideo()
        }
    }
    
    var videoPlayer: AVPlayer?
    
    var videoPlayerLayer: AVPlayerLayer?
    
    @IBOutlet weak var headlineTF: UITextField!
    
    @IBOutlet weak var summary: UITextView!
    
    @IBOutlet weak var commentsTF: UITextView!
    
    
    var headText = ""
    var summaryText = ""
    var commentsText = ""
    
    @IBAction func saveClass(_ sender: UIButton) {
        self.headText = headlineTF.text ?? ""
        self.summaryText = headlineTF.text ?? ""
        self.commentsText = headlineTF.text ?? ""
        
        performSegue(withIdentifier: "saveLesson", sender: self)
        
        guard let currentImage = image.image else {return}
    
        let db = Firestore.firestore()
        let storageRef = storage.reference()        
        let imagesRef = storageRef.child("images")        
        var spaceRef = storageRef.child("images/\(UUID().description).jpeg")

        // This is equivalent to creating the full reference
        let uploadTask = spaceRef.putData(currentImage.jpegData(compressionQuality: 100) ?? Data(), metadata: nil) { (metadata, error) in
             guard let metadata = metadata else {
                print("err: \(error)" )
               return
             }
             // Metadata contains file metadata such as size, content-type.
            _ = metadata.size
             // You can also access to download URL after upload.
             spaceRef.downloadURL { (url, error) in
               guard let downloadURL = url else {
                 // Uh-oh, an error occurred!
                 return
               }
             
                print("need to save url in databse \n \(downloadURL)")
                
                //MARK: need to save url in database/Users/user/Documents/Naganitara/Naganitara/controller's/ReadyLessonViewController.swift
//                db.collection("users").document() { (error) in
//
//                    if error != nil {
//
//                        print("שגיאת שמירת נתונים")
//                    }
//                }
             }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    var vc = segue.destination as! ReadyLessonViewController
    vc.headlineLabel = self.headText
    vc.summaryLabel = self.summaryText
    vc.commentsLabel = self.commentsText
}
    
    @IBOutlet weak var image: UIImageView!
    
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
    
    let storage = Storage.storage()
    
    @IBAction func takePhoto(_ sender: Any) {
            // let camara = UIImagePickerController().cameraCaptureMode
           let imagePickerVC = UIImagePickerController()
             
           if UIImagePickerController.isSourceTypeAvailable(.camera){
               imagePickerVC.sourceType = .camera
           }
           //crop, etc.
           imagePickerVC.allowsEditing = true
           imagePickerVC.delegate = self //extension: conform to protocols
           present(imagePickerVC, animated: true)
    
    }
    
    
    
    var ref: DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }

}

//delegate
extension LessonViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
       
        picker.dismiss(animated: true)
    }
//    let vc = UIImagePickerController()
//    vc.sourceType = .camera
//    vc.allowsEditing = true
//    vc.delegate = self
//    present(vc, animated: true)
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //[] print("Info", info)
 
        picker.dismiss(animated: true)
              
        guard let image1 = info[.originalImage] as? UIImage else {return}
        //use the photo
        image.image = image1
        print(image1)
    }
    
}

