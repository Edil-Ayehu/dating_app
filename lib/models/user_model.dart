class UserModel {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final int age;
  final String bio;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.age,
    required this.bio,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      photoUrl: data['photoUrl'],
      age: data['age'],
      bio: data['bio'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'age': age,
      'bio': bio,
    };
  }
}