import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/helper/chat.dart';
import '../core/model/chat.dart';
import '../core/model/chat_user.dart';
import '../pages/screens/MessageSection.dart';
import '../pages/screens/new_chat.dart';
import '../utilities/info.dart';
import 'exception.dart';
import 'loading.dart';
class ContactList extends StatefulWidget {
  final ChatUser? user;

  const ContactList(this.user, {Key? key}) : super(key: key);

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final ChatOverviewController _controller = ChatOverviewController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: FutureBuilder(
        future: _controller.getAllChatsOfUser(widget.user),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingWidget();
          } else if (snapshot.hasData) {
            return _buildChatWidgets(snapshot.data!);
          } else {
            return const ExceptionWidget();
          }
        },
      ),
    );
  }

  Widget _buildChatWidgets(List<Chat> chats) {
    return chats.isEmpty
        ? const Center(child: Text("Start your first conversation!"))
        : RefreshIndicator(
      onRefresh: () async =>
      await _controller.getAllChatsOfUser(widget.user),
      child: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          var chatName =
          _controller.getChatName(chats[index], widget.user);
          var stream = FirebaseFirestore.instance
              .collection("chats")
              .doc(chats[index].id)
              .snapshots();

          return StreamBuilder(
            stream: stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LoadingWidget(); // or another loading indicator
              }

              var chat = Chat.fromJson(snapshot.data!.data()!);
              var lastMessage = chat!.messages.isNotEmpty
                  ? chat!.messages.last.content
                  : "No messages yet";

              var lastTimestamp = chat!.messages.isNotEmpty
                  ? chat!.messages.last.timestamp.toString()
                  : "No messages yet";


              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          NewChatPage(widget.user!),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text(
                      chatName,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        lastMessage,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    leading: CircleAvatar(
                      child: Icon(Icons.person),
                      radius: 30,
                    ),
                    trailing: Text(
                      lastTimestamp,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
