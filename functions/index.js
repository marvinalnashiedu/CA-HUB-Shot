const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const userFollowersDocPath = "/followers/{userId}/userFollowers/{followerId}";

exports.onFollowUser = functions.firestore
  .document(userFollowersDocPath)

  .onCreate(async (_, context) => {
    const userId = context.params.userId;
    const followerId = context.params.followerId;
    const followedUserRef = admin.firestore().collection("users").doc(userId);
    const followedUserDoc = await followedUserRef.get();
    const followerCount = followedUserDoc.get("followers");
    if (followerCount !== undefined) {
      followedUserRef.update({ followers: followerCount + 1 });
    } else {
      followedUserRef.update({ followers: 1 });
    }

    const userRef = admin.firestore().collection("users").doc(followerId);
    const userDoc = await userRef.get();
    const followingCount = userDoc.get("following");
    if (followingCount !== undefined) {
      userRef.update({ following: followingCount + 1 });
    } else {
      userRef.update({ following: 1 });
    }

    const followedUserPostsRef = admin
      .firestore()
      .collection("posts")
      .where("author", "==", followedUserRef);
    const userFeedRef = admin
      .firestore()
      .collection("feeds")
      .doc(followerId)
      .collection("userFeed");
    const followedUserPostsSnapshots = await followedUserPostsRef.get();

    followedUserPostsSnapshots.forEach((postDoc) => {
      if (postDoc.exists) {
        userFeedRef.doc(postDoc.id).set(postDoc.data());
      }
    });
  });

exports.onUnfollowUser = functions.firestore
  .document(userFollowersDocPath)
  .onDelete(async (_, context) => {
    const userId = context.params.userId;
    const followerId = context.params.followerId;
    const followedUserRef = admin.firestore().collection("users").doc(userId);
    const followedUserDoc = await followedUserRef.get();
    const followerCount = followedUserDoc.get("followers");
    if (followerCount !== undefined) {
      followedUserRef.update({
        followers: followerCount - 1,
      });
    } else {
      followedUserRef.update({ followers: 0 });
    }
    const userRef = admin.firestore().collection("users").doc(followerId);
    const userDoc = await userRef.get();
    const followingCount = userDoc.get("following");
    if (followerCount !== undefined) {
      userRef.update({ following: followingCount - 1 });
    } else {
      userRef.update({ following: 0 });
    }
    const userFeedRef = admin
      .firestore()
      .collection("feeds")
      .doc(followerId)
      .collection("userFeed")
      .where("author", "==", followedUserRef);
    const userPostSnapshot = await userFeedRef.get();

    userPostSnapshot.forEach((postDoc) => {
      if (postDoc.exists) {
        postDoc.ref.delete();
      }
    });
  });


const postDocumentPath = "/posts/{postId}";
exports.onCreatePost = functions.firestore
  .document(postDocumentPath)
  .onCreate(async (snapshot, context) => {
    const postId = context.params.postId;
    const authorRef = snapshot.get("author");
    const authorId = authorRef.path.split("/")[1];
    const userFollowerRef = admin
      .firestore()
      .collection("followers")
      .doc(authorId)
      .collection("userFollowers");
    const userFollowerSnapshot = await userFollowerRef.get();

    userFollowerSnapshot.forEach((followerDoc) => {
      if (followerDoc.exists) {
        admin
          .firestore()
          .collection("feeds")
          .doc(followerDoc.id)
          .collection("userFeed")
          .doc(postId)
          .set(snapshot.data());
      }
    });
  });

exports.onUpdatePost = functions.firestore
  .document(postDocumentPath)
  .onUpdate(async (snapshot, context) => {
    const postId = context.params.postId;
    const authorRef = snapshot.after.get("author");
    const authorId = authorRef.path.split("/")[1];
    const userFollowerRef = admin
      .firestore()
      .collection("followers")
      .doc(authorId)
      .collection("userFollowers");
    const userFollowerSnapshot = await userFollowerRef.get();
    const updatedPostData = snapshot.after.data();

    userFollowerSnapshot.forEach(async (followerDoc) => {
      if (followerDoc.exists) {
        const postRef = admin
          .firestore()
          .collection("feeds")
          .doc(followerDoc.id)
          .collection("userFeed");

        const postDoc = await postRef.doc(postId).get();
        if (postDoc.exists) {
          postDoc.ref.update(updatedPostData);
        }
      }
    });
  });
