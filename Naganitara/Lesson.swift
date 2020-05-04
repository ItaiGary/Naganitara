//
//  LessonObj.swift
//  Naganitara
//
//  Created by User on 21/03/2020.
//  Copyright © 2020 Naganitara. All rights reserved.
//
import UIKit
import Foundation

class Lesson {
    
    let title: String
    let num: Int
    let comments: String
    let summery: String
    var date: String
    
    
    var imagesUUID: [String]
    
    init(titleI: String, numI: Int, dateI: String, commentsI: String, summeryI: String, imagesUUIDI: [String]) {
        self.title = titleI
        self.summery = summeryI
        self.comments = commentsI
        self.num = numI
        self.date = dateI
        self.imagesUUID =  imagesUUIDI
    }
}
