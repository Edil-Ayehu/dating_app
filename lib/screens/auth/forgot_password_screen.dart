import 'package:dating_app/export.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose(); 
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
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await context.read<AuthProvider>().resetPassword(_emailController.text.trim());
        _showSnackbar('Password reset email sent. Check your inbox.', isError: false);
      } catch (e) {
        _showSnackbar('Error: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reset Password',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 32,
                    ),
                textAlign: TextAlign.center,
              ),
              Gap(30),
              CustomTextField(
                controller: _emailController,
                hintText: 'Email',
                icon: Icons.email,
                validator: Validators.validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              Gap(24),
              _isLoading
                  ? Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: Theme.of(context).colorScheme.primary,
                        size: 50,
                      ),
                    )
                  : CustomButton(
                      text: 'Reset Password',
                      onPressed: _resetPassword,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}