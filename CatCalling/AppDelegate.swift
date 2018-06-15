//
//  AppDelegate.swift
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
import FirebaseDynamicLinks
import Firebase
import FirebaseUI

var isDynamicLink = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    LoginManager.sharedInstance.checkLoginStatus() { user in
      isUser = user
    }
    
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                   restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    handleDynamicLink(url: userActivity.webpageURL!)
    return true
  }
  
  @available(iOS 9.0, *)
  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
    // FUIAuth Handling
    let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
    if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
      return true
    }
    
    return application(app, open: url,
                       sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                       annotation: "")
  }
  
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    handleDynamicLink(url: (url))
    return true
  }

}

// MARK: Handle URLs
extension AppDelegate {
  
  func handleDynamicLink(url: URL) {
    DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamiclink, error) in
      if let error = error {
        print(error)
      }
      
      self.handled(link: (dynamiclink?.url?.absoluteString)!)
    }
  }
  
  func handled(link: String) {
    let dict = parseLink(link: link)
    // if the link contains a cat
    if let paramVal = dict[LinkMaker.LinkTypes.cat.rawValue] {
      if let wd = self.window {
        var vc = wd.rootViewController
        if(vc is UINavigationController){
          vc = (vc as! UINavigationController).visibleViewController
          if vc is CatsTableViewController {
            let vc = vc as! CatsTableViewController
            vc.startCat = paramVal
            isDynamicLink = true
            vc.initializeCats()
          }
        }
      }
    }
      
    // if the link is a request to share
    if let _ = dict[LinkMaker.LinkTypes.share.rawValue] {
      if let wd = self.window {
        var vc = wd.rootViewController
        if(vc is UINavigationController){
          vc = (vc as! UINavigationController).visibleViewController
          if vc is CatsTableViewController {
            let vc = vc as! CatsTableViewController
            vc.share()
          }
        }
      }
    }
  }
  
  func parseLink(link: String) -> [String: String] {
    var params = [String: String]()
    let split = link.components(separatedBy: "?")
    for val in split {
      let param = val.components(separatedBy: "=")
      if param.count > 1 {
        let key = param[0]
        let val = param[1]
        params[key] = val
      }
    }
    return params
  }
}
