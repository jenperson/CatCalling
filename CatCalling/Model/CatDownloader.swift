//
//  CatDownloader.swift
//  CatCalling
//
//  Created by Jen Person on 4/30/18.
//  Copyright 2018 Google LLC
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and limitations under the License.

import Foundation
import Firebase

class CatDownloader {
  
  // MARK: - Properties
  
  lazy var dbRef = Firestore.firestore().collection("cats")
  //static let sharedInstance = CatManager()
  //lazy var cats = [Cat]()
  var lastDoc: DocumentSnapshot?
  
  // MARK: - Initializers
  
  init() {}
}

// Firestore extension
extension CatDownloader {
  
  // 1 function includes an escaping completion handler
  func downloadCats(cats: [Cat], startAt: String?, startAfter: DocumentSnapshot?,  completion: @escaping ([Cat]) -> Void) {
    var catArray = cats
    let query = dbRef.order(by: "timestamp", descending: true).limit(to: 10)
    getQuery(query: query, startAt: startAt, startAfter: startAfter) { query in
      guard let dbQuery = query else {
        completion(catArray)
        return
      }
      // 2 add a listener, or get the data you need
      dbQuery.getDocuments { snapshot, error in
        if let error = error {
          completion(catArray)
          print(error)
          return
        }
        if (startAt == nil && isDynamicLink == true) {
          // don't reload data
          completion(catArray)
          return
        }
        self.lastDoc = snapshot!.documents.last
        // 3 add data as needed
        for doc in snapshot!.documents {
          let cat = Cat(snapshot: doc)
          catArray.append(cat)
          
        }
        completion(catArray)
      }
    }
  }
  
  func getQuery(query: Query, startAt: String?, startAfter: DocumentSnapshot?, completion: @escaping (Query?) -> Void) {
    if let startAfter = startAfter {
      let dbQuery = query.start(afterDocument: startAfter)
      completion(dbQuery)
      return
    }
    if let startAt = startAt {
      dbRef.document(startAt).getDocument { snapshot, err in
        if let err = err {
          completion(nil)
          print(err)
          return
        }
        guard let snapshot = snapshot else { return }
        let dbQuery = query.start(atDocument: snapshot)
        completion(dbQuery)
        return
      }
    } else {
      completion(query)
    }
  }
  
  func checkLikeStatus(cat: Cat, completion: @escaping (Bool) -> Void) {
    
    guard let _ = cat.key, let _ = LoginManager.sharedInstance.user else {return};  Firestore.firestore().collection("cats").document(cat.key!).collection("likes").document(LoginManager.sharedInstance.user!.uid).getDocument { snapshot, err in
      if (snapshot?.exists)! == true {
        completion(true)
      } else {
        completion(false)
      }
    }
  }
}
