import 'dart:io';
import 'package:dating_app/export.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _bioController;
  late TextEditingController _interestController;

  String _gender = '';
  String _interestedIn = '';
  bool _isLoading = false;
  UserModel? _user;
  File? _image;
  List<String> _interests = [];

  @override
  void initState() {
    super.initState();
    _interestController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final authProvider = context.read<AuthProvider>();
      _user = await authProvider.getCurrentUser();
      if (_user != null) {
        _nameController = TextEditingController(text: _user!.name);
        _ageController = TextEditingController(text: _user!.age.toString());
        _bioController = TextEditingController(text: _user!.bio);
        _gender = _user!.gender;
        _interestedIn = _user!.interestedIn;
        _interests = _user!.interests;
      } else {
        throw Exception('User data is null');
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addInterest(String interest) {
    setState(() {
      _interests.add(interest);
    });
  }

  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.message}')),
      );
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image. Please try again.')),
      );
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Select from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        String photoUrl = _user!.photoUrl;
        if (_image != null) {
          photoUrl = await _uploadImage();
        }
        final updatedUser = _user!.copyWith(
          name: _nameController.text,
          age: int.parse(_ageController.text),
          bio: _bioController.text,
          gender: _gender,
          interestedIn: _interestedIn,
          photoUrl: photoUrl,
          interests: _interests,
        );
        await context.read<AuthProvider>().updateUserProfile(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        print('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _uploadImage() async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('profile_images/${_user!.id}.jpg');

      print('Attempting to upload image...');
      await imageRef.putFile(_image!);
      print('Image uploaded successfully');

      print('Attempting to get download URL...');
      String downloadURL = await imageRef.getDownloadURL();
      print('Download URL obtained: $downloadURL');

      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      if (e is FirebaseException) {
        print('Firebase error code: ${e.code}');
        print('Firebase error message: ${e.message}');
      }
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.eagleLake(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).colorScheme.primary,
                size: 50,
              ),
            )
          : _user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Failed to load user data'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _user!.photoUrl.isNotEmpty
                                  ? NetworkImage(_user!.photoUrl)
                                  : AssetImage('assets/images/6.jpg')
                                      as ImageProvider,
                              onBackgroundImageError: (_, __) {
                                // If the image fails to load, we'll update the state to show a default icon
                                setState(() {
                                  _user = _user!.copyWith(photoUrl: '');
                                });
                              },
                              child: _user!.photoUrl.isEmpty
                                  ? Icon(Icons.person,
                                      size: 60, color: Colors.grey)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showImageSourceActionSheet,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.camera_alt,
                                      size: 20, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text('Full Name',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                        SizedBox(height: 8),
                        CustomTextField(
                          controller: _nameController,
                          hintText: 'Full Name',
                          icon: Icons.person,
                          validator: (value) =>
                              value!.isEmpty ? 'Name is required' : null,
                        ),
                        SizedBox(height: 16),
                        Text('Age',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                        SizedBox(height: 8),
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
                        Text('Bio',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                        SizedBox(height: 8),
                        CustomTextField(
                          controller: _bioController,
                          hintText: 'Bio',
                          icon: Icons.description,
                          validator: (value) =>
                              value!.isEmpty ? 'Bio is required' : null,
                        ),
                        SizedBox(height: 16),
                        Text('Gender',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _gender,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          hint: Text(
                            'Select Gender',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          items:
                              ['Male', 'Female', 'Other'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
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
                        Text('Interested In',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _interestedIn,
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
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
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
                        SizedBox(height: 16),
                        _buildInterestsSection(),
                        SizedBox(height: 24),
                        CustomButton(
                          text: 'Update Profile',
                          onPressed: _updateProfile,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Interests', style: TextStyle(fontSize: 18, color: Colors.black)),
        Wrap(
          spacing: 8,
          children: _interests
              .map((interest) => Chip(
                    label: Text(interest),
                    onDeleted: () => _removeInterest(interest),
                  ))
              .toList(),
        ),
        TextField(
          controller: _interestController,
          decoration: InputDecoration(
            hintText: 'Add an interest',
            hintStyle: TextStyle(fontSize: 18, color: Colors.black),
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (_interestController.text.isNotEmpty) {
                  _addInterest(_interestController.text);
                  _interestController.clear();
                }
              },
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _addInterest(value);
              _interestController.clear();
            }
          },
        ),
      ],
    );
  }
}
