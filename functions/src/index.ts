// Copyright 2018 Google LLC

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//     https://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();
const db = admin.firestore();


export const bootstrapUserProfile = functions.auth.user().onCreate((user) => {
  console.log(user.providerData)

  if (user.providerData.length === 0) {
    // this is an anonymous user. No profile required
    console.log("anonymous user");
    return (Promise.resolve());
  }
  const displayName = user.displayName;
  const userId = user.uid;
  const userImage = user.photoURL;

  const userData = {
    name: displayName,
    userImage: userImage
  };
  
  return db.collection('users').doc(userId).set(userData);
});


export const updateLikesCount = functions.firestore.document("cats/{catId}/likes/{userId}").onWrite((change, context) => {
  const catId = context.params.catId;
  console.log(change.after)
  console.log(change.before)
  if (change.after.exists) {
    return updateLikes(true, catId);
  } else {
    return updateLikes(false, catId);
  }
})

async function updateLikes(add: Boolean, catId: string) {

  const likeDB = db.collection('cats').doc(catId);
  const transactionResult = await db.runTransaction(t => {
    return (async () => {
      const snap = await t.get(likeDB);
      const data = snap.data();
      let likes = data.likes
      if (!likes) {
        console.log("no other likes");
        return await t.update(likeDB, {likes: 1});
      }
      if (add) {
        likes += 1
        console.log(likes);
      } else {
        likes -=1
        console.log(likes);
      }
      await t.update(likeDB, { likes });
      return null;
    })();
  })
}
