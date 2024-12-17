import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:lunges_and_legends/player_common.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'player.dart';
import 'friends_list.dart';
import 'character_sheet.dart';
import 'campaign.dart';
import 'user_data.dart';
import 'settings.dart';
import 'help_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late AudioPlayer _player;
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  final User _user = FirebaseAuth.instance.currentUser!;
  late String uid = _user!.uid;
  late DatabaseReference ref;
  late UserData userData;
  late FriendData friendData;
  late AppBarData appBarData;
  late Widget backButton;

  void _reload() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    _player = AudioPlayer();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ));
    _init();
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return AudioPlayerFull(_player, _scaffoldMessengerKey);
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

  Route _createRouteHelp(int index) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return HelpPage(index);
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

  void playerPopup(context, index, exp) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Module Complete!"),
          content: Text(
              "${CampaignData.titles[index]} completed for the first time. $exp XP earned."),
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
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    userData = await UserData.create(uid);
    friendData = await FriendData.create(userData);
    appBarData = AppBarData();
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        Navigator.popUntil(context, ModalRoute.withName('/homepage'));
        _showItemFinished(_player.currentIndex);
        _player.pause();
        _player.seek(Duration.zero);
        if (userData.moduleStatus[userData.currentlyPlaying] == 1) {
          if (!userData.achievements[0]) {
            userData.achievements[0] = true;
            achievementPopup(context, 0);
            updateAchievement(userData.ref, 0);
          } else if (!userData.achievements[1] &&
              userData.currentlyPlaying == 1) {
            userData.achievements[1] = true;
            achievementPopup(context, 1);
            updateAchievement(userData.ref, 1);
          }
          userData.userExp += 600;
          updateExp(userData.ref, userData.userExp);
          playerPopup(context, userData.currentlyPlaying, 600);
          userData.moduleStatus[userData.currentlyPlaying] = 2;
          bool unlock;
          int lvl = getLevel(userData.userExp);
          for (int x = 0; x < CampaignData.moduleCount; x++) {
            unlock = true;
            if (userData.moduleStatus[x] == 0) {
              if (CampaignData.moduleRequirements[x] != -1) {
                if (userData.moduleStatus[CampaignData.moduleRequirements[x]] !=
                    2) {
                  unlock = false;
                }
              }
              if (CampaignData.levelRequirements[x] != -1) {
                if (lvl < CampaignData.levelRequirements[x]) {
                  unlock = false;
                }
              }
              if (unlock) {
                userData.moduleStatus[x] = 1;
                updateModuleStatus(userData.ref, x, 1);
              }
            }
          }
        }
        updateModuleStatus(userData.ref, userData.currentlyPlaying, 2);
        setState(() {});
      }
    });
    setState(() {
      _isLoading = false;
    });
    if (userData.moduleStatus[0] == 1) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Welcome to Lunges and Legends!"),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: const Text(
                  "Lunges and Legends is a series of guided, immersive workouts you can listen to alone or as a group. Your character sheet will track your progress and the friends tab will let you connect with other users. The campaign tab is where you access the workouts, click the exclamation mark to get started!"),
            ),
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
    }
  }

  void _showItemFinished(int? index) {
    if (index == null) return;
    final sequence = _player.sequence;
    if (sequence == null) return;
    final source = sequence[index];
    final metadata = source.tag as MediaItem;
    _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text('Finished playing ${metadata.title}'),
      duration: const Duration(seconds: 2),
    ));
  }

  void menuSelected(index) {
    appBarData.backButton = 0;
    appBarData.friendSheet = false;
    appBarData.avatarEditor = false;
    setState(() {
      switch (index) {
        case 0:
          appBarData.appTitle = "Campaign";
          break;
        case 1:
          appBarData.appTitle = "Character Sheet";
          break;
        case 2:
          appBarData.appTitle = "Friends";
          break;
        case 3:
          appBarData.appTitle = "Settings";
          break;
      }
    });
  }

  @override
  void dispose() {
    ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    _player.dispose();
    super.dispose();
  }

  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (_isLoading == true) {
      return SafeArea(
          child: Container(
            color: backgroundColor,
          child: const Center(

        child: CircularProgressIndicator(),
            ),
      ));
    } else {
      backButton = const SizedBox();
      if (appBarData.backButton == 1) {
        backButton = IconButton(
          iconSize: 48.0,
          icon: const Icon(
            Icons.keyboard_arrow_left,
          ),
          onPressed: () {
            setState(() {
              appBarData.backButton = 0;
              appBarData.friendSheet = false;
            });
          },
        );
      } else if (appBarData.backButton == 2) {
        backButton = IconButton(
          iconSize: 48.0,
          icon: const Icon(
            Icons.keyboard_arrow_left,
          ),
          onPressed: () {
            setState(() {
              appBarData.backButton = 0;
              appBarData.avatarEditor = false;
            });
          },
        );
      }
      return SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Scaffold(
              appBar: AppBar(
                centerTitle: true,
                elevation: 4,
                leadingWidth: 72.0,
                toolbarHeight: 72.0,
                backgroundColor: Colors.white,
                shadowColor: Colors.black,
                surfaceTintColor: Colors.white,
                leading: backButton,
                flexibleSpace: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 0,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                            Color(0xFFF6F2ED), BlendMode.modulate),
                        child: Image.asset(
                          "asset_files/fantasy_border_long.png",
                          height: 72.0,
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.fitHeight,
                          opacity: const AlwaysStoppedAnimation(1),
                        ),
                      ),
                    ),
                    Image.asset(
                      "asset_files/vintageribbon_sample_03.png",
                      filterQuality: FilterQuality.high,
                      opacity: const AlwaysStoppedAnimation(1),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        appBarData.appTitle,
                        style: TextStyle(
                          textBaseline: TextBaseline.alphabetic,
                          fontFamily: "FellEnglish",
                          fontSize: 26.0,
                        ),
                      ),
                    )
                  ],
                ),
                actions: [
                  IconButton(
                    iconSize: 48.0,
                    onPressed: () => Navigator.of(context)
                        .push(_createRouteHelp(_selectedIndex)),
                    icon: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          "asset_files/vintageheraldic_normal_47_small.png",
                          width: 64.0,
                          height: 64.0,
                          filterQuality: FilterQuality.high,
                        ),
                        const Text(
                          "?",
                          style: TextStyle(
                            textBaseline: TextBaseline.alphabetic,
                            fontFamily: "FellEnglish",
                            fontSize: 32.0,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: MediaQuery.of(context).size.width < 640
                  ? Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: kElevationToShadow[4],
                            ),
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                  Color(0xFFF6F2ED), BlendMode.modulate),
                              //child:Image.asset('asset_files/antique_normalbox_aty_09.png',
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
                        BottomNavigationBar(
                            currentIndex: _selectedIndex,
                            unselectedItemColor: (Theme.of(context)
                                        .iconTheme
                                        .color ??
                                    Colors.black)
                                .withOpacity(
                                    Theme.of(context).iconTheme.opacity ?? .8),
                            selectedItemColor: const Color(0xFF708353),
                            elevation: 0,
                            onTap: (int index) {
                              setState(() {
                                menuSelected(index);
                                _selectedIndex = index;
                              });
                            },
                            items: const [
                              BottomNavigationBarItem(
                                  icon: Icon(Icons.home), label: 'Campaign'),
                              BottomNavigationBarItem(
                                  icon: Icon(Icons.table_chart_outlined),
                                  label: 'Character Sheet'),
                              BottomNavigationBarItem(
                                  icon: Icon(Icons.groups), label: 'Friends'),
                              BottomNavigationBarItem(
                                  icon: Icon(Icons.settings),
                                  label: 'Settings'),
                            ]),
                      ],
                    )
                  : null,
              body: Row(
                children: [
                  if (MediaQuery.of(context).size.width >= 640)
                    NavigationRail(
                      onDestinationSelected: (int index) {
                        setState(() {
                          menuSelected(index);
                          _selectedIndex = index;
                        });
                      },
                      selectedIndex: _selectedIndex,
                      destinations: [
                        NavigationRailDestination(
                            icon: Icon(Icons.home), label: Text('Campaign')),
                        NavigationRailDestination(
                            icon: Icon(Icons.table_chart_outlined),
                            label: Text('Character Sheet')),
                        NavigationRailDestination(
                            icon: Icon(Icons.groups), label: Text('Friends')),
                        NavigationRailDestination(
                            icon: Icon(Icons.settings),
                            label: Text('Settings')),
                      ],
                      labelType: NavigationRailLabelType.all,
                      selectedLabelTextStyle: const TextStyle(
                        color: const Color(0xFF708353),
                      ),
                      indicatorColor: Colors.black.withOpacity(.07),
                      unselectedLabelTextStyle: const TextStyle(),
                    ),
                  if (_selectedIndex == 0) Campaign(userData, _player, _reload),
                  if (_selectedIndex == 1)
                    CharacterSheet(userData, appBarData, _reload),
                  if (_selectedIndex == 2)
                    FriendsList(userData, friendData, appBarData, _reload),
                  if (_selectedIndex == 3) Settings(userData),
                ],
              ),
            ),
            !userData.showPlayer
                ? const SizedBox()
                : Positioned(
                    bottom: MediaQuery.of(context).size.width < 640 ? 58 : 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 6.0),
                        decoration: BoxDecoration(
                            //boxShadow: kElevationToShadow[2],
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(18.0)),
                        constraints: const BoxConstraints(
                            minWidth: 200.0, maxWidth: 640.0),
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.of(context).push(_createRoute()),
                          child: Material(
                            borderRadius: BorderRadius.circular(18.0),
                            color: Colors.transparent,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 6.0),
                                  decoration: BoxDecoration(
                                      // boxShadow: kElevationToShadow[2],
                                      color: Colors.blueGrey.shade900
                                          .withOpacity(0.7),
                                      borderRadius:
                                          BorderRadius.circular(18.0)),
                                  height: 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: StreamBuilder<SequenceState?>(
                                          stream: _player.sequenceStateStream,
                                          builder: (context, snapshot) {
                                            final state = snapshot.data;
                                            if (state?.sequence.isEmpty ??
                                                true) {
                                              return const SizedBox();
                                            }
                                            final metadata = state!
                                                .currentSource!
                                                .tag as MediaItem;
                                            return Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                      child: Image.asset(
                                                    metadata.artUri.toString(),
                                                  )),
                                                ),
                                                Flexible(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(metadata.title,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    color: Colors
                                                                        .white)),
                                                        const SizedBox(
                                                          height: 2.0,
                                                        ),
                                                        Text(
                                                            metadata.album
                                                                as String,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .white38)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          StreamBuilder<PlayerState>(
                                            stream: _player.playerStateStream,
                                            builder: (context, snapshot) {
                                              final playerState = snapshot.data;
                                              final processingState =
                                                  playerState?.processingState;
                                              final playing =
                                                  playerState?.playing;
                                              if (processingState ==
                                                      ProcessingState.loading ||
                                                  processingState ==
                                                      ProcessingState
                                                          .buffering) {
                                                return Container(
                                                  margin:
                                                      const EdgeInsets.all(8.0),
                                                  width: 64.0,
                                                  height: 64.0,
                                                  child:
                                                      const CircularProgressIndicator(),
                                                );
                                              } else if (playing != true) {
                                                return IconButton(
                                                  icon: const Icon(
                                                      Icons.play_arrow),
                                                  color: Colors.white,
                                                  iconSize: 48.0,
                                                  onPressed: _player.play,
                                                );
                                              } else if (processingState !=
                                                  ProcessingState.completed) {
                                                return IconButton(
                                                  icon: const Icon(Icons.pause),
                                                  color: Colors.white,
                                                  iconSize: 48.0,
                                                  onPressed: _player.pause,
                                                );
                                              } else {
                                                return IconButton(
                                                  icon:
                                                      const Icon(Icons.replay),
                                                  color: Colors.white,
                                                  iconSize: 48.0,
                                                  onPressed: () => _player.seek(
                                                      Duration.zero,
                                                      index: _player
                                                          .effectiveIndices!
                                                          .first),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 1.0),
                                  child: StreamBuilder<PositionData>(
                                    stream: positionDataStream,
                                    builder: (context, snapshot) {
                                      final positionData = snapshot.data;
                                      double position =
                                          ((positionData?.position ??
                                                  Duration.zero)
                                              .inMicroseconds
                                              .toDouble());
                                      if (position < 0.0) {
                                        position = 0.0;
                                      }
                                      double duration;

                                      duration = (positionData?.duration ??
                                              const Duration(
                                                  seconds: 100000000000000))
                                          .inMicroseconds
                                          .toDouble();
                                      if (duration <= 0.0) {
                                        duration = 100000000000000.0;
                                      }
                                      return SliderTheme(
                                        data: SliderThemeData(
                                            //disabledActiveTrackColor: Colors.blueGrey.shade400,
                                            disabledActiveTrackColor:
                                                Colors.white,
                                            disabledInactiveTrackColor:
                                                Colors.white.withOpacity(0.0),
                                            trackHeight: 4.0,
                                            overlayShape:
                                                const RoundSliderOverlayShape(
                                                    overlayRadius: 0),
                                            thumbShape:
                                                SliderComponentShape.noOverlay),
                                        child: Slider(
                                          value: position / duration > 1
                                              ? 1
                                              : position / duration,
                                          onChanged: null,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      );
    }
  }
}

class AchievementData {
  static List<String> achievementList = [
    //complete the first campaign module
    "A New Journey",
    //complete the second campaign module
    "Fearless in the Forest",
    //change your avatar picture
    "The Hero Unmasked",
    //Add a friend.
    "Branching Out",
  ];
  static List<String> achievementReqs = [
    "Complete the first module.",
    "Complete the second module.",
    "Change your avatar picture.",
    "Send a friend request.",
  ];
}

String achievementLog() {
  String achievementLog = "";
  for (int x = 0; x < AchievementData.achievementList.length; x++) {
    achievementLog += "\n" +
        AchievementData.achievementList[x] +
        ": " +
        AchievementData.achievementReqs[x];
  }
  return achievementLog;
}

void achievementPopup(context, index) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Achievement Earned!"),
        content: Text(
            "\"${AchievementData.achievementList[index]}\": ${AchievementData.achievementReqs[index]}"),
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
}

class AppBarData {
  int backButton = 0;
  String appTitle = "Campaign";
  bool friendSheet = false;
  bool avatarEditor = false;
}

const backgroundColor=Color(0xFFFAF9F6);
