//
//  ReadyLessonViewController.swift
//  Naganitara
//
//  Created by User on 22/02/2020.
//  Copyright © 2020 Naganitara. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class ReadyLessonViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var summary: UILabel!    
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var ImagesCollectionView: UICollectionView!
    
    var headLabel = ""
    var summaryLabel = ""
    var commentsLabel = ""
    var fireTitle: String?
    var fireNum: Int?
    
    let user = Auth.auth().currentUser!
    var db = Firestore.firestore()

    var imagesRef: StorageReference {
        return Storage.storage().reference().child("images/")
    }
        
   var imagesNames: [String] = []
        var notesImages: [UIImage] = []

        
    override func viewDidLoad() {
        super.viewDidLoad()
        headline.text = headLabel
        summary.text = summaryLabel
        comments.text = commentsLabel

        ImagesCollectionView.dataSource = self;
        ImagesCollectionView.delegate = self;
        
    }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notesImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ImagesCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
            
            cell.notesImageCell.image = notesImages[indexPath.item]
            cell.layer.borderWidth = 1
            cell.backgroundColor = UIColor.purple
            
        return cell
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //send text's & images to edit
            let vc = segue.destination as! EditLessonViewController
            vc.fireNum = self.fireNum
            vc.fireTitle = self.fireTitle
            vc.headText = self.headLabel
            vc.summaryText = self.summaryLabel
            vc.commentsText = self.commentsLabel
            vc.images = self.notesImages
        }
}
