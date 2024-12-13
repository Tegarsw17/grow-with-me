import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grow_with_me/firebase_options.dart';
import 'package:grow_with_me/screens/login_screen.dart';
import 'package:grow_with_me/screens/level_screen.dart';
import 'package:grow_with_me/screens/quiz_screen.dart';
import 'package:grow_with_me/screens/subject_screen.dart';
import 'package:grow_with_me/widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Comic Sans MS',
      ),
      // home: const SubjectSelectionScreen(),
      home: const WidgetTree(),
    );
  }
}
