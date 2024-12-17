import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'character_sheet_friend.dart';
import 'homepage.dart';
import 'user_data.dart';

class FriendsList extends StatefulWidget {
  final UserData userData;
  final FriendData friendData;
  final AppBarData appBarData;
  final Function _reload;

  const FriendsList(
      this.userData, this.friendData, this.appBarData, this._reload,
      {Key? key})
      : super(key: key);

  @override
  State<FriendsList> createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  final ctrl = TextEditingController();
  DatabaseReference baseRef = FirebaseDatabase.instance.ref("usernames");
  DataSnapshot? friend;
  String? friendString;
  String sheetUid = "Error";
  bool friendSheet = false;
  bool friendsEmpty = true;
  bool requestsEmpty = true;
  bool lfpEmpty = true;
  List<bool> accLoading = [];

  //decline request loading
  List<bool> decLoading = [];

  //looking for party send request loading
  List<bool> lfpLoading = [];

  //manually send request loading
  bool frOpen = false;
  bool lfpOpen = false;
  bool friendsOpen = true;
  bool _mrLoading = false;
  List<Widget> listEmpty = [
    Text(
      "\nThere's nothing here yet!",
      textAlign: TextAlign.center,
      style: TextStyle(fontStyle: FontStyle.italic),
    )
  ];

  List<Widget> _requestList() {
    return List<Widget>.generate(widget.friendData.frUsernames.length,
        (int index) {
      accLoading.add(false);
      decLoading.add(false);
      if (widget.friendData.frUsernames[index] == "User not found") {
        return Container();
      }
      requestsEmpty = false;
      return Container(
        margin: const EdgeInsets.only(top: 6.0, left: 6.0, right: 6.0),
        decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(width: 1.0, color: Colors.black26),
            //boxShadow: kElevationToShadow[2],
            borderRadius: const BorderRadius.all(Radius.circular(18.0))),
        child: Row(
          children: [
            const SizedBox(
              width: 10.0,
            ),
            Center(
              child: IconButton(
                  tooltip: "View character sheet",
                  icon: getAvatar(widget.friendData.friendRequests[index]),
                  onPressed: () {
                    setState(() {
                      sheetUid = widget.friendData.friendRequests[index];
                      widget.appBarData.friendSheet = true;
                      widget.appBarData.backButton = 1;
                      widget._reload();
                    });
                  }),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Text(
                widget.friendData.frUsernames[index],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  tooltip: "Accept",
                  icon: accLoading[index]
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.check),
                  onPressed: () {
                    if (!accLoading[index] && !decLoading[index]) {
                      _replyFQ(true, index);
                    }
                  }),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  tooltip: "Decline",
                  icon: decLoading[index]
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.close),
                  onPressed: () {
                    if (!accLoading[index] && !decLoading[index]) {
                      _replyFQ(false, index);
                    }
                  }),
            ),
            const SizedBox(
              width: 10.0,
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _friendsList() {
    return List<Widget>.generate(widget.friendData.flUsernames.length,
        (int index) {
      if (widget.friendData.flUsernames[index] == "User not found") {
        return Container();
      }
      friendsEmpty = false;
      return Container(
        margin: const EdgeInsets.only(top: 6.0, left: 6.0, right: 6.0),
        decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(width: 1.0, color: Colors.black26),
            //boxShadow: kElevationToShadow[2],
            //border: Border.all(),
            borderRadius: const BorderRadius.all(Radius.circular(18.0))),
        child: Row(
          children: [
            const SizedBox(
              width: 10.0,
            ),
            Center(
              child: IconButton(
                  tooltip: "View character sheet",
                  icon: getAvatar(widget.friendData.friends[index]),
                  onPressed: () {
                    setState(() {
                      sheetUid = widget.friendData.friends[index];
                      widget.appBarData.friendSheet = true;
                      widget.appBarData.backButton = 1;
                      widget._reload();
                    });
                  }),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Text(
                widget.friendData.flUsernames[index],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: "Remove friend",
                icon: const Icon(Icons.close),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text(
                            "Are you sure you wish to remove this user from your friend's list?"),
                        actions: [
                          TextButton(
                            child: const Text("Confirm"),
                            onPressed: () {
                              removeFriend(
                                  widget.userData.ref,
                                  index,
                                  widget.userData.uid,
                                  widget.friendData.friends[index]);
                              setState(() {
                                widget.friendData.friends.removeAt(index);
                                widget.friendData.flUsernames.removeAt(index);
                              });
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _lfpList() {
    return List<Widget>.generate(widget.friendData.lfpUids.length, (int index) {
      lfpLoading.add(false);
      if (widget.userData.uid == widget.friendData.lfpUids[index]) {
        return Container();
      }
      for (int x = 0; x < widget.friendData.friends.length; x++) {
        if (widget.friendData.lfpUids[index] == widget.friendData.friends[x]) {
          return Container();
        }
      }
      lfpEmpty = false;
      return Container(
        margin: const EdgeInsets.only(top: 6.0, left: 6.0, right: 6.0),
        decoration: BoxDecoration(
            color: backgroundColor,
            //boxShadow: kElevationToShadow[2],
            border: Border.all(width: 1.0, color: Colors.black26),
            //border: Border.all(),
            borderRadius: const BorderRadius.all(Radius.circular(18.0))),
        child: Row(
          children: [
            const SizedBox(
              width: 10.0,
            ),
            Center(
              child: IconButton(
                  tooltip: "View character sheet",
                  icon: getAvatar(widget.friendData.lfpUids[index]),
                  onPressed: () {
                    setState(() {
                      sheetUid = widget.friendData.lfpUids[index];
                      widget.appBarData.friendSheet = true;
                      widget.appBarData.backButton = 1;
                      widget._reload();
                    });
                  }),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Text(
                widget.friendData.lfpUsernames[index],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  tooltip: "Add friend!",
                  icon: lfpLoading[index]
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.person_add),
                  onPressed: () {
                    if (!lfpLoading[index]) {
                      _sendRequest(
                          widget.friendData.lfpUsernames[index], index);
                    }
                  }),
            ),
            const SizedBox(
              width: 10.0,
            ),
          ],
        ),
      );
    });
  }

  Widget getAvatar(String uid) {
    if (widget.friendData.avatarsMap.containsKey(uid) &&
        !listEquals(widget.friendData.avatarsMap[uid], Uint8List(0))) {
      return Container(
        decoration: BoxDecoration(
          //boxShadow: kElevationToShadow[2],
          border: Border.all(color: Colors.black87, width: 2),
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          radius: 24.0,
          backgroundImage:
              Image.memory(widget.friendData.avatarsMap[uid]!).image,
          backgroundColor: Colors.black87,
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black87, width: 2),
          shape: BoxShape.circle,
        ),
        child: const CircleAvatar(
          radius: 24.0,
          backgroundColor: backgroundColor,
          child: Icon(
            Icons.person,
            color: Colors.black87,
          ),
        ),
      );
    }
  }

  Future<void> _replyFQ(bool accept, int index) async {
    if (accept) {
      addFriend(
          widget.userData.ref,
          widget.userData.uid,
          widget.friendData.friendRequests[index],
          widget.friendData.friends.length);
      setState(() {
        widget.friendData.friends.add(widget.friendData.friendRequests[index]);
        widget.friendData.flUsernames.add(widget.friendData.frUsernames[index]);
      });
    }
    removeFriendRequest(widget.userData.ref, index);
    setState(() {
      widget.friendData.friendRequests.removeAt(index);
      widget.friendData.frUsernames.removeAt(index);
    });
  }

  //index -1 for manually entered friend request, otherwise looking for party
  Future<void> _sendRequest(String friend, int index) async {
    if (index >= 0) {
      setState(() {
        lfpLoading[index] = true;
      });
    } else {
      _mrLoading = true;
    }
    try {
      await addFriendRequest(widget.userData.uid, friend);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Friend request sent."),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        },
      );
      setState(() {
        if (!widget.userData.achievements[3]) {
          widget.userData.achievements[3] = true;
          achievementPopup(context, 3);
          updateAchievement(widget.userData.ref, 3);
          widget._reload();
        }
        if (index >= 0) {
          lfpLoading[index] = false;
        } else {
          _mrLoading = false;
        }
      });
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(error.toString()),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        },
      );
      if (index >= 0) {
        setState(() {
          lfpLoading[index] = false;
        });
      } else {
        _mrLoading = false;
      }
      return;
    }
  }

  Future<void> _lfpChecked() async {
    updateLfp(widget.userData.ref, !widget.friendData.lfp);
    setState(() {
      widget.friendData.lfp = !widget.friendData.lfp;
    });
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double railAug;
    friendsEmpty = true;
    requestsEmpty = true;
    lfpEmpty = true;
    List<Widget> friendsList = _friendsList();
    List<Widget> requestList = _requestList();
    List<Widget> lfpList = _lfpList();

    double height = MediaQuery.of(context).size.height;
    if (MediaQuery.of(context).size.width >= 916) {
      railAug = 116.0;
    } else {
      railAug = 0.0;
    }
    return Flexible(
      child: Scaffold(
        body: Center(
          child: Container(
            decoration: widget.appBarData.friendSheet
                ? BoxDecoration(
                    boxShadow: kElevationToShadow[2],
                  )
                : null,
            margin: EdgeInsets.only(
              right: railAug,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 100.0,
                maxWidth: 800.0,
                minHeight: 100.0,
                maxHeight: 1600.0,
              ),
              child: widget.appBarData.friendSheet
                  ? CharacterSheetFriend(sheetUid)
                  : Column(
                      children: [
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 10.0, bottom: 16.0),
                                child: TextField(
                                  controller: ctrl,
                                  decoration: const InputDecoration(
                                    hintText: 'Add friend by name',
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () {
                                  if (_mrLoading == false) {
                                    _sendRequest(ctrl.text, -1);
                                  }
                                },
                                tooltip: "Add friend!",
                                icon: _mrLoading
                                    ? const CircularProgressIndicator()
                                    : const Icon(Icons.person_add),
                              ),
                            ),
                            const SizedBox(
                              width: 16.0,
                            ),
                          ],
                        ),
                        Flexible(
                          child: DefaultTabController(
                            length: 3,
                            child: Center(
                              //fit: BoxFit.contain,
                              child: Scaffold(
                                appBar: AppBar(
                                  automaticallyImplyLeading: false,
                                  toolbarHeight: 0,
                                  backgroundColor: backgroundColor,
                                  surfaceTintColor: backgroundColor,
                                  bottom: TabBar(
                                    tabs: [
                                      Tab(
                                        child: FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Text(
                                            "Friends",
                                            style: TextStyle(
                                              textBaseline:
                                                  TextBaseline.alphabetic,
                                              fontFamily: "FellEnglish",
                                              color: (Theme.of(context)
                                                          .iconTheme
                                                          .color ??
                                                      Colors.black)
                                                  .withOpacity(Theme.of(context)
                                                          .iconTheme
                                                          .opacity ??
                                                      .8),
                                              fontSize: lfpOpen ? 22 : 18.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Tab(
                                        child: FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Text(
                                            "Requests",
                                            style: TextStyle(
                                              textBaseline:
                                                  TextBaseline.alphabetic,
                                              fontFamily: "FellEnglish",
                                              color: (Theme.of(context)
                                                          .iconTheme
                                                          .color ??
                                                      Colors.black)
                                                  .withOpacity(Theme.of(context)
                                                          .iconTheme
                                                          .opacity ??
                                                      .8),
                                              fontSize: lfpOpen ? 22 : 18.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Tab(
                                        child: FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Text(
                                            "Looking for Party",
                                            style: TextStyle(
                                              textBaseline:
                                                  TextBaseline.alphabetic,
                                              fontFamily: "FellEnglish",
                                              color: (Theme.of(context)
                                                          .iconTheme
                                                          .color ??
                                                      Colors.black)
                                                  .withOpacity(Theme.of(context)
                                                          .iconTheme
                                                          .opacity ??
                                                      .8),
                                              fontSize: lfpOpen ? 22 : 18.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                body: TabBarView(
                                  children: [
                                    ListView(
                                      shrinkWrap: true,
                                      children: friendsEmpty
                                          ? listEmpty
                                          : _friendsList(),
                                    ),
                                    ListView(
                                      shrinkWrap: true,
                                      children: requestsEmpty
                                          ? listEmpty
                                          : _requestList(),
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Checkbox(
                                              value: widget.friendData.lfp,
                                              onChanged: (_) {
                                                _lfpChecked();
                                              },
                                            ),
                                            const Flexible(
                                              child: Text(
                                                "Make me visible in Looking for Party",
                                                overflow: TextOverflow.visible,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Flexible(
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: lfpEmpty
                                                ? listEmpty
                                                : _lfpList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
