import 'package:flutter/material.dart';

import 'achievements_form.dart';
import 'avatar_form.dart';
import 'bio_form.dart';
import 'homepage.dart';
import 'name_form.dart';
import 'user_data.dart';

class CharacterSheet extends StatefulWidget {
  final UserData userData;
  final AppBarData appBarData;
  final Function _reload;

  const CharacterSheet(this.userData, this.appBarData, this._reload, {Key? key})
      : super(key: key);

  @override
  CharacterSheetState createState() => CharacterSheetState();
}

class CharacterSheetState extends State<CharacterSheet> {
  late int currentExp;
  late int lvl;

  late double railAug;

  void _reloadAvatar() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width >= 916) {
      railAug = 116.0;
    } else {
      railAug = 0.0;
    }
    int currentExp = widget.userData.userExp % 1000;
    lvl = getLevel(widget.userData.userExp);
    return Expanded(
      child: Center(
        child: Container(
          decoration: widget.appBarData.avatarEditor
              ? null
              : BoxDecoration(
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
            child: widget.appBarData.avatarEditor
                ? AvatarFormPopup(
                    widget.userData, widget.appBarData, _reloadAvatar)
                : SingleChildScrollView(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Stack(
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
                                            margin: const EdgeInsets.all(6.0),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black87,
                                                  width: 2),
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
                                                NameForm(widget.userData),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 463.0,
                                                height: 83.0,
                                                margin:
                                                    const EdgeInsets.all(6.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black87,
                                                      width: 2),
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
                                                //padding: const EdgeInsets.all(12.0),
                                                margin:
                                                    const EdgeInsets.all(6.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black87,
                                                      width: 2),
                                                  shape: BoxShape.rectangle,
                                                  //borderRadius: ,
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
                                                    //Align(
                                                    //alignment: Alignment.topCenter,
                                                    Text(
                                                      '$lvl', //textAlign: TextAlign.left,
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
                                            child: AvatarForm(
                                                widget.userData,
                                                widget.appBarData,
                                                widget._reload),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 463.0,
                                        height: 1000.0,
                                        margin: const EdgeInsets.all(6.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black87, width: 2),
                                          shape: BoxShape.rectangle,
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              top:
                                                  21.0, //left: 14.0,               left: 112.0,
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
                                              top: 8.0, //right: 10.0,
//color: Colors.red,
                                              child: BioForm(widget.userData),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 463.0,
                                        height: 1000.0,
                                        //padding: const EdgeInsets.all(12.0),
                                        margin: const EdgeInsets.all(6.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black87, width: 2),
                                          shape: BoxShape.rectangle,
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              top:
                                                  21.0, //left: 14.0,               left: 112.0,
//color: Colors.red,
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
                                              left: 20.5, //color: Colors.red,
                                              child: AchievementsForm(
                                                  widget.userData),
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
                  ),
          ),
        ),
      ),
    );
  }
}

int getLevel(exp) {
  int currentExp = exp % 1000;
  return (exp - currentExp) ~/ 1000 + 1;
}
