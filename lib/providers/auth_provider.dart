import 'package:dating_app/export.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  UserModel? _currentUser;

  User? get user => _user;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // sign up (email and password)
  Future<UserCredential> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      throw e;
    }
  }

  // sign in (email and password)
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw e;
    }
  }

  // sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // method to create user profile
  Future<void> createUserProfile(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(user.toMap());
    } catch (e) {
      print('Error creating user profile: $e');
      throw e;
    }
  }

  // method to reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      throw e;
    }
  }

  // method to get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      if (_user == null) {
        print('Current user is null');
        return null;
      }
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      if (!userDoc.exists) {
        print('User document does not exist');
        return null;
      }
      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // method to update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }

Future<void> initializeCurrentUser() async {
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    if (userDoc.exists) {
      _currentUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      notifyListeners();
    }
  }
}

// method to get nearby users
Future<List<UserModel>> getNearbyUsers(UserModel currentUser, double radius, {int? limit}) async {
  try {
    final users = await FirebaseFirestore.instance
        .collection('users')
        .where('location', isNotEqualTo: null)
        .where('gender', isEqualTo: currentUser.gender == 'Male' ? 'Female' : 'Male')
        .get();

    List<UserModel> nearbyUsers = [];
    for (var doc in users.docs) {
      final user = UserModel.fromMap(doc.data());
      if (user.id != currentUser.id && user.location != null) {
        double distance = Geolocator.distanceBetween(
          currentUser.location!.latitude,
          currentUser.location!.longitude,
          user.location!.latitude,
          user.location!.longitude,
        );
        if (distance <= radius) {
          nearbyUsers.add(user);
          if (limit != null && nearbyUsers.length >= limit) break;
        }
      }
    }
    return nearbyUsers;
  } catch (e) {
    print('Error getting nearby users: $e');
    return [];
  }
}

Future<List<UserModel>> getBestMatches(UserModel currentUser, {int limit = 5}) async {
  try {
    final users = await FirebaseFirestore.instance
        .collection('users')
        .where('gender', isEqualTo: currentUser.gender == 'Male' ? 'Female' : 'Male')
        .get();

    List<UserModel> allUsers = users.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .where((user) => user.id != currentUser.id)
        .toList();

    allUsers.sort((a, b) {
      int aMatches = a.interests.where((interest) => currentUser.interests.contains(interest)).length;
      int bMatches = b.interests.where((interest) => currentUser.interests.contains(interest)).length;
      return bMatches.compareTo(aMatches);
    });

    return allUsers.take(limit).toList();
  } catch (e) {
    print('Error getting best matches: $e');
    return [];
  }
}
}
