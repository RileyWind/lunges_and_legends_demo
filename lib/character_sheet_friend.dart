import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'help_page.dart';
import 'homepage.dart';
import 'user_data.dart';

class CharacterSheetFriend extends StatefulWidget {
  final String friendUid;

  const CharacterSheetFriend(this.friendUid, {Key? key}) : super(key: key);

  @override
  CharacterSheetFriendState createState() => CharacterSheetFriendState();
}

class CharacterSheetFriendState extends State<CharacterSheetFriend> {
  late UserData otherData;
  late bool _loading = true;

  List<Widget> _displayAchievements() {
    return List<Widget>.generate(otherData.achievements.length, (int index) {
      if (otherData.achievements[index] == false) {
        return Container();
      }
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330.0, maxHeight: 1050.0),
        child: Text(
          AchievementData.achievementList[index],
          style: const TextStyle(
            fontFamily: 'King',
            fontSize: 36.0,
          ),
        ),
      );
    });
  }

  Route _createRouteAchievements() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return HelpPage(4);
      },
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0, 1);
        const end = Offset(0, 0);
        const curve = Curves.easeInCubic;
        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Future<void> _init() async {
    otherData = await UserData.create(widget.friendUid);

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    _init();
  }

  @override
  Widget build(BuildContext context) {
    double railAug = 0.0;
    Widget avatarImage;
    if (_loading == true) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                    Color(0xFFF6F2ED), BlendMode.modulate),
                child: Image.asset(
                  'asset_files/papertexture.png',
                  opacity: const AlwaysStoppedAnimation(1),
                  filterQuality: FilterQuality.high,
                  width: 4500.0,
                  height: 3000.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      );
    }
    if (!listEquals(otherData.avatar, Uint8List(0))) {
      avatarImage = Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          radius: 86,
          backgroundImage: Image.memory(otherData.avatar).image,
          backgroundColor: Colors.black,
        ),
      );
    } else {
      //print("here");
      avatarImage = Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          radius: 86,
          backgroundColor: Colors.white,
          child: Icon(Icons.person,
              size: 46, color: Theme.of(context).colorScheme.secondary),
        ),
      );
    }
    List<Widget> _displayList = _displayAchievements();
    _displayList.add(SizedBox(height: 40));
    _displayList.add(
      Padding(
        padding: EdgeInsets.only(right: 12),
        child: Image.asset("asset_files/vintageanimalemblem_normal_26.png",
            height: 134, width: 134, filterQuality: FilterQuality.high),
      ),
    );
    int currentExp = otherData.userExp % 1000;
    int lvl = (otherData.userExp - currentExp) ~/ 1000 + 1;
    Widget achievementButton = Align(
      alignment: Alignment.topRight,
      child: IconButton(
        iconSize: 46,
        icon: Icon(Icons.question_mark),
        onPressed: () => Navigator.of(context).push(_createRouteAchievements()),
        tooltip: "List of Achievements",
      ),
    );
    return SingleChildScrollView(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                //height: 1200.0,
                color: Colors.white,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                      Color(0xFFF6F2ED), BlendMode.modulate),
                  child: Image.asset(
                    'asset_files/papertexture.png',
                    opacity: const AlwaysStoppedAnimation(1),
                    filterQuality: FilterQuality.high,
                    width: 4500.0,
                    height: 3000.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.contain,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 748.0,
                              height: 83.0,
                              //padding: const EdgeInsets.all(12.0),
                              margin: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black87, width: 2),
                                shape: BoxShape.rectangle,
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 78.0),
                                  Text(
                                    'NAME',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 22.0,
                                    ),
                                  ),
                                  const SizedBox(width: 14.0),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxWidth: 382.0, minWidth: 382.0),
                                    child: Text(
                                      otherData.username ?? 'Unknown',
                                      style: const TextStyle(
                                        fontFamily: 'King',
                                        fontSize: 50,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 463.0,
                                  height: 83.0,
                                  //padding: const EdgeInsets.all(12.0),
                                  margin: const EdgeInsets.all(6.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black87, width: 2),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 12.0),
                                      const Text(
                                        'EXPERIENCE',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                          fontSize: 22.0,
                                        ),
                                      ),
                                      const SizedBox(width: 14.0),
                                      Text(
                                        '$currentExp/1000',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                          fontFamily: 'King',
                                          fontSize: 50.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 273.0,
                                  height: 83.0,
                                  margin: const EdgeInsets.all(6.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black87, width: 2),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 12.0),
                                      const Text(
                                        'LEVEL',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                          fontSize: 22.0,
                                        ),
                                      ),
                                      const SizedBox(width: 14.0),
                                      Text(
                                        '$lvl',
                                        style: const TextStyle(
                                          fontFamily: 'King',
                                          fontSize: 50.0,
                                          //),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            const SizedBox.square(
                              dimension: 190,
                            ),
                            Positioned.fill(
                              top: 0.0,
                              left: 0.0,
                              child: FittedBox(
                                fit: BoxFit.none,
                                alignment: Alignment.center,
                                child: avatarImage,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.contain,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 463.0,
                          height: 1000.0,
                          margin: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black87, width: 2),
                            shape: BoxShape.rectangle,
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                top: 21.0,
//left: 14.0,               left: 112.0,
//color: Colors.red,
                                child: Text(
                                  'BIO',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22.0,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                top: 17.0,
                                child: FittedBox(
                                  fit: BoxFit.none,
                                  alignment: Alignment.topCenter,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const SizedBox(height: 56),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                            maxWidth: 422.0, maxHeight: 896.0),
                                        child: Text(
                                          otherData.bio ?? 'Unknown',
                                          style: const TextStyle(
                                            fontFamily: 'King',
                                            fontSize: 36.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 463.0,
                          height: 1000.0,
                          margin: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black87, width: 2),
                            shape: BoxShape.rectangle,
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                top: 21.0,
                                child: Text(
                                  'ACHIEVEMENTS',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22.0,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8.0,
                                left: 20.5,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      maxWidth: 422.0,
                                      minWidth: 422.0,
                                      maxHeight: 896.0),
                                  child: Column(
                                    children: [
                                      achievementButton,
                                      ..._displayList
                                    ],
                                  ),
                                ),
                                //),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FittedBox(
              fit: BoxFit.contain,
              child: Stack(
                children: [
                  const SizedBox(
                    width: 998.0,
                    height: 1250.0,
                  ),
                  Positioned(
                    //left: -985,
                    //top: -992,
                    left: -123,
                    top: -11,

                    child: Transform.flip(
                      flipX: true,
                      child: Image.asset(
                          "asset_files/vintageanimalemblem_normal_17_cropped.png",
                          height: 250,
                          width: 250,
                          fit: BoxFit.fitHeight,
                          filterQuality: FilterQuality.high),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    //}
  }
}
