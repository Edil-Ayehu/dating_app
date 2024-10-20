import 'package:dating_app/export.dart';
import 'package:dating_app/screens/chat/chat_detail_screen.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Stream<QuerySnapshot>? _chatsStream;
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

Future<void> _loadCurrentUser() async {
  final authProvider = context.read<AuthProvider>();
  _currentUser = await authProvider.getCurrentUser();
  if (_currentUser != null) {
    _chatsStream = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: _currentUser!.id)
        .snapshots();
  }
  setState(() {
    _isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? Center(child: Text('Unable to load user data'))
              : StreamBuilder<QuerySnapshot>(
                  stream: _chatsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No chats yet'));
                    }

                    return ListView.builder(
  itemCount: snapshot.data!.docs.length,
  itemBuilder: (context, index) {
    final chatDoc = snapshot.data!.docs[index];
    final chatData = chatDoc.data() as Map<String, dynamic>;
    final otherUserId = (chatData['participants'] as List<dynamic>)
        .firstWhere((id) => id != _currentUser!.id);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return ListTile(title: Text('Loading...'));
        }

        final otherUser = UserModel.fromMap(
            userSnapshot.data!.data() as Map<String, dynamic>);

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: otherUser.photoUrls.isNotEmpty
                ? NetworkImage(otherUser.photoUrls[0])
                : AssetImage('assets/images/6.jpg') as ImageProvider,
          ),
          title: Text(otherUser.name),
          subtitle: Text(chatData['lastMessage'] ?? 'No messages yet'),
          trailing: chatData['lastMessageTimestamp'] != null
              ? Text(
                  DateFormat('MMM d, HH:mm').format(
                    (chatData['lastMessageTimestamp'] as Timestamp).toDate(),
                  ),
                )
              : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  chatId: chatDoc.id,
                  otherUser: otherUser,
                ),
              ),
            );
          },
        );
      },
    );
  },
);
                  },
                ),
    );
  }
}
