import 'package:flutter/material.dart';

import '../../core/model/chat_user.dart';
import 'Calls_Fragment.dart';
import 'Chat_Fragment.dart';
import 'Status_Fragment.dart';
import 'new_chat.dart';

class Home extends StatefulWidget {
  final ChatUser user;
  const Home(this.user,{Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
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
            Chat_Screen(widget.user),
            Status_Screen(),
            Calls_Screen(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            print(widget.user);
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NewChatPage(widget.user)));

            setState(() {});
          },
          backgroundColor: Color(0xFF075E54),
          child: const Icon(
            Icons.comment,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
