import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat/providers/user.dart';
import 'package:chat/screens/chatRoom.dart';
import 'package:chat/providers/chatting.dart';
import 'package:web_socket_channel/io.dart';

class onBoarding extends StatefulWidget {
  const onBoarding({super.key});

  @override
  State<onBoarding> createState() => _onBoardingState();
}

class _onBoardingState extends State<onBoarding> {
  final TextEditingController _usernameController = TextEditingController();

  _login() {
    final provider = Provider.of<UserProvider>(context, listen: false);
    if (_usernameController.text.trim().isNotEmpty) {
      provider.setUsername(_usernameController.text);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                    create: (context) => ChatProvider(),
                    child: chatRoom(),
                  )));
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Please enter a username'),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'))
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 20.0,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Welcome to Chat App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 20.0,
                ),
              ),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your username',
                ),
              ),
              ElevatedButton(
                  onPressed: _login, child: const Text('Start Chating'))
            ],
          ),
        ),
      ),
    );
  }
}
