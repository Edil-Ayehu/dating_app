import 'package:dating_app/export.dart';
import 'package:dating_app/providers/home_provider.dart';
import 'package:dating_app/screens/chat/chat_screen.dart';
import 'package:dating_app/screens/profile/profile_screen.dart';

class Home extends StatelessWidget {
  Home({
    super.key,
  });

  final List<Widget> pages = [
    HomeScreen(),
    MatchesScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: homeProvider.currentPage,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: homeProvider.currentPage,
        onTap: (value) {
          homeProvider.changePage(value);
        },
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 15,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Matches',
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Chat',
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          ),
        ],
      ),
    );
  }
}
