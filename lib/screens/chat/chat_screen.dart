import 'package:dating_app/export.dart';
import 'package:dating_app/screens/all_nearby_users_screen.dart';
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
  List<UserModel> _nearbyUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final authProvider = context.read<AuthProvider>();
    _currentUser = await authProvider.getCurrentUser();
    if (_currentUser != null && _currentUser!.location != null) {
      _chatsStream = FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: _currentUser!.id)
          .snapshots();

      _nearbyUsers = await authProvider.getNearbyUsers(_currentUser!, 10000,
          limit: 5); // 10km radius, limit to 5 users
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Chats'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? Center(child: Text('Unable to load user data'))
              : Column(
                  children: [
                    _buildNearbyUsersList(),
                    Expanded(child: _buildChatsList()),
                  ],
                ),
    );
  }

  Widget _buildNearbyUsersList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nearby',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AllNearbyUsersScreen(currentUser: _currentUser!),
                    ),
                  );
                },
                child: Text('See All',
                    style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
            ],
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _nearbyUsers.length,
              itemBuilder: (context, index) {
                final user = _nearbyUsers[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => _startChat(user),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: user.photoUrls.isNotEmpty
                              ? NetworkImage(user.photoUrls[0])
                              : AssetImage('assets/images/6.jpg')
                                  as ImageProvider,
                        ),
                        SizedBox(height: 4),
                        Text(user.name, style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsList() {
    return StreamBuilder<QuerySnapshot>(
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

            final lastSeenMessage = (chatData['lastSeenMessage']
                as Map<String, dynamic>?)?[_currentUser!.id];
            final lastMessageTimestamp =
                chatData['lastMessageTimestamp'] as Timestamp?;
            final lastSenderId = chatData['lastSenderId'] as String?;
            final hasUnreadMessages = lastSenderId != _currentUser!.id &&
                (lastSeenMessage == null ||
                    (lastMessageTimestamp != null &&
                        lastMessageTimestamp
                            .toDate()
                            .isAfter(lastSeenMessage.toDate())));
            final isMessageSeen = lastSenderId == _currentUser!.id &&
                (chatData['lastSeenMessage']
                        as Map<String, dynamic>?)?[otherUserId] !=
                    null &&
                lastMessageTimestamp != null &&
                ((chatData['lastSeenMessage']
                        as Map<String, dynamic>?)?[otherUserId] as Timestamp)
                    .toDate()
                    .isAfter(lastMessageTimestamp.toDate());

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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasUnreadMessages)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        )
                      else if (isMessageSeen)
                        Icon(Icons.done_all, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      if (chatData['lastMessageTimestamp'] != null)
                        Text(
                          DateFormat('MMM d, HH:mm').format(
                            (chatData['lastMessageTimestamp'] as Timestamp)
                                .toDate(),
                          ),
                        ),
                    ],
                  ),
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
    );
  }

  void _startChat(UserModel otherUser) async {
    // Check if a chat already exists
    final querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: _currentUser!.id)
        .get();

    String? existingChatId;
    for (var doc in querySnapshot.docs) {
      List<dynamic> participants = doc['participants'];
      if (participants.contains(otherUser.id)) {
        existingChatId = doc.id;
        break;
      }
    }

    if (existingChatId != null) {
      // Chat already exists, navigate to it
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
            chatId: existingChatId!,
            otherUser: otherUser,
          ),
        ),
      );
    } else {
      // Create a new chat
      final newChatDoc =
          await FirebaseFirestore.instance.collection('chats').add({
        'participants': [_currentUser!.id, otherUser.id],
        'lastMessage': null,
        'lastMessageTimestamp': null,
        'lastSeenMessage': {
          _currentUser!.id: null,
          otherUser.id: null,
        },
        'lastSenderId': null,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
            chatId: newChatDoc.id,
            otherUser: otherUser,
          ),
        ),
      );
    }
  }
}
