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

  Message.fromMap(Map<String, dynamic> map) {
    message = map['message'];
    sender = map['sender'];
    receiver = map['receiver'];
    time = map['time'];
  }
}
