import 'package:dating_app/export.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dating_app/providers/auth_provider.dart' as app_auth;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

Future<void> _checkAuthState() async {
  await Future.delayed(Duration(seconds: 2)); // Simulating a splash screen delay

  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // User is logged in, initialize AuthProvider and navigate to HomeScreen
    final authProvider = context.read<app_auth.AuthProvider>();
    await authProvider.initializeCurrentUser();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Home()),
    );
  } else {
    // User is not logged in, navigate to LoginScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Theme.of(context).colorScheme.primary,
          size: 50,
        ),
      ),
    );
  }
}
