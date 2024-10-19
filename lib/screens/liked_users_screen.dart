import 'package:dating_app/export.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
        title: Text('Liked Users', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).primaryColor,
                size: 50,
              ),
            )
          : likedUsers.isEmpty
              ? _buildEmptyState()
              : _buildLikedUsersGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No liked users yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Start swiping to find your match!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLikedUsersGrid() {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemCount: likedUsers.length,
      itemBuilder: (context, index) {
        final user = likedUsers[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailsScreen(user: user),
            ),
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: user.photoUrls.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: user.photoUrls[0],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              )
                            : Image.asset('assets/images/6.jpg',
                                fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _showRemoveConfirmationDialog(user),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.name}, ${user.age}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user.bio,
                        style: TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRemoveConfirmationDialog(UserModel user) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove User'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to remove ${user.name} from your liked users?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Remove'),
              onPressed: () {
                _removeLikedUser(user);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeLikedUser(UserModel user) async {
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
        'likedUsers': FieldValue.arrayRemove([user.id])
      });

      setState(() {
        likedUsers.remove(user);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.name} removed from liked users')),
      );
    } catch (e) {
      print('Error removing liked user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing liked user: ${e.toString()}')),
      );
    }
  }
}
