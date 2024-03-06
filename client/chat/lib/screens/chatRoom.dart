import 'dart:io';
import 'package:chat/providers/chatting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat/providers/user.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_io_socket/flutter_io_socket.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import '../model/message.dart';

class chatRoom extends StatefulWidget {
  const chatRoom({super.key});

  @override
  State<chatRoom> createState() => _chatRoomState();
}

class _chatRoomState extends State<chatRoom> {
  late IO.Socket socket;
  final TextEditingController _messageInputController = TextEditingController();

  _sendMessage() {
    socket.emit('message', {
      'message': _messageInputController.text.trim(),
      'sender': Provider.of<UserProvider>(context, listen: false).username,
    });
    _messageInputController.clear();
  }

  // _connectSocket() {
  //   socket.onConnect((data) => print('Connection established'));
  //   _socket.onConnectError((data) => print('Connect Error: $data'));
  //   _socket.onDisconnect((data) => print('Socket.IO server disconnected'));
  //   _socket.on(
  //     'message',
  //     (data) => Provider.of<ChatProvider>(context, listen: false).addMessage(
  //       Message.fromJson(data),
  //     ),
  //   );
  // }

  Future<void> initSocket() async {
    try {
      socket = IO.io("http://10.0.2.2:3000", <String, dynamic>{
        'transports': ['websocket'],
        'forceNew': true,
      });
      socket.connect();

      socket.onConnect((data) => print('connected'));
      socket.onDisconnect((data) => print('disconnected'));
      socket.onConnectError((data) => print('Connect Error: $data'));
    } catch (e) {
      print('error $e');
    }
  }

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        return Scaffold(
            appBar: AppBar(
              title: Text("Welcome back ${provider.username}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 20.0,
                  )),
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
                )),
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
                            if (_messageInputController.text
                                .trim()
                                .isNotEmpty) {
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
            ));
      },
    );
  }

  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
