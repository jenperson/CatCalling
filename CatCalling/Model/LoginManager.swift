//
//  LoginManager.swift
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
import FirebaseUI

var isUser = false

class LoginManager: NSObject, FUIAuthDelegate {

  var authUI: FUIAuth?
  static let sharedInstance = LoginManager()
  var user: User?
  
  override init() {
    authUI = FUIAuth.defaultAuthUI()
    let providers: [FUIAuthProvider] = [
      FUIGoogleAuth(),
      ]
    self.authUI?.providers = providers
  }
  
  func checkLoginStatus(completion: @escaping (Bool) -> Void) {
    Auth.auth().addStateDidChangeListener { auth, user in
      if let currUser = auth.currentUser {
        if currUser.isAnonymous {
          completion(false)
          return
        }
        self.user = currUser
        completion(true)
      } else {
        Auth.auth().signInAnonymously(completion: nil)
      }
    }
  }

  
  func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
    // handle user and error as necessary
  }
  
  func signIn() {
    let authViewController = self.authUI!.authViewController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.window?.rootViewController?.present(authViewController, animated: true, completion: nil)
  }
  
  func signOut() {
    do {
      try self.authUI!.signOut()
    } catch {
      print("unable to logout")
    }
  }
}
