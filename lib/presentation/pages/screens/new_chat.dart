import 'package:flutter/material.dart';

import '../../core/helper/new_chat.dart';
import '../../core/model/chat.dart';
import '../../core/model/chat_user.dart';
import '../../widgets/exception.dart';
import '../../widgets/loading.dart';
import 'MessageSection.dart';

class NewChatPage extends StatefulWidget {
  final ChatUser localUser;
  const NewChatPage(this.localUser, {Key? key}) : super(key: key);

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
        appBar: AppBar(title: const Text("Select your partner")),
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
                        leading: const CircleAvatar(
                            child: Icon(Icons.person)),
                        title: Text(snapshot.data![index].name),
                        onTap: () async =>
                            _startNewChat(snapshot.data![index] ),
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
        builder: (context) => Message_screeen(chat!, widget.localUser)));
  }
}