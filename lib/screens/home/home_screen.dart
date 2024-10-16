import 'package:dating_app/export.dart';
import 'package:dating_app/screens/liked_users_screen.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<UserModel> users = [];
  List<UserModel> filteredUsers = [];
  TextEditingController searchController = TextEditingController();
  RangeValues ageRange = RangeValues(18, 100);
  String selectedGender = '';
  List<String> selectedInterests = [];
  List<String> selectedCities = [];

  bool showLikeOverlay = false;
  bool showDislikeOverlay = false;

  List<String> cities = [
    'Addis Ababa',
    'Hawassa',
    'Jimma',
    'Adama',
    'Gondar',
    'Bahir dar',
    'Hosanna',
    'Arba Minch',
    'Gonder',
    'Harar',
    'Dire Dawa',
    'Mekelle',
    'Nazret',
    'Debre Birhan',
    'Shashemene',
    'Jima',
    'Bishoftu',
    'Bedesa',
    'Gimbi',
    'Kemise',
    'Kondi',
    'Moyale',
    'Nekemte',
    'Shambu',
    'Tepi',
    'Woldia',
    'Yabello',
    'Ziway',
    'Awasa',
    'Dodola',
    'Gambela',
    'Gimbi',
    'Kemise',
    'Kondi',
    'Moyale',
    'Nekemte',
    'Shambu',
    'Tepi',
    'Woldia',
    'Yabello',
    'Ziway'
  ];

  List<String> interests = [
    'Music',
    'Sports',
    'Travel',
    'Food',
    'Art',
    'Walking',
    'Song',
    'Dance',
    'Reading',
    'Writing',
    'Movies',
    'Photography',
    'Gaming',
    'Fashion',
    'Fitness',
    'Technology',
    'Science',
    'Art',
    'History',
    'Nature',
    'Animals',
    'Traveling',
    'Cooking',
    'Writing',
    'Reading',
    'Movies',
    'Photography',
    'Gaming',
    'Fashion',
    'Fitness',
    'Technology',
    'Science',
    'Fiction',
    'Non-Fiction',
    'Biography',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });

    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final authProvider = context.read<AuthProvider>();
      UserModel? currentUser;

      // Try to get the current user multiple times with a delay
      for (int i = 0; i < 3; i++) {
        currentUser = await authProvider.getCurrentUser();
        if (currentUser != null) break;
        await Future.delayed(Duration(seconds: 1));
      }

      if (currentUser == null) {
        throw Exception('Unable to retrieve current user data');
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isNotEqualTo: currentUser.id)
          .get();

      setState(() {
        users = querySnapshot.docs
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
        filteredUsers = List.from(users);
      });
    } catch (e) {
      print('Error loading users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: ${e.toString()}')),
      );
    }
  }

  void _filterUsers() {
    setState(() {
      filteredUsers = users.where((user) {
        bool matchesSearch = user.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
        bool matchesGender =
            selectedGender.isEmpty || user.gender == selectedGender;
        bool matchesAge =
            user.age >= ageRange.start && user.age <= ageRange.end;
        bool matchesInterests = selectedInterests.isEmpty ||
            selectedInterests
                .any((interest) => user.interests.contains(interest));
        bool matchesCities = selectedCities.isEmpty ||
            selectedCities.contains(user.city); // Add this line

        return matchesSearch &&
            matchesGender &&
            matchesAge &&
            matchesInterests &&
            matchesCities; // Update this line
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      searchController.clear();
      ageRange = RangeValues(18, 100);
      selectedGender = '';
      selectedInterests.clear();
      selectedCities.clear();
      filteredUsers = List.from(users);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'D.A',
          style: GoogleFonts.eagleLake(),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LikedUsersScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Provider.of<ThemeProvider>(context).darkMode
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterArea(),
          Expanded(
            child: filteredUsers.isNotEmpty
                ? SizedBox(
                    width: double.infinity,
                    child: Stack(
                      children: [
                        CardSwiper(
                          cardsCount: filteredUsers.length,
                          cardBuilder: (context, index, percentThresholdX,
                                  percentThresholdY) =>
                              buildUserCard(filteredUsers[index]),
                          onSwipe:
                              (previousIndex, currentIndex, direction) async {
                            if (previousIndex < filteredUsers.length) {
                              UserModel swipedUser =
                                  filteredUsers[previousIndex];
                              setState(() {
                                if (direction == CardSwiperDirection.left) {
                                  showDislikeOverlay = true;
                                } else if (direction ==
                                    CardSwiperDirection.right) {
                                  showLikeOverlay = true;
                                }
                                filteredUsers.removeAt(previousIndex);
                              });

                              if (direction == CardSwiperDirection.right) {
                                await _saveLikedUser(swipedUser.id);
                              }

                              Future.delayed(Duration(milliseconds: 500), () {
                                setState(() {
                                  showLikeOverlay = false;
                                  showDislikeOverlay = false;
                                });
                              });
                            }
                            return filteredUsers.length > 1;
                          },
                          numberOfCardsDisplayed: 2,
                          backCardOffset: Offset(0, 40),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          isDisabled: filteredUsers.length <= 1,
                        ),
                        if (showLikeOverlay)
                          Container(
                            color: Colors.green.withOpacity(0.5),
                            child: Center(
                              child: Icon(Icons.favorite,
                                  size: 100, color: Colors.white),
                            ),
                          ),
                        if (showDislikeOverlay)
                          Container(
                            color: Colors.red.withOpacity(0.5),
                            child: Center(
                              child: Icon(Icons.close,
                                  size: 100, color: Colors.white),
                            ),
                          ),
                      ],
                    ))
                : Center(
                    child: Text(
                      'No profiles match your criteria',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search by name',
              prefixIcon: Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        _filterUsers();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text('Filter'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButton<String>(
                                  value: selectedGender.isEmpty
                                      ? null
                                      : selectedGender,
                                  hint: Text('Select Gender'),
                                  items: ['Male', 'Female']
                                      .map((gender) => DropdownMenuItem(
                                            value: gender,
                                            child: Text(gender),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedGender = value ?? '';
                                    });
                                  },
                                ),
                                SizedBox(height: 8),
                                Text(
                                    'Age Range: ${ageRange.start.round()} - ${ageRange.end.round()}'),
                                RangeSlider(
                                  values: ageRange,
                                  min: 18,
                                  max: 100,
                                  divisions: 82,
                                  onChanged: (RangeValues values) {
                                    setState(() {
                                      ageRange = values;
                                    });
                                  },
                                ),
                                SizedBox(height: 8),
                                Text('Interests'),
                                MultiSelectDialogField(
                                  items: interests
                                      .map((e) => MultiSelectItem(e, e))
                                      .toList(),
                                  listType: MultiSelectListType.CHIP,
                                  onConfirm: (values) {
                                    setState(() {
                                      selectedInterests = values.cast<String>();
                                    });
                                  },
                                  chipDisplay: MultiSelectChipDisplay(
                                    onTap: (value) {
                                      setState(() {
                                        selectedInterests.remove(value);
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text('Cities'),
                                MultiSelectDialogField(
                                  items: cities
                                      .map((e) => MultiSelectItem(e, e))
                                      .toList(),
                                  listType: MultiSelectListType.CHIP,
                                  onConfirm: (values) {
                                    setState(() {
                                      selectedCities = values.cast<String>();
                                    });
                                  },
                                  chipDisplay: MultiSelectChipDisplay(
                                    onTap: (value) {
                                      setState(() {
                                        selectedCities.remove(value);
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _filterUsers();
                              },
                              child: Text('Apply'),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
                child: Text('Filter'),
              ),
              ElevatedButton(
                onPressed: _resetFilters,
                child: Text('Reset Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildUserCard(UserModel user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailsScreen(user: user),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: user.photoUrls.isNotEmpty
                  ? FancyShimmerImage(
                      imageUrl: user.photoUrls[0],
                      boxFit: BoxFit.cover,
                      errorWidget:
                          Image.asset('assets/images/6.jpg', fit: BoxFit.cover),
                    )
                  : Image.asset('assets/images/6.jpg', fit: BoxFit.cover),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
            // User details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.name}, ${user.age}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    user.bio,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 7,
                    runSpacing: 4,
                    children: user.interests
                        .map((interest) => Chip(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              label: Text(interest,
                                  style: TextStyle(color: Colors.black)),
                              backgroundColor: Colors.white.withOpacity(0.7),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveLikedUser(String likedUserId) async {
    try {
      final authProvider = context.read<AuthProvider>();
      UserModel? currentUser = await authProvider.getCurrentUser();

      if (currentUser == null) {
        throw Exception('Unable to retrieve current user data');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.id)
          .update({
        'likedUsers': FieldValue.arrayUnion([likedUserId])
      });
    } catch (e) {
      print('Error saving liked user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving liked user: ${e.toString()}')),
      );
    }
  }
}
