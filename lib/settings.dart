import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'profile_screen_internal.dart';
import 'user_data.dart';

class Settings extends StatefulWidget {
  final UserData userData;

  const Settings(this.userData, {Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  double railAug = 0.0;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width >= 916) {
      railAug = 116.0;
    } else {
      railAug = 0.0;
    }
    return Expanded(
      child: Center(
        child: Container(
          margin: EdgeInsets.only(
            right: railAug,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 100.0,
              maxWidth: 800.0,
            ),
            child: ProfileScreenInternal(
              providers: const [],
              actions: [
                SignedOutAction(
                  ((context) {
                    Navigator.of(context).pop();
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
