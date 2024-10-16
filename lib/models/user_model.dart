class UserModel {
  final String id;
  final String name;
  final String email;
  final int age;
  final String bio;
  final String gender;
  final String interestedIn;
  final String photoUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.bio,
    required this.gender,
    required this.interestedIn,
    required this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'bio': bio,
      'gender': gender,
      'interestedIn': interestedIn,
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      age: map['age'],
      bio: map['bio'],
      gender: map['gender'],
      interestedIn: map['interestedIn'],
      photoUrl: map['photoUrl'],
    );
  }

  UserModel copyWith({
  String? id,
  String? name,
  String? email,
  int? age,
  String? bio,
  String? gender,
  String? interestedIn,
  String? photoUrl,
}) {
  return UserModel(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    age: age ?? this.age,
    bio: bio ?? this.bio,
    gender: gender ?? this.gender,
    interestedIn: interestedIn ?? this.interestedIn,
    photoUrl: photoUrl ?? this.photoUrl,
  );
}
}