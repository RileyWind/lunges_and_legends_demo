import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'homepage.dart';

class AuthApp extends StatelessWidget {
  const AuthApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        //scaffoldBackgroundColor: Colors.white,
        scaffoldBackgroundColor: backgroundColor,
        //canvasColor: Colors.transparent,
        canvasColor: backgroundColor,
        navigationRailTheme:
            //const NavigationRailThemeData(backgroundColor: Colors.white),
        const NavigationRailThemeData(backgroundColor: backgroundColor),
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(backgroundColor: backgroundColor),
        dialogTheme: DialogTheme(
          backgroundColor: backgroundColor,
          titleTextStyle: const TextStyle(
            textBaseline: TextBaseline.alphabetic,
            fontFamily: "FellEnglish",
            fontSize: 20.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            elevation: WidgetStateProperty.all(4.0),
            padding: WidgetStateProperty.all(EdgeInsets.all(0.0)),
            overlayColor:
                WidgetStateProperty.all(Colors.black.withOpacity(.035)),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
          ),
        ),
      ),
      //themeMode: ThemeMode.dark,
      //darkTheme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) {
          return SignInScreen(
            actions: [
              ForgotPasswordAction(
                ((context, email) {
                  Navigator.of(context).pushNamed('/forgot-password',
                      arguments: {'email': email});
                }),
              ),
              AuthStateChangeAction(
                ((context, state) {
                  if (state is UserCreated || state is SignedIn) {
                    var user = (state is SignedIn)
                        ? state.user
                        : (state as UserCreated).credential.user;
                    if (user == null) {
                      return;
                    }
                    if (!user.emailVerified && (state is UserCreated)) {
                      user.sendEmailVerification();
                    }
                    if (state is UserCreated) {
                      if (user.displayName == null && user.email != null) {
                        var defaultDisplayName = user.email!.split('@')[0];
                        user.updateDisplayName(defaultDisplayName);
                      }
                    }
                    Navigator.of(context).pushNamed('/homepage');
                  }
                }),
              ),
            ],
          );
        },
        '/forgot-password': ((context) {
          final arguments = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;

          return ForgotPasswordScreen(
            email: arguments?['email'] as String,
            headerMaxExtent: 200,
          );
        }),
        '/profile': ((context) {
          return ProfileScreen(
            providers: const [],
            actions: [
              SignedOutAction(
                ((context) {
                  Navigator.of(context).popUntil(ModalRoute.withName('/'));
                }),
              ),
            ],
          );
        }),
        '/homepage': (context) {
          return const HomeScreen();
        },
      },
    );
  }
}
