import 'package:dating_app/export.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _bioController;
  late TextEditingController _aboutController;
  late TextEditingController _interestController;
  String _gender = '';
  String _interestedIn = '';
  bool _isLoading = false;

  List<String> _interests = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _ageController = TextEditingController(text: widget.user.age.toString());
    _bioController = TextEditingController(text: widget.user.bio);
    _aboutController = TextEditingController(text: widget.user.about);
    _gender = widget.user.gender;
    _interestedIn = widget.user.interestedIn;
    _interests = List.from(widget.user.interests);
    _interestController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _aboutController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  void _addInterest(String interest) {
    if (interest.isNotEmpty && !_interests.contains(interest)) {
      setState(() {
        _interests.add(interest);
      });
      _interestController.clear();
    }
  }

  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final updatedUser = widget.user.copyWith(
          name: _nameController.text,
          age: int.parse(_ageController.text),
          bio: _bioController.text,
          about: _aboutController.text,
          gender: _gender,
          interestedIn: _interestedIn,
          interests: _interests, // Add this line
        );
        await context.read<AuthProvider>().updateUserProfile(updatedUser);
        Navigator.of(context).pop(updatedUser);
      } catch (e) {
        print('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile. Please try again.')),
        );
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
        backgroundColor: Colors.white,
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Full Name',
                  style: TextStyle(fontSize: 18, color: Colors.black)),
              SizedBox(height: 8),
              CustomTextField(
                controller: _nameController,
                hintText: 'Full Name',
                icon: Icons.person,
              ),
              SizedBox(height: 16),
              Text('Age', style: TextStyle(fontSize: 18, color: Colors.black)),
              SizedBox(height: 8),
              CustomTextField(
                controller: _ageController,
                hintText: 'Age',
                icon: Icons.cake,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              Text('Bio', style: TextStyle(fontSize: 18, color: Colors.black)),
              SizedBox(height: 8),
              CustomTextField(
                controller: _bioController,
                hintText: 'Bio',
                icon: Icons.short_text,
              ),
              SizedBox(height: 16),
              Text('About',
                  style: TextStyle(fontSize: 18, color: Colors.black)),
              SizedBox(height: 8),
              CustomTextField(
                controller: _aboutController,
                hintText: 'About',
                icon: Icons.description,
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Text('Gender',
                  style: TextStyle(fontSize: 18, color: Colors.black)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _gender.isNotEmpty ? _gender : null,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.wc),
                  border: OutlineInputBorder(),
                ),
                hint: Text('Gender'),
                items: ['Male', 'Female']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
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
                  style: TextStyle(fontSize: 18, color: Colors.black)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _interestedIn.isNotEmpty ? _interestedIn : null,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.favorite),
                  border: OutlineInputBorder(),
                ),
                hint: Text('Interested In'),
                items: ['Male', 'Female']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _interestedIn = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Preference is required' : null,
              ),
              SizedBox(height: 16),
              _buildInterestsSection(), // Add this line
              SizedBox(height: 24),
              _isLoading
                  ? Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: Theme.of(context).colorScheme.primary,
                        size: 50,
                      ),
                    )
                  : CustomButton(
                      text: 'Save Changes',
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
        Text('Interests', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _interests
              .map((interest) => InputChip(
                    label: Text(interest),
                    onDeleted: () => _removeInterest(interest),
                    onPressed: () => _editInterest(interest),
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                  ))
              .toList(),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _interestController,
                hintText: 'Add new interest',
                icon: Icons.add,
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final newInterest = _interestController.text.trim();
                if (newInterest.isNotEmpty) {
                  _addInterest(newInterest);
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ],
    );
  }

  void _editInterest(String oldInterest) {
    _interestController.text = oldInterest;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Interest'),
          content: CustomTextField(
            controller: _interestController,
            hintText: 'Edit interest',
            icon: Icons.edit,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _interestController.clear();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                final editedInterest = _interestController.text.trim();
                if (editedInterest.isNotEmpty &&
                    editedInterest != oldInterest) {
                  setState(() {
                    _interests[_interests.indexOf(oldInterest)] =
                        editedInterest;
                  });
                }
                Navigator.of(context).pop();
                _interestController.clear();
              },
            ),
          ],
        );
      },
    );
  }
}
