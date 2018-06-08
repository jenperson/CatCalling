//
//  SettingsManager.swift
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

var isImgix = true

final class SettingsManager {
  
  // MARK: Properties
  
  static let sharedInstance = SettingsManager()
  var width: String? = "300"
  var height: String? = "300"
  var crop: CropParams = CropParams.edges
  
  enum Params: String {
    case width = "w"
    case height = "h"
    case crop = "crop"
  }
  
  enum CropParams: String {
    case none = "none"
    case edges = "edges"
    case entropy = "entropy"
  }
  
  func getURLparams(width: String?, height: String?, cropping: CropParams) -> String {
    var urlParams = "?"
    // add width, if noted
    if let width = width {
      if urlParams != "?" {
        urlParams = "\(urlParams)&"
      }
      urlParams = "\(urlParams)\(Params.width.rawValue)=\(width)"
    }
  
    // add height, if noted
    if let height = height {
      if urlParams != "?" {
        urlParams = "\(urlParams)&"
      }
      urlParams = "\(urlParams)\(Params.height.rawValue)=\(height)"
    }
    
    // add cropping, if noted
    urlParams = cropParams(urlParams: urlParams, cropping: cropping)
    
    return urlParams
  }
  
  func cropParams(urlParams: String, cropping: CropParams) -> String {
    var cropParam = urlParams
    switch cropping {
    case .none:
      return cropParam
    case .edges:
      if urlParams != "?" {
        cropParam = "\(cropParam)&"
      }
      cropParam = "\(cropParam)fit=crop&\(Params.crop.rawValue)=\(CropParams.edges.rawValue)"
      return cropParam
    case .entropy:
      if cropParam != "?" {
        cropParam = "\(cropParam)&"
      }
      cropParam = "\(cropParam)fit=crop&\(Params.crop.rawValue)=\(CropParams.entropy.rawValue)"
      return cropParam
    }
  }
}

