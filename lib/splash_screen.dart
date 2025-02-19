import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:gloalo/main.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<String?> getCookies() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_cookies');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getCookies(),
      builder: (context, snapshot) {
        // Check if the Future is complete
        if (snapshot.connectionState == ConnectionState.done) {
          // Determine the next screen based on the presence of cookies
          final nextScreen =
              snapshot.data != null ?  MainPage() : HomeNotLoggedIn();
          return AnimatedSplashScreen(
            splash: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: LottieBuilder.asset("assets/animation/animation.json"),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF12BCC6),
            nextScreen: nextScreen,
            splashIconSize: 300,
          );
        }

        // Show a loading indicator while waiting for the Future
        return const Scaffold(
          backgroundColor: Color(0xFF12BCC6),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
