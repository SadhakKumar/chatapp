class Message {
  String? message;
  String? sender;
  String? time;
  Message({this.message, this.sender, this.time});

  factory Message.fromJson(Map<String, dynamic> message) {
    return Message(
      message: message['message'],
      sender: message['sender'],
      time: DateTime.now().toString(),
    );
  }
}
