import 'package:flutter/material.dart';
import 'package:grow_with_me/auth.dart';
import 'package:grow_with_me/screens/home_screen.dart';
import 'package:grow_with_me/screens/subject_screen.dart';
import 'package:grow_with_me/screens/wardrobe_screen.dart';

class BottomBar extends StatelessWidget {
  final String uid;
  final String currentScreen; // Track active screen

  const BottomBar({
    super.key,
    required this.uid,
    required this.currentScreen,
  });

  Color _getIconColor(String screenName) {
    return currentScreen == screenName ? const Color(0xFF76BE80) : Colors.white;
  }

  // Helper method to create background decoration
  BoxDecoration _getBackgroundDecoration(String screenName) {
    return BoxDecoration(
      color: currentScreen == screenName
          ? const Color(0xFF76BE80).withOpacity(0.5)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(25),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: _getBackgroundDecoration('profile'),
            child: IconButton(
              icon: Icon(
                Icons.person,
                color: _getIconColor('profile'),
                size: 24,
              ),
              // onPressed: () => Auth().signOut(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WardrobeScreen(uid: uid),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: _getBackgroundDecoration('home'),
            child: IconButton(
              icon: Icon(
                Icons.home,
                color: _getIconColor('home'),
                size: 24,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(uid: uid),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: _getBackgroundDecoration('subjects'),
            child: IconButton(
              icon: Icon(
                Icons.menu,
                color: _getIconColor('subjects'),
                size: 24,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubjectSelectionScreen(uid: uid),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
