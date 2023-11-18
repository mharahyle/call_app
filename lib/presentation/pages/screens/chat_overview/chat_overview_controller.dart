import 'package:call_app/presentation/core/model/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

import '../../../core/model/chat_user.dart';

class ChatOverviewController {
  String getChatName(Chat chat, ChatUser user) {
    return chat.users.firstWhere((element) => element.id != user.id).name;
  }

  Future<List<Chat>> getAllChatsOfUser(ChatUser user) async {
    final res = <Chat>[];

    for (var chatId in user.chatIds) {
      res.add(Chat.fromJson((await FirebaseFirestore.instance
              .collection("chats")
              .doc(chatId)
              .get())
          .data()!));
    }

    return res;
  }

  String formatDateTime(DateTime datetime) {
    final now = DateTime.now();
    if (datetime.year == now.year &&
        datetime.month == now.month &&
        datetime.day == now.day) {
      return DateFormat(DateFormat.HOUR24_MINUTE).format(datetime);
    } else {
      return DateFormat.yMd().format(datetime);
    }
  }
}
