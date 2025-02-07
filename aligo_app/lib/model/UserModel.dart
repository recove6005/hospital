class UserModel {
  final bool admin;
  final String email;
  final String subscribe;
  final String uid;
  final bool verify;

  UserModel({
    required this.admin,
    required this.email,
    required this.subscribe,
    required this.uid,
    required this.verify,
  });


  Map<String, dynamic> toFirestore() {
    return {
      'admin': admin,
      'email': email,
      'subscribe': subscribe,
      'uid': uid,
      'verify': verify,
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
        admin: data['admin'],
        email: data['email'],
        subscribe: data['subscribe'],
        uid: data['uid'],
        verify: data['verify'],
    );
  }
}