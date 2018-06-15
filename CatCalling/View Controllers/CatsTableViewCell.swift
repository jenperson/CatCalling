//
//  CatsTableViewCell.swift
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

import UIKit
import Foundation
import Firebase
import SDWebImage

class CatsTableViewCell: UITableViewCell {
  
  // MARK: Properties
  var catManager = CatDownloader()
  let linkMaker = LinkMaker()
  var cat: Cat! {
    didSet {
      let attributedString = attributedTextDescription()
      userNameLabel.text = cat.user ?? ""
      catsDescriptionLabel.attributedText = attributedString
      catsDescriptionLabel.sizeToFit()
      catsLabel.text = "\(cat.likes?.description ?? "0") likes"
      userImageView.image = #imageLiteral(resourceName: "baseline_account_circle_black_18pt")
      userImageView.tintColor = UIColor.black
      catsImageView.image = img
      self.checkIsLiked()
      self.populateImage()
      self.populateUserImage()
    }
  }
  let img = #imageLiteral(resourceName: "loading_cat").alpha(0.5)
  var isLiked = false
  
  
  // MARK: Outlets
  
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var catsImageView: UIImageView!
  @IBOutlet weak var catsLabel: UILabel!
  @IBOutlet weak var catsShareButton: UIButton!
  @IBOutlet weak var catsDescriptionLabel: UILabel!
  @IBOutlet weak var likeCatButton: UIButton!
  @IBOutlet weak var userNameLabel: UILabel!
  
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    userImageView.layer.cornerRadius = userImageView.frame.width/2.0
    userImageView.layer.masksToBounds = true
    likeCatButton.tintColor = UIColor.black
  }
  
  func attributedTextDescription() -> NSAttributedString {
    let boldText  = "\(cat.name) "
    let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 13)]
    let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
    let normalText = cat.note
    let normalString = NSMutableAttributedString(string:normalText!)
    attributedString.append(normalString)
    return attributedString
  }
  
  // populate image using SDWebImage
  func populateImage() {
    guard let url = self.cat.catURL() else { return }
    self.catsImageView.sd_setImage(with: URL(string: url), placeholderImage: img)
  }
  
  // populate image using NSCache and GCD
  func populateUserImage() {
    DispatchQueue.main.async {
      let userImage = self.cat.userImage()
      self.userImageView.image = userImage
    }
  }
  
  func checkIsLiked() {
    DispatchQueue.main.async {
      self.catManager.checkLikeStatus(cat: self.cat) { isLiked in
        self.isLiked = isLiked
        self.updateLikeButton(likes: self.cat.likes ?? 0)
      }
    }
  }
  
  func updateLikeButton(likes: Int) {
    var likeDescription = "likes"
    if isLiked == true {
      self.likeCatButton.setImage(#imageLiteral(resourceName: "ic_favorite"), for: .normal)
      if likes == 1 {
        likeDescription = "like"
      }
      catsLabel.text = "\(likes.description) \(likeDescription)"
    } else {
      if likes == 1 {
        likeDescription = "like"
      }
      self.likeCatButton.setImage(#imageLiteral(resourceName: "ic_favorite_border"), for: .normal)
      catsLabel.text = "\(likes.description) \(likeDescription)"
    }
  }
  
  func changeLikeCount() {
    cat.likes = cat.likes ?? 0
    if isLiked == true {
      cat.likes = cat.likes!+1
    } else {
      if cat.likes! > 0 {
        cat.likes = cat.likes!-1
      }
    }
    updateLikeButton(likes: cat.likes!)
  }
  
  @IBAction func didTapShareCat(_ sender: Any) {
    if let cat = cat {
      share(sender as AnyObject, cat: cat)
    }
  }
  
  @IBAction func didTapLikeCat(_ sender: Any) {
    isLiked = !isLiked
    saveLikeToDB(isLike: isLiked)
    // asign universal cat
    currentCat = self.cat
  }
  
  func saveLikeToDB(isLike: Bool) {
    if (isLike == true) {
      var data: [String: Any] = [:]
      data[(LoginManager.sharedInstance.user?.uid)!] = true
      Firestore.firestore().collection("cats").document(cat.key!).collection("likes").document((LoginManager.sharedInstance.user?.uid)!).setData(data) { error in
        if let error = error {
          print(error)
        }
        Analytics.logEvent("liked_image", parameters: nil)
        self.changeLikeCount()
      }
    } else {
      Firestore.firestore().collection("cats").document(cat.key!).collection("likes").document((LoginManager.sharedInstance.user?.uid)!).delete { error in
        if let error = error {
          print(error)
        }
        self.changeLikeCount()
      }
    }
    
  }
  
  func share(_ sender: AnyObject, cat: Cat) {
    linkMaker.createLink(propertyName: LinkMaker.LinkTypes.cat.rawValue, propertyVal: cat.key!) { link, err in
      if let err = err {
        print(err)
        return
      }
      let activityViewController = UIActivityViewController(
        activityItems: ["Check out this cat I liked in CatCalling!", link],
        applicationActivities: nil)
      self.window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
  }
  
}
