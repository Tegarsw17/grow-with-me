import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grow_with_me/auth.dart';
import 'package:grow_with_me/models/user_model.dart';
import 'package:grow_with_me/screens/home_screen.dart';
import 'package:grow_with_me/screens/login_screen.dart';
import 'package:grow_with_me/screens/subject_screen.dart';
import 'package:grow_with_me/services/user_service.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        // Add more robust state handling
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            // Check if user profile is complete before routing
            return FutureBuilder<UserModel?>(
              future: UserService().getUserData(user.uid),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.done) {
                  if (userSnapshot.data != null) {
                    // User exists and has a profile
                    return HomeScreen(uid: user.uid);
                  } else {
                    // User exists but needs to complete profile
                    return LoginScreen(
                        user: user, requireProfileCompletion: true);
                  }
                }
                // Show loading indicator while checking user data
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            );
          } else {
            // No user logged in
            return LoginScreen();
          }
        }

        // Show loading state during authentication check
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
