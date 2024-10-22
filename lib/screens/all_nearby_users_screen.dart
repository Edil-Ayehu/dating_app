import 'package:dating_app/export.dart';

class AllNearbyUsersScreen extends StatefulWidget {
  final UserModel currentUser;

  const AllNearbyUsersScreen({Key? key, required this.currentUser})
      : super(key: key);

  @override
  _AllNearbyUsersScreenState createState() => _AllNearbyUsersScreenState();
}

class _AllNearbyUsersScreenState extends State<AllNearbyUsersScreen> {
  List<UserModel> _allNearbyUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllNearbyUsers();
  }

  Future<void> _loadAllNearbyUsers() async {
    final authProvider = context.read<AuthProvider>();
    _allNearbyUsers = await authProvider.getNearbyUsers(
        widget.currentUser, 10000); // 10km radius
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('All Nearby Users'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allNearbyUsers.length,
              itemBuilder: (context, index) {
                final user = _allNearbyUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.photoUrls.isNotEmpty
                        ? NetworkImage(user.photoUrls[0])
                        : AssetImage('assets/images/6.jpg') as ImageProvider,
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.bio),
                  onTap: () {
                    // Navigate to user details or start chat
                  },
                );
              },
            ),
    );
  }
}
