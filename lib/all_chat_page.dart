import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'chat_model.dart';
import 'chat_page.dart';
import 'model.dart';

class AllChatPage extends StatefulWidget {
  const AllChatPage({Key? key}) : super(key: key);

  @override
  State<AllChatPage> createState() => _AllChatPageState();
}

class _AllChatPageState extends State<AllChatPage> {
  late Socket socket;

  @override
  void initState() {
    super.initState();
    ScopedModel.of<ChatModel>(context).init();
    // initializeSocket();
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  void initializeSocket() {
    socket = io(
      'https://chat-app-snf.herokuapp.com/',
      // 'wss://127.0.0.1:3000/',
      OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setPath('/')
          .setQuery({
            'chatID': '111',
            // 'user_name': currentUser.name,
          })
          .build(),
    );
    socket.connect(); //connect the Socket.IO Client to the Server

    socket.onError((data) {
      print('error: $data');
    });

    socket.onConnectError((data) {
      print('connect error: $data');
    });

    //SOCKET EVENTS
    // --> listening for connection
    socket.on('connect', (data) {
      print(socket.connected);
    });

    //listen for incoming messages from the Server.
    socket.on('message', (data) {
      print(data); //
    });

    //listens when the client is disconnected from the Server
    socket.on('disconnect', (data) {
      print('disconnect');
    });
  }

  void friendClicked(User friend) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return ChatPage(friend: friend);
        },
      ),
    );
  }

  Widget buildAllChatList() {
    return ScopedModelDescendant<ChatModel>(
      builder: (context, child, model) {
        return ListView.builder(
          itemCount: model.friendList.length,
          itemBuilder: (BuildContext context, int index) {
            User friend = model.friendList[index];
            return ListTile(
              title: Text(friend.name),
              onTap: () => friendClicked(friend),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Chats'),
      ),
      body: buildAllChatList(),
    );
  }
}
