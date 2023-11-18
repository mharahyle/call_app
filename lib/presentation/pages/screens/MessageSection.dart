import 'package:call_app/presentation/pages/screens/single_chat/single_chat_controller.dart';
import 'package:call_app/presentation/pages/screens/single_chat/widgets/send_message_field_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


import '../../core/model/chat.dart';
import '../../core/model/chat_user.dart';
import '../../utilities/info.dart';
import '../../widgets/ChatList.dart';
import '../../widgets/SenderMessageCard.dart';
import '../../widgets/loading.dart';
import '../../widgets/mymessagecard.dart';


class Message_screeen extends StatefulWidget {
  final Chat chat;
  final ChatUser user;
  const Message_screeen(this.chat,this.user,{Key? key}) : super(key: key);

  @override
  State<Message_screeen> createState() => _Message_screeenState();
}

class _Message_screeenState extends State<Message_screeen> {
  final SingleChatController _controller = SingleChatController();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage("https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png"
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
          bottomSheet: SendMessageFieldWidget(onPressed: _sendMessage),
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Color(0xFF075E54),
          elevation: 0,
          title: Text(_controller.getChatName(widget.chat, widget.user)),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.video_call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ) ,
        body: _buildMessagesWidget()

      ),
    );
  }

  Widget _buildMessagesWidget() {
    return widget.chat.messages.isEmpty
        ? const Center(child: Text("Start a conversation!"))
        : Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 68),
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chats")
              .doc(widget.chat.id)
              .snapshots(),
          builder: (context, snapshot) {
            var myChat = snapshot.hasData
                ? Chat.fromJson(snapshot.data!.data()!)
                : null;

            return myChat == null
                ? const LoadingWidget()
                : ListView.separated(
                separatorBuilder: (context, index) =>
                const SizedBox(height: 5),
                itemCount: myChat.messages.length,
                itemBuilder: (context, index) {
                  var message = myChat.messages[index];
                  var isLocal = message.sender.id == widget.user.id;

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      if (isLocal) {
                        return MyMessageCard(
                          message:  message.content,
                          date: message.timestamp.toString(),
                        );
                      }
                      return SenderMessageCard(
                        message:  message.content,
                        date: message.timestamp.toString(),
                      );
                    },
                  );

                });
          }),
    );
  }

  Future _sendMessage(String message) async {
    await _controller.sendMessage(widget.chat.id, widget.user, message);

    setState(() {});
  }
}