//
//  Category.swift
//  Todoey
//
//  Created by Julio Collado on 9/11/19.
//  Copyright © 2019 Julio Collado. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    var items = List<Item>()
}
