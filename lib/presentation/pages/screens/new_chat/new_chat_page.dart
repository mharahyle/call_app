import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:call_app/presentation/core/model/chat_user.dart';
import 'package:call_app/presentation/pages/screens/new_chat/new_chat_controller.dart';
import 'package:call_app/presentation/pages/screens/single_chat/single_chat_page.dart';
import 'package:flutter/material.dart';

import '../../../core/model/chat.dart';
import '../../../widgets/exception.dart';
import '../../../widgets/loading.dart';


class NewChatPage extends StatefulWidget {
  final ChatUser localUser;
  final ReceivedAction? receivedAction;
  const NewChatPage(this.localUser,this.receivedAction, {Key? key}) : super(key: key);

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final NewChatController _controller = NewChatController();
  Future<List<ChatUser>>? _future;

  @override
  void initState() {
    super.initState();

    _future = _controller.getAllPossibleChatPartners(widget.localUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("New Contact"),
          backgroundColor: Color(0xFF075E54),),
        body: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const LoadingWidget();
              } else if (snapshot.hasData) {
                return snapshot.data!.isEmpty
                    ? const Center(child: Text("No chat users found!"))
                    : ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Icon(Icons.person),
                                  radius: 30,
                                ),
                                title: Text(snapshot.data![index].name, style: const TextStyle(
                                  fontSize: 18,
                                ),),
                                onTap: () async =>
                                    _startNewChat(snapshot.data![index]),
                              ),
                            ));
              }

              return const ExceptionWidget();
            }));
  }

  Future _startNewChat(ChatUser chatPartner) async {
    Chat? chat =
        await _controller.getExistingChat(widget.localUser, chatPartner);

    chat ??= await _controller.createNewChat(widget.localUser, chatPartner);
    await Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => SingleChatPage(chat!, widget.localUser,widget.receivedAction)));
  }
}
