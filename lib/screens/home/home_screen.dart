import 'package:dating_app/export.dart';
import 'package:dating_app/screens/user_details_screen.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = await authProvider.getCurrentUser();

      if (currentUser == null) {
        throw Exception('Current user is null');
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isNotEqualTo: currentUser.id)
          .get();

      setState(() {
        users = querySnapshot.docs
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      print('Error loading users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: ${e.toString()}')),
      );
    }
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
      body: users.isNotEmpty
          ? SizedBox(
              width: double.infinity,
              child: CardSwiper(
                cardsCount: users.length,
                cardBuilder:
                    (context, index, percentThresholdX, percentThresholdY) =>
                        buildUserCard(users[index]),
                onSwipe: (previousIndex, currentIndex, direction) {
                  setState(() {
                    if (direction == CardSwiperDirection.left) {
                      // Dislike
                      users.removeAt(previousIndex);
                    } else if (direction == CardSwiperDirection.right) {
                      // Like
                      users.removeAt(previousIndex);
                      // TODO: Implement match logic
                    }
                  });
                  return true;
                },
                numberOfCardsDisplayed: 1,
                backCardOffset: Offset(0, 40),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                isDisabled: users.length < 2,
              ),
            )
          : Center(
              child: Text(
                'No more profiles to show',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
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
          image: DecorationImage(
            image: user.photoUrls.isNotEmpty
                ? NetworkImage(user.photoUrls[0])
                : AssetImage('assets/images/6.jpg') as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
          child: Padding(
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
                  spacing: 4,
                  runSpacing: 4,
                  children: user.interests
                      .map((interest) => Chip(
                            label: Text(interest,
                                style: TextStyle(color: Colors.black)),
                            backgroundColor: Colors.white.withOpacity(0.7),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
