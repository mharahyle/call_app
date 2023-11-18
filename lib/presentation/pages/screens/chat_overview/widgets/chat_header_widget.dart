import 'package:call_app/presentation/common/resources/extensions/datetime_extensions.dart';
import 'package:call_app/presentation/pages/screens/single_chat/single_chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/model/chat.dart';
import '../../../../core/model/chat_user.dart';

class ChatHeaderWidget extends StatelessWidget {
  final String chatName;
  final Stream<DocumentSnapshot<Map<String, dynamic>>> stream;
  final ChatUser user;

  const ChatHeaderWidget(
      {required this.chatName,
      required this.stream,
      required this.user,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
            stream: stream,
            builder: (context, snapshot) {
              var chat = snapshot.hasData
                  ? Chat.fromJson(snapshot.data!.data()!)
                  : null;
              var lastMessage = chat?.messages.last.content ?? " - ";
              var lastTimestamp =
                  chat?.messages.last.timestamp.toNicerTime() ?? " - ";
              return  InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          SingleChatPage(chat!, user),
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

            }));
  }
}
