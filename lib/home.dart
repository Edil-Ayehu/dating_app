import 'package:dating_app/export.dart';
import 'package:dating_app/providers/home_provider.dart';
import 'package:dating_app/screens/chat/chat_screen.dart';
import 'package:dating_app/screens/profile/profile_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class Home extends StatelessWidget {
  Home({super.key});

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
      bottomNavigationBar: CurvedNavigationBar(
        index: homeProvider.currentPage,
        height: 65.0,
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.favorite, size: 30, color: Colors.white),
          Icon(Icons.message, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        color:
            isDarkMode ? Colors.black : Theme.of(context).colorScheme.primary,
        buttonBackgroundColor:
            isDarkMode ? Colors.black : Theme.of(context).colorScheme.primary,
        backgroundColor: isDarkMode ? Colors.grey[900]! : Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          homeProvider.changePage(index);
        },
      ),
    );
  }
}
