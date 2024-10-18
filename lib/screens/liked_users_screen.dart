import 'package:dating_app/export.dart';

class LikedUsersScreen extends StatefulWidget {
  const LikedUsersScreen({super.key});

  @override
  _LikedUsersScreenState createState() => _LikedUsersScreenState();
}

class _LikedUsersScreenState extends State<LikedUsersScreen> {
  List<UserModel> likedUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikedUsers();
  }

  Future<void> _loadLikedUsers() async {
    try {
      final authProvider = context.read<AuthProvider>();
      UserModel? currentUser = await authProvider.getCurrentUser();

      if (currentUser == null) {
        throw Exception('Unable to retrieve current user data');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.id)
          .get();

      final likedUserIds =
          List<String>.from(userDoc.data()?['likedUsers'] ?? []);

      final likedUsersData = await Future.wait(
        likedUserIds.map((userId) =>
            FirebaseFirestore.instance.collection('users').doc(userId).get()),
      );

      setState(() {
        likedUsers = likedUsersData
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading liked users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading liked users: ${e.toString()}')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Liked Users'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : likedUsers.isEmpty
              ? Center(child: Text('No liked users yet'))
              : ListView.builder(
                  itemCount: likedUsers.length,
                  itemBuilder: (context, index) {
                    final user = likedUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.photoUrls.isNotEmpty
                            ? NetworkImage(user.photoUrls[0])
                            : AssetImage('assets/images/6.jpg')
                                as ImageProvider,
                      ),
                      title: Text('${user.name}, ${user.age}'),
                      subtitle: Text(user.bio),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailsScreen(user: user),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
