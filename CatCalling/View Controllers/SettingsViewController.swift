//
//  SettingsViewController.swift
//  CatCalling
//
//  Created by Jen Person on 5/21/18.
//  Copyright © 2018 Google. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

  // MARK: Properties
  
  // MARK: Outlets
  
  @IBOutlet weak var useImgIxSwitch: UISwitch!
  @IBOutlet weak var widthTextField: UITextField!
  @IBOutlet weak var heightTextField: UITextField!
  @IBOutlet weak var croppingSegmentedControl: UISegmentedControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    widthTextField.text = SettingsManager.sharedInstance.width
    heightTextField.text = SettingsManager.sharedInstance.height
    useImgIxSwitch.isOn = isImgix
    widthTextField.isEnabled = isImgix
    heightTextField.isEnabled = isImgix
    croppingSegmentedControl.isEnabled = isImgix
    croppingSegmentedControl.selectedSegmentIndex = SettingsManager.sharedInstance.crop.hashValue
  }
  
  override func viewWillLayoutSubviews() {
    // sync toggle with using ImgIx
    useImgIxSwitch.isOn = isImgix
  }
  
  func restoreDefaults() {
    useImgIxSwitch.setOn(true, animated: true)
    croppingSegmentedControl.selectedSegmentIndex = 0
    widthTextField.text = ""
    textFieldDidEndEditing(widthTextField)
    heightTextField.text = "300"
    textFieldDidEndEditing(heightTextField)
  }

  @IBAction func didToggleUseImgIx(_ sender: Any) {
    isImgix = !isImgix
    widthTextField.isEnabled = isImgix
    heightTextField.isEnabled = isImgix
    croppingSegmentedControl.isEnabled = isImgix
  }
  
  
  @IBAction func didChangeCroppingSegment(_ sender: Any) {
    switch croppingSegmentedControl.selectedSegmentIndex {
    case 0:
      SettingsManager.sharedInstance.crop = SettingsManager.CropParams.none
    case 1:
      SettingsManager.sharedInstance.crop = SettingsManager.CropParams.edges
    case 2:
      SettingsManager.sharedInstance.crop = SettingsManager.CropParams.entropy
    default:
      SettingsManager.sharedInstance.crop = SettingsManager.CropParams.none
    }
  }
  
  @IBAction func didTapRestoreDefaults(_ sender: Any) {
    restoreDefaults()
  }
  
}

// TODO: Add Checks for data type

extension SettingsViewController: UITextFieldDelegate {
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == heightTextField {
      SettingsManager.sharedInstance.height = textField.text
    }
    if textField == widthTextField {
      SettingsManager.sharedInstance.width = textField.text
    }
  }
  
}
