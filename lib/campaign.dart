import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'homepage.dart';
import 'user_data.dart';

class Campaign extends StatefulWidget {
  final UserData userData;
  final AudioPlayer _player;
  final Function _reload;

  Campaign(this.userData, this._player, this._reload, {Key? key})
      : super(key: key);

  @override
  State<Campaign> createState() => _CampaignState();
}

class _CampaignState extends State<Campaign> {
  double railSize = 0.0;
  double railAug = 0.0;
  int queueCount = 0;

  Future<void> _playModule(index) async {
    widget.userData.showPlayer = true;
    widget._reload();
    await widget._player.setAudioSource(CampaignData.audioSources[index]);
    widget.userData.currentlyPlaying = index;
    widget._player.play();
    widget._reload();
  }

  _modulePopup(int index) {
    if (index < CampaignData.moduleCount) {
      String reqText = "";
      String rewardText = "";
      if (widget.userData.moduleStatus[index] != 2) {
        rewardText =
            "\n\n600 XP reward available for completion of this module.";
      }
      if (CampaignData.moduleRequirements[index] != -1 &&
          widget.userData.moduleStatus[index] == 0) {
        reqText +=
            "\n\nRequirements: Complete Main Module ${CampaignData.moduleRequirements[index] + 1}";
        if (CampaignData.levelRequirements[index] != -1) {
          reqText +=
              " and reach Adventurer Level ${CampaignData.levelRequirements[index]}";
        }

        reqText += ".";
      }
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(CampaignData.titles[index]),
            content: SingleChildScrollView(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                        text: "${CampaignData.descriptions[index]}$reqText"),
                    TextSpan(
                      text: rewardText,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              widget.userData.moduleStatus[index] > 0
                  ? TextButton(
                      child: const Text("Play"),
                      onPressed: () {
                        _playModule(index);
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    )
                  : const SizedBox(),
              TextButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(CampaignData.titles[index]),
            content: SingleChildScrollView(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: CampaignData.descriptions[index]),
                    TextSpan(
                      text: "\n\nModule not yet released.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        },
      );
    }
    //}
  }

  Widget getIcon(int index) {
    Widget iconBase;
    if (index >= CampaignData.moduleCount) {
      iconBase = Container(
        padding: const EdgeInsets.only(bottom: 3, top: 5, left: 2, right: 2),
        child: const Icon(Icons.lock_outline, size: 36.0),
      );
    } else if (widget.userData.moduleStatus[index] == 0) {
      iconBase = Container(
        padding: const EdgeInsets.only(bottom: 3, top: 5, left: 2, right: 2),
        child: const Icon(Icons.lock_outline, size: 36.0),
      );
    } else if (index >= CampaignData.mainCount) {
      iconBase = Container(
        padding: const EdgeInsets.only(left: 1),
        child: Icon(
            widget.userData.moduleStatus[index] == 1
                ? Icons.error_outline
                : Icons.check_circle_outline,
            size: 40.0,
            color: widget.userData.moduleStatus[index] == 2
                ? const Color(0xFF708353)
                : Colors.orange),
      );
    } else {
      iconBase = Container(
        padding: const EdgeInsets.only(left: 1),
        child: Icon(
            widget.userData.moduleStatus[index] == 1
                ? Icons.new_releases_outlined
                : Icons.verified_outlined,
            size: 44.0,
            color: widget.userData.moduleStatus[index] == 2
                ? const Color(0xFF708353)
                : Colors.orange),
      );
    }
    return iconBase;
  }

  //position is the distance from the top and left of the map in units of map width(i.e .5 is middle of the map)
  double getInset(double position) {
    if (MediaQuery.of(context).size.width >= 1032) {
      return 800 * position - 32.0;
    }
    return (MediaQuery.of(context).size.width - railSize - railAug) * position -
        32.0;
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width >= 640) {
      railSize = 116.0;
    } else {
      railSize = 0.0;
    }
    if (MediaQuery.of(context).size.width >= 916) {
      railAug = 116.0;
    } else {
      railAug = 0.0;
    }
    return Expanded(
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: kElevationToShadow[2],
          ),
          margin: EdgeInsets.only(
            right: railAug,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 100.0,
              maxWidth: 800.0,
            ),
            child: SingleChildScrollView(
              child: IntrinsicHeight(
                child: Stack(
                  children: [
                    SizedBox.expand(
                        child: Image.asset("asset_files/map5.png",
                            fit: BoxFit.fitWidth)),
                    Positioned(
                      top: getInset(.12),
                      left: getInset(.5),
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        child: FloatingActionButton(
                          clipBehavior: Clip.hardEdge,
                          backgroundColor: backgroundColor,
                          heroTag: 0,
                          onPressed: () {
                            _modulePopup(0);
                          },
                          tooltip: CampaignData.titles[0],
                          child: getIcon(0),
                        ),
                      ),
                    ),
                    Positioned(
                      top: getInset(.6),
                      left: getInset(.2),
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        child: FloatingActionButton(
                          clipBehavior: Clip.hardEdge,
                          backgroundColor: backgroundColor,
                          heroTag: 1,
                          onPressed: () {
                            _modulePopup(1);
                          },
                          tooltip: CampaignData.titles[1],
                          child: getIcon(1),
                        ),
                      ),
                    ),
                    Positioned(
                      top: getInset(.35),
                      left: getInset(.6),
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        child: FloatingActionButton(
                          clipBehavior: Clip.hardEdge,
                          backgroundColor: backgroundColor,
                          heroTag: 2,
                          onPressed: () {
                            _modulePopup(2);
                          },
                          tooltip: CampaignData.titles[2],
                          child: getIcon(2),
                        ),
                      ),
                    ),
                    Positioned(
                      top: getInset(.3),
                      left: getInset(.2),
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        child: FloatingActionButton(
                          clipBehavior: Clip.hardEdge,
                          backgroundColor: backgroundColor,
                          heroTag: 3,
                          onPressed: () {
                            _modulePopup(3);
                          },
                          tooltip: CampaignData.titles[3],
                          child: getIcon(3),
                        ),
                      ),
                    ),
                    Positioned(
                      top: getInset(.75),
                      left: getInset(.53),
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        child: FloatingActionButton(
                          clipBehavior: Clip.hardEdge,
                          backgroundColor: backgroundColor,
                          heroTag: 4,
                          onPressed: () {
                            _modulePopup(4);
                          },
                          tooltip: CampaignData.titles[4],
                          child: getIcon(4),
                        ),
                      ),
                    ),
                    Positioned(
                      top: getInset(1.1),
                      left: getInset(.33),
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        child: FloatingActionButton(
                          clipBehavior: Clip.hardEdge,
                          backgroundColor: backgroundColor,
                          heroTag: 5,
                          onPressed: () {
                            _modulePopup(5);
                          },
                          tooltip: CampaignData.titles[5],
                          child: getIcon(5),
                        ),
                      ),
                    ),
                    Positioned(
                      top: getInset(1.15),
                      left: getInset(.15),
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        child: FloatingActionButton(
                          clipBehavior: Clip.hardEdge,
                          backgroundColor: backgroundColor,
                          heroTag: 6,
                          onPressed: () {
                            _modulePopup(6);
                          },
                          tooltip: CampaignData.titles[6],
                          child: getIcon(6),
                        ),
                      ),
                    ),
                    Positioned(
                      top: getInset(1.9),
                      left: getInset(.37),
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        child: FloatingActionButton(
                          clipBehavior: Clip.hardEdge,
                          backgroundColor: backgroundColor,
                          heroTag: 7,
                          onPressed: () {
                            _modulePopup(7);
                          },
                          tooltip: CampaignData.titles[7],
                          child: getIcon(7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CampaignData {
  //the number of main modules. If the index of the module is greater than or equal to this, it's a side module.
  static const int mainCount = 2;
  static const int moduleCount = 4;

  //if -1, no level requirement
  static const List<int> levelRequirements = [
    -1,
    2,
    -1,
    -1,
  ];
  static const List<int> moduleRequirements = [-1, 0, 0, 0];
  static const List<String> descriptions = [
    "Learn how to proceed through the app, have fun, and get in shape! Main exercises include stretches, squats, running, and  punches, and more.\n\nDuration: 12 minutes.",
    "Confront a dangerous decision with the help of a surprising mentor. Main exercises include jogging, running, lunges, modified burpees, planks, stretches and more.\n\nDuration: 16 minutes.",
    "Enjoy the satisfaction of a job well done with an unexpected call to heroism. Main exercises include Sit ups, swimmers and more.\n\nDuration: 4 minutes.",
    "Fight the zombies and keep your village safe. Main exercises include Punches, push-ups and more.\n\nDuration: 2 minutes.",
    "Cover diverse terrain while strengthening your resolve to rescue the helpless.",
    "Face the darkness as your diminutive guide reveals helpful magical powers.",
    "Go toward the source of the new dangers that you’ve been battling.",
    "Wait to see what's next in your journey!",
  ];
  static const List<String> titles = [
    "Module 1: Introduction",
    "Module 2: A New Danger",
    "Side Quest: Mermaid Harbor",
    "Side Quest: The Graveyard",
    "Module 3: Pursue and Rescue",
    "Module 4: Face the Darkness and Win",
    "Module 5: No Turning Back",
    "Module 6: The Story Continues",
  ];
  static final List<Uri> art = [
    Uri.parse("asset_files/dndPicture.jpg"),
    Uri.parse("asset_files/dndPicture.jpg"),
    Uri.parse("asset_files/dndDwarf.jpg"),
    Uri.parse("asset_files/dndDwarf.jpg"),
  ];
  static final audioSources = [
    AudioSource.uri(
      Uri.parse(
          "https://firebasestorage.googleapis.com/v0/b/lunges-and-legends.appspot.com/o/soundFiles%2FModule_1.mp3?alt=media&token=3df18f94-25b3-4851-9384-7b153c4109c6"),
      tag: MediaItem(
        id: '1',
        album: "Main Campaign",
        title: titles[0],
        artUri: art[0],
      ),
    ),
    AudioSource.uri(
      Uri.parse(
          "https://firebasestorage.googleapis.com/v0/b/lunges-and-legends.appspot.com/o/soundFiles%2FModule_2.mp3?alt=media&token=ef33fe6e-aeaf-496b-9af8-d6443cd539aa"),
      tag: MediaItem(
        id: '2',
        album: "Main Campaign",
        title: titles[1],
        artUri: art[1],
      ),
    ),
    AudioSource.uri(
      Uri.parse(
          "https://firebasestorage.googleapis.com/v0/b/lunges-and-legends.appspot.com/o/soundFiles%2FSide_Module_Mermaids.mp3?alt=media&token=f4be75c6-5531-44fa-8e2a-c5345d3b0a14"),
      tag: MediaItem(
        id: '3',
        album: "Side Quest",
        title: titles[2],
        artUri: art[2],
      ),
    ),
    AudioSource.uri(
      Uri.parse(
          "https://firebasestorage.googleapis.com/v0/b/lunges-and-legends.appspot.com/o/soundFiles%2FSide_Module_Graveyard.mp3?alt=media&token=32f85b29-7e12-429e-ba5d-24419259a89c"),
      tag: MediaItem(
        id: '4',
        album: "Side Quest",
        title: titles[3],
        artUri: art[3],
      ),
    ),
  ];
}
