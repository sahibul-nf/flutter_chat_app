class Message {
  final String text;
  final String senderID;
  final String receiverID;

  Message(this.text, this.senderID, this.receiverID);

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      json['content'],
      json['senderID'] ?? json['sender_id'],
      json['receiverID'] ?? json['receiver_id'],
    );
  }
}

class User {
  String name;
  String chatID;

  User(this.name, this.chatID);
}
