class UserModel {
  final String uid;
  final String name;
  int points;

  UserModel({required this.uid, required this.name, this.points = 0});

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'points': points,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      points: map['points'] ?? 0,
    );
  }
}
