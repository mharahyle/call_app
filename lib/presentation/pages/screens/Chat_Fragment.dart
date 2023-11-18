import 'package:flutter/material.dart';

import '../../core/model/chat_user.dart';
import '../../widgets/contact_list.dart';


class Chat_Screen extends StatefulWidget {
  final ChatUser user;
  const Chat_Screen(this.user,{Key? key}) : super(key: key);

  @override
  State<Chat_Screen> createState() => _Chat_ScreenState();
}

class _Chat_ScreenState extends State<Chat_Screen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: ContactList(widget.user),
    );
  }
}
