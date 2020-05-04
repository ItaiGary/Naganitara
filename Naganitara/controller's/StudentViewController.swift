//
//  StudentViewController.swift
//  Naganitara
//
//  Created by User on 23/12/2019.
//  Copyright © 2019 Naganitara. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class StudentViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var greetLabel: UILabel!
    @IBAction func addLessonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "add_class", sender: tableView)
    }

    var status = ""   
    var lessonDataSource = LessonDataSource.shared
    var dbRef = Firestore.firestore()
    var studentTableView: UITableView?

    override func viewWillAppear(_ animated: Bool) {
            self.navigationItem.hidesBackButton = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 6..<12 : status = NSLocalizedString("בוקר", comment: "בוקר")
        
        case 12..<17 : status = NSLocalizedString("יום", comment: "יום")
            
        case 17..<22 :
            status = NSLocalizedString("ערב", comment: "ערב")
            
        default:
            status = NSLocalizedString("לילה", comment: "לילה")
        }
        
        let user = UserDefaults.standard.string(forKey: "studentName") ?? ""
        greetLabel.text = "\(user), \(status) טוב"
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? LessonViewController{
            dest.studentTableView = sender as? UITableView
        }
    }
}
let imagesCache = NSCache<NSString, UIImage>()

func downloadImg(from imgRef: StorageReference, closure: @escaping (UIImage?)->Void){
        let name = imgRef.name as NSString
        if let cachedImage = imagesCache.object(forKey: name){
            closure(cachedImage)
            }
    return
}


extension StudentViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessonDataSource.lessons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lessonCell") as! MainTableViewCell
        let lesson = lessonDataSource.lessons[indexPath.row]
        
        cell.headLine.text = lesson.title
        cell.numberLabel.text = lesson.num.description
        cell.dateLabel.text = lesson.date
      
        return cell
    }

    // lesson (cell) selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell \(indexPath.row) is selected")
            let vc = storyboard?.instantiateViewController(identifier: "readyLesson") as? ReadyLessonViewController
            self.navigationController?.pushViewController(vc!, animated: true)
            
            let lesson = lessonDataSource.lessons[indexPath.row]
            let storage = Storage.storage()
            let imgNamArr: [String] = lesson.imagesUUID

            for imgNam in imgNamArr{
                let imgRef = storage.reference().child("images").child(imgNam)
                imgRef.downloadURL{ url, error in
                if let error = error {
                        print("\(error) |||||| NO URL|||||")
                      } else {
                        print("\(String(describing: url)) <----- url")
                      }
                }
                imgRef.getData(maxSize: 12 * 1024 * 1024 * 12) { data, error in
                  if let error = error {
                    print("||||||||| error geting img data ||||||| \(error)")
                    } else {
                    let image: UIImage = UIImage(data: data!)!
                    vc?.notesImages.append(image)
                  }
                  vc?.ImagesCollectionView.reloadData()
                }
            }
            vc?.fireTitle = "\(lesson.num)\(lesson.title)) ( \(lesson.date) )"
            vc?.fireNum = lesson.num
            vc?.headLabel = lesson.title
            vc?.summaryLabel = lesson.summery
            vc?.commentsLabel = lesson.comments
        }
    func tableView(_ tableView: UITableView, canEditRowAt: IndexPath) -> Bool{
        return true
        }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete{
                lessonDataSource.lessons.remove(at: indexPath.row )
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
        }
    }
}
