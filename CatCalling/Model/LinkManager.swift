//
//  LinkMaker.swift
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

class LinkMaker {
  
  // MARK: Properties
  
  static let DYNAMIC_LINK_DOMAIN = "rkw75.app.goo.gl"
  var longLink: URL?
  var shortLink: URL?
  
  enum Params: String {
    case link = "Link Value"
    case source = "Source"
    case medium = "Medium"
    case campaign = "Campaign"
    case term = "Term"
    case content = "Content"
    case bundleID = "App Bundle ID"
    case fallbackURL = "Fallback URL"
    case minimumAppVersion = "Minimum App Version"
    case customScheme = "Custom Scheme"
    case iPadBundleID = "iPad Bundle ID"
    case iPadFallbackURL = "iPad Fallback URL"
    case appStoreID = "AppStore ID"
    case affiliateToken = "Affiliate Token"
    case campaignToken = "Campaign Token"
    case providerToken = "Provider Token"
    case packageName = "Package Name"
    case androidFallbackURL = "Android Fallback URL"
    case minimumVersion = "Minimum Version"
    case title = "Title"
    case descriptionText = "Description Text"
    case imageURL = "Image URL"
    case otherFallbackURL = "Other Platform Fallback URL"
  }
  
  enum ParamTypes: String {
    case googleAnalytics = "Google Analytics"
    case iOS = "iOS"
    case iTunes = "iTunes Connect Analytics"
    case android = "Android"
    case social = "Social Meta Tag"
    case other = "Other Platform"
  }
  
  enum LinkTypes: String {
    case cat = "cat"
    case share = "Share"
  }
  
  init() {
    
  }
  
  func createLink(propertyName: String, propertyVal: String, completion: @escaping (String, Error?) -> Void) {
    let linkString = "http://example.com/?cat=\(propertyVal)"
    
    guard let link = URL(string: linkString) else { return }
    print(link)
    let components = DynamicLinkComponents(link: link, domain: LinkMaker.DYNAMIC_LINK_DOMAIN)
    
    let bundleID = "com.google.personjeh.InspiringQuotes"
    let iOSParams = DynamicLinkIOSParameters(bundleID: bundleID)
    components.iOSParameters = iOSParams
    
    let options = DynamicLinkComponentsOptions()
    options.pathLength = .short
    components.options = options
    longLink = components.url
    
    shortenLink(components: components) { link, err in
      if let err = err {
        completion(link, err)
        return
      }
      print(link)
      completion(link, nil)
    }
  }
  
  func shortenLink(components: DynamicLinkComponents, completion: @escaping (String, Error?) -> Void) {
    let options = DynamicLinkComponentsOptions()
    options.pathLength = .unguessable
    components.options = options
    
    components.shorten { (shortURL, warnings, error) in

      // Handle shortURL.
      if let error = error {
        print(error.localizedDescription)
        completion("", error)
        return
      }
      self.shortLink = shortURL
      print(self.shortLink?.absoluteString ?? "")
      completion(self.shortLink?.absoluteString ?? "", nil)
    }
  }
}
