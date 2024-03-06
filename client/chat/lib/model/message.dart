class Message {
  String? message;
  String? sender;
  String? receiver;
  String? time;
  Message({this.message, this.sender, this.receiver, this.time});
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'sender': sender,
      'receiver': receiver,
      'time': time,
    };
  }

  factory Message.fromJson(Map<String, dynamic> message) {
    return Message(
      message: message['message'],
      sender: message['sender'],
      time: DateTime.fromMillisecondsSinceEpoch(message['time']).toString(),
    );
  }
}
