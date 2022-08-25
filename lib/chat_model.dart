import 'package:scoped_model/scoped_model.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:convert';

import 'model.dart';

class ChatModel extends Model {
  List<User> users = [
    User('IronMan', '20f1bc51-5737-44ea-8dc6-88ed2846c2d3'),
    User('Captain America', '15e540d4-d995-4675-bc95-ddfc3896fc4b'),
    User('Antman', 'f8c23681-ee6c-4114-aa3d-c04235732272'),
    // User('Hulk', '444'),
    // User('Thor', '555'),
    // User('Black Widow', '666'),
    // User('Hawkeye', '777'),
  ];

  late User currentUser;
  List<User> friendList = <User>[];
  List<Message> messages = <Message>[];
  late Socket socketIO;

  void init() {
    currentUser = users[0];
    friendList =
        users.where((user) => user.chatID != currentUser.chatID).toList();

    var token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoidSIsInVzZXJfaWQiOiIyMGYxYmM1MS01NzM3LTQ0ZWEtOGRjNi04OGVkMjg0NmMyZDMifQ.zs0uTbD4JwGoawsJeUsNMFL7DoojwGLuJETcLmwGbFo";
    socketIO = io(
      // 'https://chat-app-snf.herokuapp.com/',
      // 'http://localhost:3000/',
      // OptionBuilder()
      //     .setTransports(['websocket'])
      //     .disableAutoConnect()
      //     .setPath('/socket.io')
      //     .setQuery({
      //       'chatID': currentUser.chatID,
      //     })
      //     .setTimeout(5000)
      //     .build(),
      'http://13.251.102.176:8084/',
      OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .disableAutoConnect() // disable auto-connection
          .setExtraHeaders({
            'Authorization': 'Bearer $token',
          })
          .setPath('/message/socket.io')
          .setTimeout(5000)
          .build(),
    );

    socketIO.connect();

    socketIO.onConnect((_) {
      print('Connected to SocketIO');
    });

    socketIO.onError((data) {
      print('error: $data');
    });

    socketIO.onConnectError((data) {
      print('connect error: $data');
    });

    socketIO.onConnectTimeout((data) {
      print('connect timeout: $data');
    });

    socketIO.on('connect', (_) {
      print(socketIO.connected);
      print('connected');
    });

    socketIO.on('disconnect', (_) {
      print('disconnected');
    });

    socketIO.on('receive', (data) {
      print('message: $data');
      final message = Message.fromJson(data);
      if (message.receiverID == currentUser.chatID) {
        messages.add(message);
        notifyListeners();
      }
    });

    socketIO.on('test', (data) {
      print('message: $data');
      var json = jsonDecode(data);
      print(json);
      final message = Message.fromJson(json);
      if (message.receiverID == currentUser.chatID) {
        messages.add(message);
        notifyListeners();
      }
    });

    socketIO.on('message_kopwar_user20f1bc51-5737-44ea-8dc6-88ed2846c2d3',
        (data) {
      print('message: $data');
      final message = Message.fromJson(data);
      if (message.receiverID == currentUser.chatID) {
        messages.add(message);
        notifyListeners();
      }
    });
  }

  void sendMessage(String text, String receiverChatID) {
    messages.add(Message(text, currentUser.chatID, receiverChatID));
    var data = '''
      {
        "content": "$text",
        "sender_id": "${currentUser.chatID}",
        "receiver_id": "$receiverChatID"
      }
    ''';
    socketIO.emit(
      'notice_lagi',
      // {
      //   'content': text,
      //   'senderID': currentUser.chatID,
      //   'receiverID': receiverChatID,
      // },
      data,
    );
    notifyListeners();
  }

  List<Message> getMessagesForChatID(String chatID) {
    return messages
        .where((msg) => msg.senderID == chatID || msg.receiverID == chatID)
        .toList();
  }
}
