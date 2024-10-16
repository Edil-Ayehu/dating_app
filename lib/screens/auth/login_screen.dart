import 'package:dating_app/export.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = true}) {
    Flushbar(
      message: message,
      icon: Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
          size: 28.0, color: isError ? Colors.red[300] : Colors.green[300]),
      duration: Duration(seconds: 3),
      leftBarIndicatorColor: isError ? Colors.red[300] : Colors.green[300],
    ).show(context);
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      _showSnackbar('Please enter your email address');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context
          .read<AuthProvider>()
          .resetPassword(_emailController.text.trim());
      _showSnackbar('Password reset email sent. Check your inbox.',
          isError: false);
    } catch (e) {
      _showSnackbar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 44,
                      ),
                  textAlign: TextAlign.center,
                ),
                Gap(50),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  icon: Icons.email,
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                  validator: Validators.validatePassword,
                ),
                Gap(10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                _isLoading
                    ? Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: Theme.of(context).colorScheme.primary,
                          size: 50,
                        ),
                      )
                    : CustomButton(
                        text: 'Login',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await context.read<AuthProvider>().signIn(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()),
                                (route) => false,
                              );
                            } catch (e) {
                              _showSnackbar('Login failed: ${e.toString()}');
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                      ),
                SizedBox(height: 16),
                TextButton(
                  child: Text('Don\'t have an account? Sign up'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
