class UserModel {
  final String id;
  final String name;
  final String email;
  final int age;
  final String bio;
  final String about;
  final String gender;
  final String interestedIn;
  final List<String> photoUrls;
  final List<String> interests;
  final String city;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.bio,
    required this.about,
    required this.gender,
    required this.interestedIn,
    required this.photoUrls,
    required this.interests,
    required this.city,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'bio': bio,
      'about': about,
      'gender': gender,
      'interestedIn': interestedIn,
      'photoUrls': photoUrls,
      'interests': interests,
      'city': city,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      age: map['age'],
      bio: map['bio'],
      about: map['about'] ?? '',
      gender: map['gender'],
      interestedIn: map['interestedIn'],
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      city: map['city'] ?? '',
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? bio,
    String? about,
    String? gender,
    String? interestedIn,
    List<String>? photoUrls,
    List<String>? interests,
    String? city,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      about: about ?? this.about,
      gender: gender ?? this.gender,
      interestedIn: interestedIn ?? this.interestedIn,
      photoUrls: photoUrls ?? this.photoUrls,
      interests: interests ?? this.interests,
      city: city ?? this.city,
    );
  }
}
