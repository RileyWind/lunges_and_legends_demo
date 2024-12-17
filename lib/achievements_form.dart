import 'package:flutter/material.dart';

import 'help_page.dart';
import 'homepage.dart';
import 'user_data.dart';

class AchievementsForm extends StatelessWidget {
  final UserData userData;

  AchievementsForm(this.userData, {super.key});

  int achievementsLength = 0;

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

  List<Widget> _displayAchievements() {
    return List<Widget>.generate(userData.achievements.length, (int index) {
      if (userData.achievements[index] == false) {
        return Container();
      }
      return Text(
        AchievementData.achievementList[index],
        style: const TextStyle(
          fontFamily: 'King',
          fontSize: 36.0,
        ),
      );
    });
  }

  Widget build(BuildContext context) {
    List<Widget> _displayList = _displayAchievements();
    _displayList.add(SizedBox(height: 40));
    _displayList.add(
      Container(
        padding: EdgeInsets.only(right: 12),
        child: Image.asset("asset_files/vintageanimalemblem_normal_26.png",
            height: 134, width: 134, filterQuality: FilterQuality.high),
      ),
    );
    Widget achievementButton = Align(
      alignment: Alignment.topRight,
      child: IconButton(
        iconSize: 46,
        icon: Icon(Icons.question_mark),
        onPressed: () => Navigator.of(context).push(_createRouteAchievements()),
        tooltip: "List of Achievements",
      ),
    );
    late Widget iconButton;
    return ConstrainedBox(
      constraints: const BoxConstraints(
          maxWidth: 422.0, minWidth: 422.0, maxHeight: 896.0),
      child: Column(
        children: [achievementButton, ..._displayList],
      ),
    );
  }
}
