import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // Collection
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");

  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  // Updating user data
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid
    });
  }

  Future gettingDataUser(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  Future getGroupInformation(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  Future getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("message")
        .orderBy("time")
        .snapshots();
  }

  Future sendMessage(
      String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("message").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData["message"],
      "recentMessageSender": chatMessageData["sender"],
      "recentMessageTime": chatMessageData["time"].toString()
    });
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot["admin"];
  }

  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": ""
    });

    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  Future searchGroup(String name) async {
    return groupCollection.where("groupName", isEqualTo: name).get();
  }

  Future<bool> isUserJoined(
      String userName, String groupId, String groupName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot["groups"];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  Future toggleGroupJoin(
      String userName, String groupId, String groupName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    DocumentSnapshot userDocumentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await userDocumentSnapshot["groups"];
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }
}
