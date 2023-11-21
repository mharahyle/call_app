import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:call_app/presentation/core/model/chat.dart';
import 'package:call_app/presentation/pages/screens/chat_overview/chat_overview_controller.dart';
import 'package:call_app/presentation/pages/screens/chat_overview/widgets/chat_header_widget.dart';
import 'package:call_app/presentation/pages/screens/new_chat/new_chat_page.dart';
import 'package:call_app/presentation/widgets/exception.dart';
import 'package:call_app/presentation/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../main.dart';
import '../../../core/model/call.dart';
import '../../../core/model/chat_user.dart';
import '../Calls_Fragment.dart';
import '../Status_Fragment.dart';
import '../video_call/video_call_page.dart';


class ChatOverviewPage extends StatefulWidget {
  final ChatUser? user;
  final ReceivedAction? receivedAction;

  const ChatOverviewPage(this.user,this.receivedAction ,{Key? key}) : super(key: key);

  @override
  State<ChatOverviewPage> createState() => _ChatOverviewPageState();
}

class _ChatOverviewPageState extends State<ChatOverviewPage> {
  final ChatOverviewController _controller = ChatOverviewController();
  handleNotification() {
    if (widget.receivedAction != null) {
      Map userMap = widget.receivedAction!.payload!;
      ChatUser user = ChatUser(
          id: userMap['id'],
          name: userMap['name'],
          uid:  userMap['uid'],
          chatIds: [],
          isAudioEnabled:userMap['isAudioEnabled'],
          isVideoEnabled:userMap['isVideoEnabled'],
          view: null,
          fcmToken: userMap['fcmToken']);
      CallModel call = CallModel(
        id: userMap['id'],
        channel: userMap['channel'],
        caller: userMap['caller'],
        called: userMap['called'],
        active: jsonDecode(userMap['active']),
        accepted: true,
        rejected: jsonDecode(userMap['rejected']),
        connected: true,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return VideoCallPage(
              appId: appId,
              token: token,
              channelName: 'Simple Call App',
              user:user,
              call:  call,
            );
          },
        ),
      );
    }
  }
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000)).then(
          (value) {
        handleNotification();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child:Scaffold(
        appBar:AppBar(
          backgroundColor: Color(0xFF075E54),
          title: Text("WhatsApp"),
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Icon(
                    Icons.search,
                    size: 26.0,
                  ),
                )
            ),
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Icon(
                    Icons.more_vert_outlined,
                    size: 26.0,
                  ),
                )
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFF6BA9AA),
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(
                text: 'CHATS',
              ),
              Tab(
                text: 'STATUS',
              ),
              Tab(
                text: 'CALLS',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FutureBuilder(
                future: _controller.getAllChatsOfUser(widget.user!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const LoadingWidget();
                  } else if (snapshot.hasData) {
                    return _buildChatWidgets(snapshot.data!);
                  } else {
                    return const ExceptionWidget();
                  }
                }),
            Status_Screen(),
            Calls_Screen(),
          ],
        ),
floatingActionButton: FloatingActionButton(
    backgroundColor: Color(0xFF075E54),
    child: const Icon(
      Icons.comment,
      color: Colors.white,
    ),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NewChatPage(widget.user!,widget.receivedAction)));

              setState(() {});
            }))
    );
  }

  Widget _buildChatWidgets(List<Chat> chats) {
    return chats.isEmpty
        ? const Center(child: Text("Start your first conversation!"))
        : RefreshIndicator(
            onRefresh: () async =>
                await _controller.getAllChatsOfUser(widget.user!),
            child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  var chatName =
                      _controller.getChatName(chats[index], widget.user!);
                  var stream = FirebaseFirestore.instance
                      .collection("chats")
                      .doc(chats[index].id)
                      .snapshots();
                  return ChatHeaderWidget(
                      chatName: chatName!, stream: stream, user: widget.user!, receivedAction: widget.receivedAction,);
                }));
  }
}
