import 'package:dating_app/export.dart';
import 'package:dating_app/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<UserModel> users = [
    UserModel(
      id: '1',
      name: 'Alice',
      age: 25,
      bio: 'Love hiking and traveling',
      photoUrl: 'https://example.com/alice.jpg',
      email: 'alice@example.como',
      gender: 'Female',
      interestedIn: 'Male',
    ),
    UserModel(
      id: '2',
      name: 'Bob',
      age: 28,
      bio: 'Foodie and movie enthusiast',
      photoUrl: 'https://example.com/bob.jpg',
      email: 'bob@example.com',
      gender: 'Male',
      interestedIn: 'Female',
    ),
    UserModel(
      id: '3',
      name: 'Charlie',
      age: 23,
      bio: 'Musician and coffee lover',
      photoUrl: 'https://example.com/charlie.jpg',
      email: 'charlie@example.com',
      gender: 'Male',
      interestedIn: 'Female',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dating App'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen()));
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
          Expanded(
            child: users.isNotEmpty
                ? SwipeableTile.card(
                    color: Theme.of(context).cardColor,
                    shadow: BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                    horizontalPadding: 16,
                    verticalPadding: 16,
                    direction: SwipeDirection.horizontal,
                    onSwiped: (direction) {
                      setState(() {
                        if (direction == SwipeDirection.endToStart) {
                          // Dislike
                          users.removeAt(0);
                        } else if (direction == SwipeDirection.startToEnd) {
                          // Like
                          users.removeAt(0);
                          // TODO: Implement match logic
                        }
                      });
                    },
                    backgroundBuilder: (context, direction, progress) {
                      return AnimatedBuilder(
                        animation: progress,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: direction == SwipeDirection.endToStart
                                  ? Colors.red.withOpacity(progress.value)
                                  : Colors.green.withOpacity(progress.value),
                            ),
                            child: Center(
                              child: Icon(
                                direction == SwipeDirection.endToStart
                                    ? Icons.close
                                    : Icons.favorite,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    key: Key(users[0].id),
                    child: buildUserCard(users[0]),
                  )
                : Center(
                    child: Text(
                      'No more profiles to show',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Dislike action
                    if (users.isNotEmpty) {
                      setState(() {
                        users.removeAt(0);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.white,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                  ),
                  child: Icon(Icons.close, color: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Like action
                    if (users.isNotEmpty) {
                      setState(() {
                        users.removeAt(0);
                        // TODO: Implement match logic
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                  child: Icon(Icons.favorite, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Matches',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MatchesScreen()),
            );
          }
        },
      ),
    );
  }

  Widget buildUserCard(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(user.photoUrl),
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
            ],
          ),
        ),
      ),
    );
  }
}
