import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grow_with_me/auth.dart';
import 'package:grow_with_me/core/widgets/bottom_navigation.dart';
import 'package:grow_with_me/models/user_model.dart';
import 'package:grow_with_me/services/user_service.dart';
import 'package:grow_with_me/screens/subject_screen.dart';

class LoginScreen extends StatefulWidget {
  final User? user;
  final bool requireProfileCompletion;

  const LoginScreen(
      {Key? key, this.user, this.requireProfileCompletion = false})
      : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final UserService _userService = UserService();
  bool _isProcessing = false;

  Future<void> _showNameInputDialog(User user) async {
    if (!mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Complete Your Profile',
            style: TextStyle(color: Color(0xFF76BE80)),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Please enter your name',
                  style: TextStyle(color: Colors.black87),
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF76BE80)),
                    ),
                  ),
                  cursorColor: Color(0xFF76BE80),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Submit',
                style: TextStyle(color: Color(0xFF76BE80)),
              ),
              onPressed: () async {
                if (_nameController.text.trim().isNotEmpty) {
                  try {
                    UserModel userData = UserModel(
                      uid: user.uid,
                      name: _nameController.text.trim(),
                      points: 0,
                    );

                    await _userService.createOrUpdateUser(userData);

                    if (!mounted) return;

                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            SubjectSelectionScreen(uid: user.uid)));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error saving profile: $e'),
                      backgroundColor: Colors.red,
                    ));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please enter a name'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.requireProfileCompletion && widget.user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNameInputDialog(widget.user!);
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAED),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Centered Image
            Expanded(
              child: Center(
                child: Image.asset(
                  'images/cactus-default.png',
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width * 0.8,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Grow With Me',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    width: 200,
                    child: const Text(
                      'Tempat dimana kita akan berkembang bersama',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        // fontWeight: FontWeight.bold,
                        color: const Color(0xff5F5F5F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () async {
                            if (_isProcessing) return;

                            setState(() {
                              _isProcessing = true;
                            });

                            try {
                              User? user = await Auth().signInWithGoogle();

                              if (user != null) {
                                UserModel? existingUser =
                                    await _userService.getUserData(user.uid);

                                if (!mounted) return;

                                if (existingUser == null) {
                                  await _showNameInputDialog(user);
                                } else {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SubjectSelectionScreen(
                                                  uid: user.uid)));
                                }
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('Sign-in failed: $e'),
                                backgroundColor: Colors.red,
                              ));
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isProcessing = false;
                                });
                              }
                            }
                          },
                    label: Text(
                      _isProcessing ? 'Signing in...' : 'Login',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff232323),
                      foregroundColor: Colors.white,
                      fixedSize: Size(343, 60),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
