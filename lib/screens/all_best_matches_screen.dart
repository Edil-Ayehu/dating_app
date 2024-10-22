import 'package:dating_app/export.dart';

class AllBestMatchesScreen extends StatefulWidget {
  final UserModel currentUser;

  const AllBestMatchesScreen({super.key, required this.currentUser});

  @override
  _AllBestMatchesScreenState createState() => _AllBestMatchesScreenState();
}

class _AllBestMatchesScreenState extends State<AllBestMatchesScreen> {
  List<UserModel> _allBestMatches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllBestMatches();
  }

  Future<void> _loadAllBestMatches() async {
    final authProvider = context.read<AuthProvider>();
    _allBestMatches = await authProvider.getBestMatches(widget.currentUser, limit: 100);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Best Matches'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allBestMatches.length,
              itemBuilder: (context, index) {
                final user = _allBestMatches[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.photoUrls.isNotEmpty
                        ? NetworkImage(user.photoUrls[0])
                        : AssetImage('assets/images/6.jpg') as ImageProvider,
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.bio),
                  trailing: Text('${_calculateMatchPercentage(user)}% Match'),
                  onTap: () {
                    // Navigate to user details or start chat
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

  int _calculateMatchPercentage(UserModel user) {
    int matchingInterests = user.interests
        .where((interest) => widget.currentUser.interests.contains(interest))
        .length;
    return (matchingInterests / widget.currentUser.interests.length * 100).round();
  }
}