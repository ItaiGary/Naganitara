//
//  extentionDate.swift
//  Naganitara
//
//  Created by User on 31/03/2020.
//  Copyright © 2020 Naganitara. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    func asString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: self)
    }
}
