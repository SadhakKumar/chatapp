import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import '../providers/chatting.dart';
import '../providers/user.dart';
import '../model/message.dart';

class chatRoom extends StatefulWidget {
  const chatRoom({Key? key}) : super(key: key);

  @override
  State<chatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<chatRoom> {
  final TextEditingController _messageInputController = TextEditingController();
  late IO.Socket socket;

  void _sendMessage() {
    final username = Provider.of<UserProvider>(context, listen: false).username;
    final message = _messageInputController.text.trim();
    final data = {
      'message': message,
      'sender': username,
    };
    socket.emit('message', data);
    _messageInputController.clear();
  }

  void connectToServer() {
    socket.onConnect((data) => print('Connection established'));
    socket.onConnectError((data) => print('Connect Error: $data'));
    socket.onDisconnect((data) => print('Socket.IO server disconnected'));

    socket.on('message', (message) {
      var jsonData = message;

      if (jsonData is List) {
        final List<Message> messages =
            jsonData.map((data) => Message.fromJson(data)).toList();

        ChatProvider chatProvider =
            Provider.of<ChatProvider>(context, listen: false);
        chatProvider.setMessages(messages); // Add all initial messages
      } else {
        final msg = Message.fromJson(jsonData);
        Provider.of<ChatProvider>(context, listen: false).addMessage(msg);
      }

      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    final username = Provider.of<UserProvider>(context, listen: false).username;
    socket = IO.io(
      Platform.isIOS ? 'http://localhost:3000' : 'http://10.0.2.2:3000',
      IO.OptionBuilder().setTransports(['websocket']).setQuery({
        'username': username,
      }).build(),
    );
    connectToServer();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Welcome back ${provider.username}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 20.0,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chat, child) => ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final msg = chat.messages[index];
                      return Wrap(
                        alignment: msg.sender == provider.username
                            ? WrapAlignment.end
                            : WrapAlignment.start,
                        children: [
                          Card(
                            color: msg.sender == provider.username
                                ? Colors.blue
                                : Colors.grey,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                    msg.sender == provider.username
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  Text(msg.message.toString()),
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    },
                    separatorBuilder: (_, index) => const SizedBox(
                      height: 5,
                    ),
                    itemCount: chat.messages.length,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageInputController,
                          decoration: const InputDecoration(
                            hintText: 'Type your message here...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (_messageInputController.text.trim().isNotEmpty) {
                            _sendMessage();
                          }
                        },
                        icon: const Icon(Icons.send),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
