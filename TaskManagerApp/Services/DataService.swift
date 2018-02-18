//
//  DataService.swift
//  TaskManagerApp
//
//  Created by Fareen on 2/17/18.
//  Copyright © 2018 Farin Namdari. All rights reserved.
//

import Foundation
import Firebase

let STORAGE_BASE = Storage.storage().reference()

class DataService {
    private static let _instance = DataService()
    private var _REF_UPLOADED_IMAGES = STORAGE_BASE.child("uploaded_images")
    
    static var instance: DataService {
        return _instance
    }
    
    var REF_UPLOADED_IMAGES: StorageReference {
        return _REF_UPLOADED_IMAGES
    }
    
}
