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
          'Dating App',
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
                        if (filteredUsers.length > 1)
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
                                });

                                if (direction == CardSwiperDirection.right) {
                                  await _saveLikedUser(swipedUser.id);
                                }

                                setState(() {
                                  filteredUsers.removeAt(previousIndex);
                                  users.remove(swipedUser);
                                });

                                Future.delayed(Duration(milliseconds: 500), () {
                                  setState(() {
                                    showLikeOverlay = false;
                                    showDislikeOverlay = false;
                                  });
                                });
                              }
                              return filteredUsers.length > 1;
                            },
                            numberOfCardsDisplayed: 1,
                            backCardOffset: Offset(0, 40),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            isDisabled: filteredUsers.length <= 1,
                          )
                        else if (filteredUsers.length == 1)
                          Center(
                            child: buildUserCard(filteredUsers[0]),
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
                    ),
                  )
                : Center(
                    child: Text(
                      'No profiles match your criteria',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterArea() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
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
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: _showFilterDialog,
            child: Icon(Icons.filter_list),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xffD2E0FB).withOpacity(0.03)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filter Your Matches',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedGender.isEmpty ? null : selectedGender,
                        hint: Text('Select Gender'),
                        isExpanded: true,
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
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Age Range: ${ageRange.start.round()} - ${ageRange.end.round()}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  RangeSlider(
                    values: ageRange,
                    min: 18,
                    max: 100,
                    divisions: 82,
                    activeColor: Colors.purple,
                    inactiveColor: Colors.purple.withOpacity(0.2),
                    labels: RangeLabels(
                      ageRange.start.round().toString(),
                      ageRange.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        ageRange = values;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Interests',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  MultiSelectDialogField(
                    items: interests.map((e) => MultiSelectItem(e, e)).toList(),
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
                      chipColor: Colors.purple.shade100,
                      textStyle: TextStyle(color: Colors.purple.shade800),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Cities',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  MultiSelectDialogField(
                    items: cities.map((e) => MultiSelectItem(e, e)).toList(),
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
                      chipColor: Colors.blue.shade100,
                      textStyle: TextStyle(color: Colors.blue.shade800),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _resetFilters();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text('Reset',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Colors.white,
                                  )),
                        ),
                      ),
                      Gap(10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _filterUsers();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text('Apply',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
