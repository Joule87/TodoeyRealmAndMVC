//
//  CoreDataManager.swift
//  Todoey
//
//  Created by Julio Collado on 9/10/19.
//  Copyright © 2019 Julio Collado. All rights reserved.
//

import Foundation
import RealmSwift

class RealmMananger {
    
    static let shared = RealmMananger()
    private var realm = try! Realm()
    
    private init() {}
    
    // MARK: - Realm Methods
    
    func get<T: Object>(objectsType: T.Type) -> Results<T> {
        let objects = realm.objects(objectsType)
        return objects
    }
 
    func save(object: Object) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print("Error trying to save Object: \(error)")
        }
    }
    
    func remove(object: Object) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Error trying to delete Object: \(error)")
        }
    }
    
    func update(action: ()->()) {
        do {
            try realm.write {
                action()
            }
        } catch {
            print("Error trying to update data: \(error)")
        }
    }
    
    
}
