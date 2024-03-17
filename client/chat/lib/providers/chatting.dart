import 'package:chat/model/message.dart';
import 'package:flutter/cupertino.dart';

class ChatProvider extends ChangeNotifier {
  List<Message> _messages = [];

  List<Message> get messages => _messages;

  void setMessages(List<Message> messages) {
    _messages.addAll(messages);
    notifyListeners();
  }

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }
}
