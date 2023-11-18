import 'package:call_app/presentation/pages/screens/single_chat/single_chat_controller.dart';
import 'package:call_app/presentation/pages/screens/single_chat/widgets/chat_message_widget.dart';
import 'package:call_app/presentation/pages/screens/single_chat/widgets/send_message_field_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../main.dart';
import '../../../core/model/chat.dart';
import '../../../core/model/chat_user.dart';
import '../../../widgets/call_option.dart';
import '../../../widgets/loading.dart';
import '../video_call/video_call_page.dart';

class SingleChatPage extends StatefulWidget {
  final Chat chat;
  final ChatUser user;

  const SingleChatPage(this.chat, this.user, {Key? key}) : super(key: key);

  @override

  State<SingleChatPage> createState() => _SingleChatPageState();
}

class _SingleChatPageState extends State<SingleChatPage> {
  final SingleChatController _controller = SingleChatController();
  bool _isJoining = false;
  Future<void> _joinCall() async {
    setState(() => _isJoining = true);
   // await dotenv.load(fileName: "functions/.env");
    final appId = "548f443b3f7d4a5987b0b1bb7ba5a4d3";


    setState(() => _isJoining = false);
    if (context.mounted) {
      Navigator.of(context).pop();
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoCallPage(
              appId: appId,
              token: token,
              channelName: 'Simple Call App',
            user: widget.user,
          ),
        ),
      );
    }
  }
  Future<void> _joinRoom() async {
    final input = <String, dynamic>{
      'channelName':'simple Call App',
      'expiryTime': 3600, // 1 hour
    };
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('generateToken')
          .call(input);
      final token = response.data as String?;
      if (token != null) {
        debugPrint('Token generated successfully!');
        await Future.delayed(
          const Duration(seconds: 1),
        );
        if (context.mounted) {
          await

          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.star),
                      title: Text('Voice Call'),
                      onTap: () {
                        // Handle Option 1
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.favorite),
                      title: Text('Video Call'),
                      onTap: _joinCall,
                    )
                  ],
                ),
              );
            },
          );

        }
      }
    } catch (e) {
      debugPrint('Error generating token: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage("assets/images/background.png"),
    fit: BoxFit.cover,
    ),
    ),
    child:
      Scaffold(
        bottomSheet: SendMessageFieldWidget(onPressed: _sendMessage),
        appBar: AppBar(
            title: Text(_controller.getChatName(widget.chat, widget.user)),
          backgroundColor: Color(0xFF075E54),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.video_call),
            ),
            IconButton(
              onPressed:  _joinRoom,
              icon: const Icon(Icons.call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ]),
        body: _buildMessagesWidget())
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

                            return ChatMessageWidget(
                                timestamp: message.timestamp,
                                content: message.content,
                                isLocalSender: isLocal);
                          });
                }),
          );
  }

  Future _sendMessage(String message) async {
    await _controller.sendMessage(widget.chat.id, widget.user, message);

    setState(() {});
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.star),
                title: Text('Option 1'),
                onTap: () {
                  // Handle Option 1
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text('Option 2'),
                onTap: () {
                  // Handle Option 2
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.send),
                title: Text('Option 3'),
                onTap: () {
                  // Handle Option 3
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
