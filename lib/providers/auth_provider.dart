import 'package:dating_app/export.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

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
}
