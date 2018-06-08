"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
exports.bootstrapUserProfile = functions.auth.user().onCreate((user) => {
    console.log(user.providerData);
    if (user.providerData.length === 0) {
        // this is an anonymous user. No profile required
        console.log("anonymous user");
        return (Promise.resolve());
    }
    const displayName = user.displayName;
    const userId = user.uid;
    const userImage = user.photoURL;
    // if (userImage) {
    // }
    const userData = {
        name: displayName,
        userImage: userImage
    };
    // Add a new document in collection "cities" with ID 'LA'
    return db.collection('users').doc(userId).set(userData);
});
exports.updateLikesCount = functions.firestore.document("cats/{catId}/likes/{userId}").onWrite((change, context) => {
    const catId = context.params.catId;
    console.log(change.after);
    console.log(change.before);
    if (change.after.exists) {
        return updateLikes(true, catId);
    }
    else {
        return updateLikes(false, catId);
    }
});
function updateLikes(add, catId) {
    return __awaiter(this, void 0, void 0, function* () {
        const likeDB = db.collection('cats').doc(catId);
        const transactionResult = yield db.runTransaction(t => {
            return (() => __awaiter(this, void 0, void 0, function* () {
                const snap = yield t.get(likeDB);
                const data = snap.data();
                let likes = data.likes;
                if (!likes) {
                    console.log("no other likes");
                    return yield t.update(likeDB, { likes: 1 });
                }
                if (add) {
                    likes += 1;
                    console.log(likes);
                }
                else {
                    likes -= 1;
                    console.log(likes);
                }
                yield t.update(likeDB, { likes });
                return null;
            }))();
        });
    });
}
// async function uploadImage(userImage: String) {
// }
//# sourceMappingURL=index.js.map