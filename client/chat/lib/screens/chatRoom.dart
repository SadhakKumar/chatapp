import 'dart:html';

import 'package:chat/providers/chatting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat/providers/user.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../model/message.dart';

class chatRoom extends StatefulWidget {
  const chatRoom({super.key});

  @override
  State<chatRoom> createState() => _chatRoomState();
}

class _chatRoomState extends State<chatRoom> {
  late IO.Socket _socket;
  final TextEditingController _messageInputController = TextEditingController();

  _sendMessage() {
    _socket.emit('message', {
      "message": _messageInputController.text,
      "sender": Provider.of<UserProvider>(context, listen: false).username
    });
    _messageInputController.clear();
  }

  connectScoket() {
    _socket.onConnect((data) {
      print("Connected");
    });

    _socket.onConnectError((data) => print("error$data"));

    _socket.onDisconnect((data) => print("disconnected $data"));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _socket = IO.io(
        "http://localhost:3000",
        IO.OptionBuilder().setTransports(['websocket']).setQuery({
          "username": Provider.of<UserProvider>(context, listen: false).username
        }).build());
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
}
