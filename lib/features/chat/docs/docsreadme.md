📱 Flutter Chat Integration Guide
1. Dependencies
Add the following to your pubspec.yaml:


YAML








dependencies:
  socket_io_client: ^2.0.3  # For Real-Time Communication
  http: ^1.1.0              # For REST API calls (History/List)





2. Socket Service (Singleton)
Create lib/services/socket_service.dart. This handles the persistent connection.


Dart








import 'package:socket_io_client/socket_io_client.dart' as IO;
class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;
  factory SocketService() {
    return _instance;
  }
  SocketService._internal();
  // Initialize Connection
  void init(String token) {
    socket = IO.io('http://YOUR_API_URL', IO.OptionBuilder()
      .setTransports(['websocket']) // Force WebSocket
      .setAuth({'token': token})    // Pass JWT in Handshake Auth
      .build());
    socket.onConnect((_) {
      print('[Socket] Connected');
    });
    socket.onDisconnect((_) {
      print('[Socket] Disconnected');
    });
    socket.onError((data) => print('[Socket] Error: $data'));
  }
  // Join a Chat Room (Call when entering Chat Screen)
  void joinRoom(String roomId) {
    socket.emit('JOIN_ROOM', roomId);
  }
  // Send a Message
  void sendMessage(String roomId, String content) {
    socket.emit('SEND_MESSAGE', {
      'roomId': roomId,
      'content': content,
    });
  }
  // Listen for incoming messages
  void onNewMessage(Function(dynamic) callback) {
    socket.on('NEW_MESSAGE', (data) {
      callback(data);
    });
  }
  // Cleanup
  void dispose() {
    socket.dispose();
  }
}





3. Usage Flow (UI Implementation)
A. Chat List Screen (Inbox)
API: GET /chats
Logic: Fetch the list via HTTP. Display items using otherUser.name, otherUser.avatarUrl, and lastMessage.
Action: When a user taps a tile, navigate to the Chat Detail Screen with the roomId.

B. Chat Detail Screen (Conversation)
API: GET /chats/:roomId/messages (Fetch history).
Socket: Connect & Listen for real-time updates.

Example ChatScreen Logic:


Dart








class ChatScreen extends StatefulWidget {
  final String roomId;
  ChatScreen({required this.roomId});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  final SocketService _socketService = SocketService();
  List<dynamic> messages = []; // Store messages here
  TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    // 1. Load History (HTTP)
    _loadMessageHistory(); 
    // 2. Join Room (Socket)
    _socketService.joinRoom(widget.roomId);
    // 3. Listen for Real-Time Messages
    _socketService.onNewMessage((data) {
      setState(() {
        messages.add(data); // Append new message to list
        // Scroll to bottom...
      });
    });
  }
  Future<void> _loadMessageHistory() async {
    // Call GET /chats/{roomId}/messages
    // Parse response -> setState(messages = fetchedMessages);
  }
  void _handleSend() {
    if (_controller.text.isEmpty) return;
    // Emit to Server
    _socketService.sendMessage(widget.roomId, _controller.text);
    // Optimistic UI Update (Optional: wait for server echo via onNewMessage)
    _controller.clear();
  }
  @override
  Widget build(BuildContext context) {
    // Render ListView of messages...
  }
}





4. Data Models (Dart)
Message Object:
Matches the NEW_MESSAGE event and GET /messages response.


Dart








class ChatMessage {
  final String id;
  final String content;
  final String senderId;
  final bool isMe; // Helper from backend
  final String createdAt;
  ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.isMe,
    required this.createdAt,
  });
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      senderId: json['senderId'],
      isMe: json['isMe'] ?? false, // 'isMe' comes from API, but not Socket event (calc manually if needed)
      createdAt: json['createdAt'],
    );
  }
}


5. Troubleshooting Tips for Mobile Team
"Authentication Error": Ensure the JWT token is passed in .setAuth({'token': ...}) before connecting. If the token expires, you must disconnect, update the token, and reconnect.
"Messages not appearing": Ensure joinRoom(roomId) is called immediately after entering the screen. You cannot receive messages for a room you haven't joined.
Localhost on Android: If testing on an emulator, use http://10.0.2.2:3000 instead of localhost.



