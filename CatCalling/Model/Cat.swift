//
//  Cat.swift
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
import UIKit
import Firebase
import FirebaseStorage

final class Cat: NSObject {
  // MARK: Keys
  fileprivate enum Keys: String {
    case Name = "name"
    case ImagePath = "imagePath"
    case CloudImagePath = "cloudImagePath"
    case UserImagePath = "userImagePath"
    case Note = "note"
    case Key = "key"
    case Time = "timestamp"
    case User = "user"
    case Likes = "likes"
  }

  // MARK: - Properties
  var user: String?
  var name: String
  var imagePath: String?
  var cloudImagePath: String?
  var userImagePath: String?
  var note: String?
  var key: String?
  var timestamp: String?
  var likes: Int?
  let imageCache = NSCache<NSString, UIImage>()
  lazy var dbRef = Firestore.firestore().collection("cats")
  lazy var storageRef = Storage.storage().reference()
  lazy var vision = Vision.vision()
  
  // MARK: - Initializers
  
  override init() {
    name = ""
    super.init()
  }

  init(name: String, imagePath: String? = nil, note: String?, key: String? = nil, timestamp: String? = nil, user: String? = nil, userImagePath: String? = nil, likes: Int? = nil) {
    self.name = name
    self.imagePath = imagePath
    self.note = note
    self.key = key
    self.timestamp = timestamp
    self.user = user!
    self.userImagePath = userImagePath
    self.likes = likes
    super.init()
  }
  
  init(snapshot: QueryDocumentSnapshot) {
    let data = snapshot.data()
    self.user = data[Keys.User.rawValue] as? String ?? ""
    self.likes = data[Keys.Likes.rawValue] as? Int ?? 0
    self.name = data[Keys.Name.rawValue] as! String? ?? "name"
    self.imagePath = data[Keys.ImagePath.rawValue] as? String? ?? ""
    self.cloudImagePath = data[Keys.CloudImagePath.rawValue] as? String? ?? ""
    if let userImagePath = data[Keys.UserImagePath.rawValue] as? String {
      self.userImagePath = userImagePath
    }
    self.note = data[Keys.Note.rawValue] as! String? ?? "note"
    self.key = data[Keys.Key.rawValue] as? String ?? ""
  }
  
  func generateKey() -> String {
    let newRef = Firestore.firestore().collection("cats").document()
    return newRef.documentID
  }

}

// MARK: - Image Saving
extension Cat {
  
  func saveImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
    verifyCat(image: image) { err in
      // verification failed
      if let err = err {
        completion(err)
        return
      }
      
      guard let imgData = UIImageJPEGRepresentation(image, 0.5) else {return}
      let time = Double(Date.timeIntervalSinceReferenceDate * 1000)
      let catRef = self.storageRef.child("cat/\(time).jpg")
      let metadata = StorageMetadata()
      metadata.contentType = "image/jpeg"
      // Upload the file to the path "images/rivers.jpg"
      catRef.putData(imgData, metadata: metadata) {
        metadata, error in
        if let error = error {
          completion(error.localizedDescription)
          return
        }
        // imagepath created in imgix
        self.imagePath = "https://catcalling.imgix.net/cat/\(time).jpg"
        // get the downloadURL to store
        catRef.downloadURL { url, error in
          if let error = error {
            completion(error.localizedDescription)
            return
          }
          self.cloudImagePath = url?.absoluteString
          completion(nil)
        }
      }
    }
  }
  
  func catURL() -> String? {
    var path = ""
    if isImgix == false {
      guard let cloudPath = cloudImagePath else { return nil }
      path = cloudPath
    } else {
      guard let imagePath = imagePath else { return nil }
      let params = SettingsManager.sharedInstance.getURLparams(width: SettingsManager.sharedInstance.width, height: SettingsManager.sharedInstance.height, cropping: SettingsManager.sharedInstance.crop)
      path = "\(imagePath)\(params)"
    }
    return path
  }
  
  func catImage() -> UIImage? {
    guard let path = catURL() else { return nil }
    return downloadImage(urlString: path)
  }
  
  func userImage() -> UIImage? {
    guard let path = userImagePath else { return #imageLiteral(resourceName: "baseline_account_circle_black_18pt") }
    return downloadImage(urlString: path)
  }
  
  func downloadImage(urlString: String) -> UIImage? {
    guard let url = URL(string: urlString) else { return nil }
    if let cachedImage = imageCache.object(forKey: (urlString as NSString)) {
      return cachedImage
    } else {
      do {
        let data = try Data(contentsOf: url)
        let image = UIImage(data: data)
        self.imageCache.setObject(image!, forKey: (urlString as NSString))
        return image
      } catch {
        print("unable to download")
        return nil
      }
    }
  }
  
  func verifyCat(image: UIImage, completion: @escaping (String?) -> Void) {
    var isCat = false
    let labelDetector = vision.labelDetector()
    let visionImage = VisionImage(image: image)
    labelDetector.detect(in: visionImage) { (labels, error) in
      if let error = error {
        completion(error.localizedDescription)
        return
      }
      guard let labels = labels, !labels.isEmpty else {
        completion("Unable to process image")
        return
      }
      for label in labels {
        let labelText = label.label
        if labelText == "Cat" {
          isCat = true
          completion(nil)
          return
        }
      }
      if isCat == false {
        completion("Sorry, this is not a cat!")
      }
    }
  }
}

extension Cat {
  
  func saveCatToDB(completion: @escaping () -> Void) {
    self.user = LoginManager.sharedInstance.user?.displayName ?? ""
    self.userImagePath = LoginManager.sharedInstance.user?.photoURL?.absoluteString ?? ""
    var catRef: DocumentReference?
    Firestore.firestore().settings.areTimestampsInSnapshotsEnabled = true
    let timestamp = FieldValue.serverTimestamp()
    var dict = [
      "name": name,
      "imagePath": imagePath ?? "",
      "cloudImagePath": cloudImagePath ?? "",
      "note": note ?? "",
      "user": user ?? "user",
      "userImagePath": userImagePath ?? "",
      "timestamp": timestamp,
      "likes": 0
    ] as [String : Any]
    if key == nil {
      catRef = dbRef.document()
      let newKey = catRef!.documentID
      dict["key"] = newKey
    }
    else {
     dict["key"] = key
      catRef = dbRef.document(key!)
    }
    catRef!.setData(dict) { err in
      if let err = err {
        print("Error writing document: \(err)")
        completion()
      } else {
        print("Document successfully written!")
        completion()
      }
    }
  }
}
