import 'dart:convert';
import 'dart:io';
import 'package:chat/providers/chatting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat/providers/user.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:flutter_io_socket/flutter_io_socket.dart' as IO;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../model/message.dart';
import 'package:http/http.dart' as http;

class chatRoom extends StatefulWidget {
  const chatRoom({super.key});

  @override
  State<chatRoom> createState() => _chatRoomState();
}

class _chatRoomState extends State<chatRoom> {
  final TextEditingController _messageInputController = TextEditingController();
  late IOWebSocketChannel channel;

  void _sendMessage() {
    final username = Provider.of<UserProvider>(context, listen: false).username;
    final message = _messageInputController.text;
    String data = "{'message': '$message','sender': '$username'}";
    channel.sink.add(data);
    _messageInputController.clear();
  }

  void connectToServer() {
    try {
      channel = IOWebSocketChannel.connect(
          'wss://pt234q3x-5556.inc1.devtunnels.ms/${Provider.of<UserProvider>(context, listen: false).username}');
      channel.stream.listen((message) {
        message = message.replaceAll(RegExp("'"), '"');
        var jsonData = json.decode(message);
        if (jsonData is List) {
          final List<dynamic> messagesData = json.decode(message);
          final List<Message> messages =
              messagesData.map((data) => Message.fromJson(data)).toList();

          ChatProvider chatProvider =
              Provider.of<ChatProvider>(context, listen: false);
          messages.forEach((message) {
            chatProvider.addMessage(message);
          });
        } else {
          final msg = Message.fromJson(jsonData);
          Provider.of<ChatProvider>(context, listen: false).addMessage(msg);
        }

        setState(() {});
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    connectToServer();
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
    channel.sink.close();
    super.dispose();
  }
}
