import 'package:flutter/material.dart';

import 'homepage.dart';

class HelpPage extends StatefulWidget {
  int index;

  HelpPage(this.index, {Key? key}) : super(key: key);

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  static const List<String> titles = [
    "Campaign",
    "Character Sheet",
    "Friends List",
    "Settings",
    "Achievements",
    "What is Lunges and Legends?",
    "Safety",
  ];
  List<String> helpText = [
    "When you start, be prepared to work out. Start in an area where you have room to move around, and where you could get down onto the ground or floor if directed. Listen to the story and immerse yourself in the action.  Work as hard as you can while paying attention to your body; there will be times when you can rest as part of the story.  Listen and follow along." +
        "\n\n" +
        "You will gain experience points (XP) from doing a module, use the Character Sheet to track your progress and share with friends." +
        "\n\n" +
        "You progress through the story by doing the main story modules. After completing a main story module, you can proceed to the next module once you’ve reached the required level. You may also need to do side modules to increase your level.   You can see your current level on your character sheet, and you increase your level by completing modules." +
        "\n\n" +
        "You can repeat any module that is unlocked, enjoying the story and seeing how your fitness has increased. However, you do not gain experience from repeating modules.",
    "The Character Sheet tracks your progress and gives you your identity as a player." +
        "\n\n" +
        "When you do main or side modules, you gain experience points (XP.)" +
        "\n\n" +
        "Levels are benchmarks that are attained after earning a certain number of XP, and then XP gets reset to zero at each level. Levels track your power.  As you level up, you get access to more advanced modules." +
        "\n\n" +
        "Achievements are like medals that are awarded to show your accomplishments, such as modules completed, friends made, etc…" +
        "\n\n" +
        "Bio is where you can put your back story, as well as notes for yourself and for your friends.",
    "The Friends List is where you can connect with other Lunges and Legends users." +
        "\n\n" +
        "You can send a friend request or view others' requests to be your friend. Click any users profile picture to view their character sheet." +
        "\n\n" +
        "The Looking for Party section shows other users who you can add as a friend. You can check the box to mark yourself as looking for party, and this can be changed at any time.",
    "You can verify your email, sign out, or delete your account from the settings page. Verifying your email can help secure your account.",
    "Achievements are displayed on your character sheet and can be earned in a variety of ways.\n" +
        achievementLog(),
    "Lunges and Legends is a fantasy and workout game for people who enjoy the mythology and spirit of role playing games and are looking for a fun and motivating way to get in shape that doesn’t require any knowledge or equipment." +
        "\n\n" +
        "You can adjust any exercise to your level.  Please consult with a physician before starting on any exercise program." +
        "\n\n" +
        "In Lunges and Legends, you get instructions from the game master about the exercises to do as you act out the story. Use the map to unlock modules as you progress through the campaign." +
        "\n\n" +
        "Action and adventure will always be right around the corner, with every module having foes to defeat and fantastical places to explore.",
    "(from HopkinsMedicine.org) Practicing exercise safety helps optimize the health benefits of a fitness routine. When planning an exercise program, it’s important to consider factors such as age and health history as well as personal strength and stamina. Before starting an exercise routine, especially a potentially strenuous one, be sure to consult a health care professional for approval and safety guidelines." +
        "\n\n" +
        "To promote safety during physical activity, health experts usually suggest moderation and regularity. Some exercise safety precautions include wearing the appropriate gear and staying hydrated. Taking time to warm up and cool down allows the body to transition in and out of periods of activity safely.",
  ];
  final ScrollController _controller = ScrollController();

  void _scrollUp() {
    _controller.jumpTo(_controller.position.minScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index == 2) {}
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        canvasColor: backgroundColor,
      ),
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            leadingWidth: 72.0,
            toolbarHeight: 72.0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.white,
            flexibleSpace: Stack(
              alignment: Alignment.center,
              children: [
                MediaQuery.of(context).size.width > 400
                    ? Image.asset(
                        "asset_files/vintageribbon_sample_03.png",
                        filterQuality: FilterQuality.high,
                        opacity: const AlwaysStoppedAnimation(.8),
                      )
                    : SizedBox(),
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    "Help",
                    style: TextStyle(
                      textBaseline: TextBaseline.alphabetic,
                      fontFamily: "FellEnglish",
                      //fontFamily: "Cinzel",
                      fontSize: 26.0,
                    ),
                  ),
                )
              ],
            ),
            leading: IconButton(
              iconSize: 48.0,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ListView.builder(
              controller: _controller,
              itemCount: 1,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titles[widget.index],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        helpText[widget.index],
                      ),
                      Text("\nClick below to view another help page."),
                      widget.index == 0
                          ? const SizedBox()
                          : TextButton(
                              child: Text(titles[0]),
                              onPressed: () {
                                _scrollUp();
                                setState(() {
                                  widget.index = 0;
                                });
                              }),
                      widget.index == 1
                          ? const SizedBox()
                          : TextButton(
                              child: Text(titles[1]),
                              onPressed: () {
                                _scrollUp();
                                setState(() {
                                  widget.index = 1;
                                });
                              }),
                      widget.index == 2
                          ? const SizedBox()
                          : TextButton(
                              child: Text(titles[2]),
                              onPressed: () {
                                _scrollUp();
                                setState(() {
                                  widget.index = 2;
                                });
                              }),
                      widget.index == 3
                          ? const SizedBox()
                          : TextButton(
                              child: Text(titles[3]),
                              onPressed: () {
                                _scrollUp();
                                setState(() {
                                  widget.index = 3;
                                });
                              }),
                      widget.index == 4
                          ? const SizedBox()
                          : TextButton(
                              child: Text(titles[4]),
                              onPressed: () {
                                _scrollUp();
                                setState(() {
                                  widget.index = 4;
                                });
                              }),
                      widget.index == 5
                          ? const SizedBox()
                          : TextButton(
                              child: Text(titles[5]),
                              onPressed: () {
                                _scrollUp();
                                setState(() {
                                  widget.index = 5;
                                });
                              }),
                      widget.index == 6
                          ? const SizedBox()
                          : TextButton(
                              child: Text(titles[6]),
                              onPressed: () {
                                _scrollUp();
                                setState(() {
                                  widget.index = 6;
                                });
                              }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
