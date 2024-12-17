import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'campaign.dart';

class UserData {
  final String uid;
  late int userTier;
  late int userExp;
  late String username;
  late String bio;
  late Uint8List avatar;
  int currentlyPlaying = -1;
  bool showPlayer = false;

  //0 is locked, 1 is unlocked, 2 is completed
  List<int> moduleStatus = [1, 0, 0, 0];
  List<bool> achievements = [false, false, false, false];
  late DatabaseReference ref;

  UserData(this.uid);

  static Future<UserData> create(String uid) async {
    UserData udInstance = UserData(uid);
    udInstance.ref = FirebaseDatabase.instance.ref("users/$uid");
    udInstance.userTier = 0;
    final userTierSnapshot = await udInstance.ref.child('tier').get();
    if (userTierSnapshot.exists) {
      udInstance.userTier = userTierSnapshot.value as int;
    } else {
      udInstance.userTier = 0;
      await updateUserTier(udInstance.ref, 0);
    }
    udInstance.userExp = 0;
    final userExpSnapshot = await udInstance.ref.child('exp').get();
    if (userExpSnapshot.exists) {
      udInstance.userExp = userExpSnapshot.value as int;
    } else {
      udInstance.userExp = 0;
      await updateExp(udInstance.ref, 0);
    }
    udInstance.username = '';
    final usernameSnapshot = await udInstance.ref.child('username').get();
    if (usernameSnapshot.exists) {
      udInstance.username = usernameSnapshot.value as String;
    } else {
      udInstance.username = 'New Adventurer';
      updateUsername(udInstance.ref, udInstance.username, null, uid);
    }
    udInstance.bio = '';
    final bioSnapshot = await udInstance.ref.child('bio').get();
    if (bioSnapshot.exists) {
      udInstance.bio = bioSnapshot.value as String;
    } else {
      updateBio(udInstance.ref, udInstance.bio);
    }
    final storageRef = FirebaseStorage.instance.ref().child("$uid.jpg");
    udInstance.avatar = Uint8List(0);
    try {
      Uint8List? avatarData = await storageRef.getData();
      udInstance.avatar = avatarData ?? Uint8List(0);
    } catch (error) {
      if (error.toString() ==
          "[firebase_storage/object-not-found] No object exists at the desired reference.") {
        updateAvatar(uid, udInstance.avatar);
      }
    }

    DataSnapshot moduleStatusSnapshot;
    for (int x = 0; x < CampaignData.moduleCount; x++) {
      moduleStatusSnapshot =
          await udInstance.ref.child('moduleStatus/$x').get();
      if (moduleStatusSnapshot.exists) {
        udInstance.moduleStatus[x] = moduleStatusSnapshot.value as int;
      } else {
        await updateModuleStatus(udInstance.ref, x, udInstance.moduleStatus[x]);
      }
    }
    DataSnapshot achievementsSnapshot;
    for (int x = 0; x < 4; x++) {
      achievementsSnapshot =
          await udInstance.ref.child('achievements/$x').get();
      if (achievementsSnapshot.exists) {
        udInstance.achievements[x] = achievementsSnapshot.value as bool;
      } else {
        await udInstance.ref.child('achievements').update({
          "$x": false,
        });
      }
    }
    return udInstance;
  }
}

class FriendData {
  final UserData userData;

  //lfp=looking for party
  bool lfp = false;
  List<String> friends = [];
  List<String> friendRequests = [];
  List<String> flUsernames = [];
  List<String> frUsernames = [];
  List<String> lfpUsernames = [];
  List<String> lfpUids = [];
  Map<String, Uint8List> avatarsMap = {};

  FriendData(this.userData);

  static Future<FriendData> create(userData) async {
    FriendData fdInstance = FriendData(userData);
    final lfpSnapshot = await userData.ref.child('lfp').get();
    if (lfpSnapshot.exists) {
      fdInstance.lfp = lfpSnapshot.value as bool;
    } else {
      fdInstance.lfp = false;
      await updateLfp(userData.ref, false);
    }
    DataSnapshot friendsSnapshot;
    for (int x = 0; x < 150; x++) {
      friendsSnapshot = await userData.ref.child('friends/$x').get();
      if (friendsSnapshot.exists) {
        fdInstance.friends.add(friendsSnapshot.value as String);
      } else {
        break;
      }
    }
    DataSnapshot friendRequestsSnapshot;
    for (int x = 0; x < 150; x++) {
      friendRequestsSnapshot =
          await userData.ref.child('friend-requests/$x').get();
      if (friendRequestsSnapshot.exists) {
        fdInstance.friendRequests.add(friendRequestsSnapshot.value as String);
      } else {
        break;
      }
    }
    for (int x = 0; x < fdInstance.friends.length; x++) {
      fdInstance.flUsernames.add(await uidToUsername(fdInstance.friends[x]));
    }
    for (int x = 0; x < fdInstance.friendRequests.length; x++) {
      fdInstance.frUsernames
          .add(await uidToUsername(fdInstance.friendRequests[x]));
    }
    DatabaseReference lfpRef = FirebaseDatabase.instance.ref("users");
    Query lfpDataQuery = lfpRef.orderByChild("lfp").equalTo(true);

    DataSnapshot lfpDataSnapshot = await lfpDataQuery.get();
    List<DataSnapshot> lfpDataList =
        List<DataSnapshot>.from(lfpDataSnapshot.children);
    for (int x = 0; x < lfpDataList.length; x++) {
      fdInstance.lfpUids.add(lfpDataList[x].key.toString());
      fdInstance.lfpUsernames
          .add(lfpDataList[x].child("username").value.toString());
    }
    List<String> avatarsList = [];
    avatarsList.addAll(fdInstance.friends);
    avatarsList.addAll(fdInstance.friendRequests);
    avatarsList.addAll(fdInstance.lfpUids);
    avatarsList = avatarsList.toSet().toList();
    Uint8List? avatarsData;
    for (int x = 0; x < avatarsList.length; x++) {
      try {
        avatarsData = await FirebaseStorage.instance
            .ref()
            .child("${avatarsList[x]}.jpg")
            .getData();
      } catch (_) {}
      fdInstance.avatarsMap[avatarsList[x]] = avatarsData ?? Uint8List(0);
    }
    return fdInstance;
  }
}

Future<void> updateUsername(
    DatabaseReference ref, String name, String? oldName, String uid) async {
  await ref.update({
    "username": name,
  });
  DatabaseReference listRef = FirebaseDatabase.instance.ref("usernames");
  if (name != "New Adventurer") {
    await listRef.update({
      name: uid,
    });
  }
  if (oldName != null && oldName != "New Adventurer") {
    await listRef.child(oldName).remove();
  }
}

Future<void> updateBio(DatabaseReference ref, String bio) async {
  await ref.update({
    "bio": bio,
  });
}

Future<void> updateAvatar(String uid, Uint8List avatar) async {
  final storageRef = FirebaseStorage.instance.ref().child("$uid.jpg");
  await storageRef.putData(avatar);
}

Future<void> addFriend(DatabaseReference ref, String uid, String friendUid,
    int friendCount) async {
  DatabaseReference friendRef =
      FirebaseDatabase.instance.ref("users/$friendUid");
  //friend's friends
  int friendsFriendCount = 0;
  await ref.child("friends").update({"$friendCount": friendUid});
  DataSnapshot friend;
  for (int x = 0; x < 150; x++) {
    friend = await friendRef.child('friends/$x').get();
    if (friend.exists) {
      friendsFriendCount++;
    } else {
      break;
    }
  }
  await friendRef.child("friends").update({"$friendsFriendCount": uid});
}

Future<void> addFriendRequest(String uid, String friend) async {
  DatabaseReference listRef = FirebaseDatabase.instance.ref("usernames");
  DatabaseReference friendRef;
  DatabaseReference ref;
  String friendUid;
  int friendRequestsCount = 0;
  DataSnapshot friendUidSnapshot = await listRef.child(friend).get();
  if (friendUidSnapshot.exists) {
    friendUid = friendUidSnapshot.value as String;
    if (friendUid != uid) {
      ref = FirebaseDatabase.instance.ref("users/$uid");
      Query friendQuery =
          ref.child("friends").orderByValue().equalTo(friendUid);
      DataSnapshot friendSnapshot = await friendQuery.get();
      if (!friendSnapshot.exists) {
        friendRef = FirebaseDatabase.instance.ref("users/$friendUid");
        Query pendingQuery =
            ref.child("friend-requests").orderByValue().equalTo(friendUid);
        DataSnapshot pendingSnapshot = await pendingQuery.get();
        if (!pendingSnapshot.exists) {
          Query sentQuery =
              friendRef.child("friend-requests").orderByValue().equalTo(uid);
          DataSnapshot sentSnapshot = await sentQuery.get();
          if (!sentSnapshot.exists) {
            DataSnapshot friendRequest;
            for (int x = 0; x < 150; x++) {
              friendRequest = await friendRef.child('friend-requests/$x').get();
              if (friendRequest.exists) {
                friendRequestsCount++;
              } else {
                break;
              }
            }
            await friendRef
                .child("friend-requests")
                .update({"$friendRequestsCount": uid});
          } else {
            throw "A friend request to this Adventurer has already been sent.";
          }
        } else {
          throw "A friend request from this Adventurer is already pending.";
        }
      } else {
        throw "You are already friends with that Adventurer.";
      }
    } else {
      throw "You cannot add yourself as a friend.";
    }
  } else {
    throw "Adventurer not found.";
  }
}

Future<String> uidToUsername(String uid) async {
  DatabaseReference ref =
      FirebaseDatabase.instance.ref("users").child("$uid/username");
  DataSnapshot usernameSnapshot = await ref.get();
  if (usernameSnapshot.exists) {
    return usernameSnapshot.value as String;
  } else {
    return "User not found";
  }
}

Future<void> removeFriendRequest(DatabaseReference ref, int index) async {
  int oldIndex;
  DataSnapshot friendRequest;
  String newValue;
  await ref.child("friend-requests/$index").remove();
  for (int x = index; x < 150; x++) {
    oldIndex = x + 1;
    friendRequest = await ref.child("friend-requests/$oldIndex").get();
    if (friendRequest.exists) {
      newValue = friendRequest.value as String;
      await ref.child("friend-requests").update({"$x": newValue});
    } else {
      await ref.child("friend-requests/$x").remove();
      break;
    }
  }
}

Future<void> removeFriend(
    DatabaseReference ref, int index, String uid, String friendUid) async {
  int oldIndex;
  DataSnapshot friend;
  String newValue;
  int friendIndex;
  DatabaseReference friendRef =
      FirebaseDatabase.instance.ref("users/$friendUid");
  await ref.child("friends/$index").remove();
  for (int x = index; x < 150; x++) {
    oldIndex = x + 1;
    friend = await ref.child("friends/$oldIndex").get();
    if (friend.exists) {
      newValue = friend.value as String;
      await ref.child("friends").update({"$x": newValue});
    } else {
      await ref.child("friends/$x").remove();
      break;
    }
  }
  Query friendQuery = friendRef.child("friends").orderByValue().equalTo(uid);
  DataSnapshot friendSnapshot = await friendQuery.get();
  List<DataSnapshot> removedFriendList =
      List<DataSnapshot>.from(friendSnapshot.children);
  if (removedFriendList[0].exists && removedFriendList[0].key != null) {
    friendIndex = int.parse(removedFriendList[0].key!);
    await friendRef.child("friends/$friendIndex").remove();
    for (int x = friendIndex; x < 150; x++) {
      oldIndex = x + 1;
      friend = await friendRef.child("friends/$oldIndex").get();
      if (friend.exists) {
        newValue = friend.value as String;
        await friendRef.child("friends").update({"$x": newValue});
      } else {
        await friendRef.child("friends/$x").remove();
        break;
      }
    }
  }
}

Future<void> updateUserTier(DatabaseReference ref, int tier) async {
  await ref.update({
    "tier": tier,
  });
}

Future<void> updateExp(DatabaseReference ref, int exp) async {
  await ref.update({
    "exp": exp,
  });
}

Future<void> updateModuleStatus(
    DatabaseReference ref, int module, int newValue) async {
  await ref.child('moduleStatus').update({
    "$module": newValue,
  });
}

Future<void> updateAchievement(DatabaseReference ref, int achievement) async {
  await ref.child('achievements').update({
    "$achievement": true,
  });
}

Future<void> updateLfp(DatabaseReference ref, bool lfp) async {
  await ref.update({
    "lfp": lfp,
  });
}
