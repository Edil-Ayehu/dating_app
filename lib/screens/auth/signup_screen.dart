import 'package:dating_app/export.dart';
import 'package:dating_app/home.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();
  final _aboutController = TextEditingController();
  String _gender = '';
  String _interestedIn = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        // Create user account
        firebase_auth.UserCredential userCredential =
            await context.read<AuthProvider>().signUp(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                );

        // Create user profile
        UserModel newUser = UserModel(
          id: userCredential.user!.uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          bio: _bioController.text.trim(),
          gender: _gender,
          interestedIn: _interestedIn,
          photoUrls: [],
          interests: [],
          about: _aboutController.text,
        );

        // Store user profile in Firestore
        await context.read<AuthProvider>().createUserProfile(newUser);

        // Navigate to home screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Home()),
          (route) => false,
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        print('Error during sign up: $e');
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Gap(80),
              Text(
                'Sign Up',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 44,
                    ),
                textAlign: TextAlign.center,
              ),
              Gap(80),
              CustomTextField(
                controller: _nameController,
                hintText: 'Full Name',
                icon: Icons.person,
                validator: (value) =>
                    value!.isEmpty ? 'Name is required' : null,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                hintText: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Password',
                icon: Icons.lock,
                isPassword: true,
                validator: Validators.validatePassword,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                icon: Icons.lock,
                isPassword: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _ageController,
                hintText: 'Age',
                icon: Icons.cake,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Age is required';
                  int? age = int.tryParse(value);
                  if (age == null || age < 18) {
                    return 'You must be at least 18 years old';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _bioController,
                hintText: 'Bio',
                icon: Icons.description,
                validator: (value) => value!.isEmpty ? 'Bio is required' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender.isEmpty ? null : _gender,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                hint: Text(
                  'Select Gender',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                items: ['Male', 'Female', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Gender is required' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _interestedIn.isEmpty ? null : _interestedIn,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.favorite),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                hint: Text(
                  'Interested In',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                items: ['Men', 'Women', 'Both'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _interestedIn = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Preference is required' : null,
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
                      text: 'Sign Up',
                      onPressed: _signUp,
                    ),
              SizedBox(height: 16),
              TextButton(
                child: Text('Already have an account? Login'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
