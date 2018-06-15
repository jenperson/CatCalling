//
//  CatDetailViewController.swift
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

final class CatDetailViewController: UIViewController {
  
  // MARK: - Outlets
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var nameField: UITextField!
  @IBOutlet weak var notesTextView: UITextView!
  @IBOutlet var tapToAddMessage: UILabel!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  
  // MARK: - Properties
  var detailCat: Cat?
  var pickedImage: UIImage?
  let grayColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1.0)
  let lightBlueColor = UIColor(red: 2/255, green: 136/255, blue: 209/255, alpha: 1.0)
  let defaultText = "Description of cat"
  
  // MARK: - View Setup
  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.layer.cornerRadius = 10
    imageView.layer.borderColor = grayColor.cgColor
    imageView.layer.borderWidth = 1
    imageView.layer.masksToBounds = true
    notesTextView.layer.cornerRadius = 10
    notesTextView.layer.borderColor = grayColor.cgColor
    notesTextView.layer.borderWidth = 1
    notesTextView.textColor = grayColor
    notesTextView.text = defaultText
    detailCat = Cat()
  }

  
  @IBAction func didTapPhoto(_ sender: Any) {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let takePhotoAction = UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""), style: .default, handler: { [unowned self] _ in
        self.showImagePicker(withSourceType: .camera)
      })
      alertController.addAction(takePhotoAction)
    }
    
    let chooseFromLibraryAction = UIAlertAction(title: NSLocalizedString("Choose From Library", comment: ""), style: .default, handler: { [unowned self] _ in
      self.showImagePicker(withSourceType: .photoLibrary)
    })
    alertController.addAction(chooseFromLibraryAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
  @IBAction func didTapShareCat(_ sender: Any) {
    saveCat()
  }
  
}

// MARK: - Private
private extension CatDetailViewController {
  
  func saveCat() {
    guard let detailCat = detailCat,
      let name = nameField.text , !name.isEmpty else {
        alert(title: "Error", message: "Please make sure all fields are complete", isComplete: false)
        return
    }
    
    detailCat.name = name
    detailCat.note = notesTextView.text
    
    if let pickedImage = pickedImage {
      activityIndicator.startAnimating()
      detailCat.saveImage(pickedImage) { err in
        if let err = err {
          self.alert(title: "Error", message: err, isComplete: false)
          self.activityIndicator.stopAnimating()
          return
        }
        detailCat.saveCatToDB {
          self.activityIndicator.startAnimating()
          self.alert(title: "Saved!", message: "Thanks for CatCalling!", isComplete: true)
        }
      }
    }
  }
}

// MARK: - UIImagePickerControllerDelegate

extension CatDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func showImagePicker(withSourceType source: UIImagePickerControllerSourceType) {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = source
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    imagePicker.view.tintColor = view.tintColor
    present(imagePicker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
      dismiss(animated: true, completion: nil)
      return
    }
    
    pickedImage = image
    if let subView = imageView.subviews.first {
      subView.removeFromSuperview()
    }
    
    imageView.image = pickedImage
    tapToAddMessage.isHidden = true
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
}

extension CatDetailViewController {
  
  func alert(title: String, message: String, isComplete: Bool) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: { action in
      if isComplete {
          self.navigationController?.popViewController(animated: true)
      }
    })
    alertController.addAction(action)
    navigationController?.present(alertController, animated: true, completion: nil)
  }
}

extension CatDetailViewController: UITextViewDelegate {
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == defaultText {
      textView.text = nil
      textView.textColor = UIColor.black
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = defaultText
      textView.textColor = UIColor.lightGray
    }
  }
}
