import 'dart:io';
import 'package:dating_app/export.dart';
import 'package:dating_app/screens/profile/edit_profile_screen.dart';

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
  late TextEditingController _aboutController;

  String _gender = '';
  String _interestedIn = '';
  bool _isLoading = false;
  UserModel? _user;
  File? _image;
  List<String> _interests = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

Future<void> _loadUserData() async {
  if (!mounted) return;
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
      _aboutController = TextEditingController(text: _user!.about);
      _gender = _user!.gender;
      _interestedIn = _user!.interestedIn;
      _interests = _user!.interests;
    } else {
      throw Exception('User data is null');
    }
  } catch (e) {
    print('Error loading user data: $e');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading user data: ${e.toString()}')),
    );
  } finally {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }
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
        await _uploadImageToFirebase();
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image. Please try again.')),
      );
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child(
          'profile_images/${_user!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await imageRef.putFile(_image!);
      final downloadURL = await imageRef.getDownloadURL();

      List<String> updatedPhotoUrls = [downloadURL, ..._user!.photoUrls];
      final updatedUser = _user!.copyWith(photoUrls: updatedPhotoUrls);

      await context.read<AuthProvider>().updateUserProfile(updatedUser);

      setState(() {
        _user = updatedUser;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated successfully')),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error updating profile picture. Please try again.')),
      );
      setState(() {
        _isLoading = false;
      });
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

  void _navigateToEditProfile() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: _user!),
      ),
    )
        .then((updatedUser) {
      if (updatedUser != null) {
        setState(() {
          _user = updatedUser;
          _interests = updatedUser.interests;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: Theme.of(context).textTheme.titleMedium),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _navigateToEditProfile,
          ),
        ],
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(width: 2, color: Colors.green),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: _user!.photoUrls.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: _user!.photoUrls[0],
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        )
                                      : Image.asset(
                                          'assets/images/6.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _showImageSourceActionSheet,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text('Full Name',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                        SizedBox(height: 8),
                        Text(_user!.name),
                        SizedBox(height: 16),
                        Text('Age',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                        SizedBox(height: 8),
                        Text(_user!.age.toString()),
                        SizedBox(height: 16),
                        Text('Bio',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                        SizedBox(height: 8),
                        Text(_user!.bio),
                        SizedBox(height: 16),
                        Text('About',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                        SizedBox(height: 8),
                        Text(_user!.about),
                        SizedBox(height: 16),
                        Text('Gender',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                        SizedBox(height: 8),
                        Text(_user!.gender),
                        SizedBox(height: 16),
                        Text('Interests',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                        _buildInterestsSection(),
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
        Wrap(
          spacing: 8,
          children: _interests
              .map((interest) => Chip(
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    label: Text(interest),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
