//
//  Category.swift
//  Todoey
//
//  Created by Joseph Metzger on 6/9/18.
//  Copyright © 2018 Joseph Metzger. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
