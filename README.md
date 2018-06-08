# CatCalling

This repository contains an iOS app used in a talk I gave at AltConf 2018. It showcases some interesting use cases for Firebase, incorporating the following features:
* Cloud Firestore
* Firebase Authentication
* Cloud Storage for Firebase
* MLKit for Firebase
* Firebase Dynamic Links

## Prerequisites

* Xcode 9.4 or later
* CocoaPods 1.4.0 or later
* An Apple Developer account (this is required to use associated domains, which are used in Dynamic Links)

## How to set up this app

This app uses Firebase Authentication with email/password and Google, Cloud Firestore, Cloud Storage, Dynamic Links, and MLKit for Firebase. This means setup for all of these features is required. The steps listed below should get you started. I've included a link for each feature in case more assistance is needed.

### Firebase Console setup

1. Create a new iOS app in a new or existing Firebase project. Be sure to make the bundle ID of the new app **com.catcalling** so it aligns with the Xcode project. For instructions on creating a new project, check out the [guide](https://firebase.google.com/docs/ios/setup) in Firebase's documentation.
1. In the Firebase Console, select the *Authentication* tab from the sidebar. Enable email/password and Google Authentication. You can see more info on Firebase Authentication in the [guides](https://firebase.google.com/docs/auth/).
1. In the Firebase Console, selecte the *Database* tab from the sidebar. Enable Cloud Firestore.
1. Once Cloud Firestore is enabled, select the *RULES* tab and replace the rules with the following: 
```
    service cloud.firestore {
      match /databases/{database}/documents {
        match /{document=**} {
          allow read, write: if request.auth.uid != null;
        }
      }
    }
```
  Then select *PUBLISH*. See the [guide](https://firebase.google.com/docs/firestore/quickstart) for more info.
1. In the Firebase Console, select the *Storage* tab from the sidebar. Enable Cloud Storage if it is not already enabled.
1. In order to use Imgix, you'll need to go to imgix.com, create an account, and link your Firebase credentials to enable Imgix to mirror your Cloud Storage bucket. If you do not wish to do this, then images will not show by default. You will still be able to see images when the app is running by selecting Settings and toggling off "use Imgix".
1. In the Firebase Console, select the *Dynamic Links* tab from the sidebar. Accept the terms if you have not already done so. Copy the Dynamic Link domain. For more help with Dynamic Links, check out the [guides](https://firebase.google.com/docs/dynamic-links/ios/create).
1. In the Firebase console, Download the `GoogleService-Info.plist` if you haven't done so already.

### Xcode setup

1. In the Xcode project, under Capabilities, you'll see Associated Domains. Add the Dynamic Link as an associated domain in the format applinks:kdfj.app.goo.gl. If you're stuck, check out the [guides](https://firebase.google.com/docs/dynamic-links/ios/create)
1. Drag the `GoogleService-Info.plist` file you downloaded earlier into the Xcode project. The name of the plist must be `GoogleService-Info.plist`, so if you have multiple downloaded and this one is named `GoogleService-Info (2).plist`, for example, be sure to rename it. See the [setup guide](https://firebase.google.com/docs/ios/setup) for more info.
1. In the Xcode project, under the Info tab, you'll see URL types. Your `REVERSED_CLIENT_ID` will go here. Copy the `REVERSED_CLIENT_ID `from the `GoogleService-info.plist` and paste it where the placeholder text `REVERSED_CLIENT_ID` is found. An example can be found in the [guides](https://firebase.google.com/docs/auth/ios/google-signin#2_implement_google_sign_in).

### Terminal setup

1. From the terminal, change to the directory of the project and run pod install to download the required dependencies.
1. From the terminal, change to the directory of `functions`
1. Run the following commands:
```
npm install firebase-functions@latest firebase-admin@latest --save
npm install -g firebase-tools
```
1. Run firebase login to log in via the browser and authenticate the firebase tool.
1. Set up the Firebase CLI to use your Firebase Project using this command:
```
firebase use --add
```
Then select your Project ID and follow the instructions. When prompted, you can choose any Alias.

### Final steps

1. After running pod commands, it's always a good idea to quit Xcode if it is running. Open **CatCalling.xcworkspace**. This is the file you will open from now on.
1. Once all the above features are configured, you can run the project.
