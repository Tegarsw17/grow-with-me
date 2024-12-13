import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grow_with_me/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or update user in Firestore
  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(
            user.toMap(),
            SetOptions(merge: true), // This will update existing document
          );
    } catch (e) {
      print('Error creating/updating user: $e');
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> updatePoints(String uid, int pointsToAdd) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'points': FieldValue.increment(pointsToAdd)});
    } catch (e) {
      print('Error updating points: $e');
    }
  }
}
