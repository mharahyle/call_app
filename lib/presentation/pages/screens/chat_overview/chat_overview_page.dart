import 'package:call_app/presentation/core/model/chat.dart';
import 'package:call_app/presentation/pages/screens/chat_overview/chat_overview_controller.dart';
import 'package:call_app/presentation/pages/screens/chat_overview/widgets/chat_header_widget.dart';
import 'package:call_app/presentation/pages/screens/new_chat/new_chat_page.dart';
import 'package:call_app/presentation/widgets/exception.dart';
import 'package:call_app/presentation/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/model/chat_user.dart';
import '../Calls_Fragment.dart';
import '../Status_Fragment.dart';


class ChatOverviewPage extends StatefulWidget {
  final ChatUser user;

  const ChatOverviewPage(this.user, {Key? key}) : super(key: key);

  @override
  State<ChatOverviewPage> createState() => _ChatOverviewPageState();
}

class _ChatOverviewPageState extends State<ChatOverviewPage> {
  final ChatOverviewController _controller = ChatOverviewController();

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
                future: _controller.getAllChatsOfUser(widget.user),
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
                  builder: (context) => NewChatPage(widget.user)));

              setState(() {});
            }))
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
                  return ChatHeaderWidget(
                      chatName: chatName, stream: stream, user: widget.user);
                }));
  }
}
