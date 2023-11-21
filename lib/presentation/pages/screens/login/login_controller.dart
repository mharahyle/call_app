import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../main.dart';
import '../../../core/model/chat_user.dart';


class LoginController {
  Future<ChatUser> login(String email, String password) async {
    var cred = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    var user = (await FirebaseFirestore.instance
            .collection("users")
            .where("id", isEqualTo: cred.user?.uid ?? "")
            .get())
        .docs
        .map((e) => ChatUser.fromJson(e.data()))
        .toList()
        .single;
    //update user info with latest token
  var updatedUser= await updateUserInfo(user);
    return updatedUser;
  }
  // Function to update user information

  Future<ChatUser> updateUserInfo(ChatUser userInfo) async {
      var updatedUser = ChatUser(id: userInfo.id, name:userInfo.name, chatIds:userInfo.chatIds, isAudioEnabled: userInfo.isAudioEnabled, isVideoEnabled: userInfo.isVideoEnabled, view: userInfo.view, uid: userInfo.uid, fcmToken: firebaseToken);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(updatedUser.id)
          .update(updatedUser.toJson());

      var getUpdatedUser = (await FirebaseFirestore.instance
          .collection("users")
          .where("id", isEqualTo: updatedUser.id)
          .get())
          .docs
          .map((e) => ChatUser.fromJson(e.data()))
          .toList()
          .single;
      print('User information updated ');
      return getUpdatedUser;


  }
  Future register(String email, String password, String username) async {
    var cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    var user =
        ChatUser(id: cred.user?.uid ?? "", name: username, chatIds: <String>[], isAudioEnabled: null, isVideoEnabled: null, view: null, uid: 0, fcmToken: firebaseToken);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(cred.user?.uid ?? "")
        .set(user.toJson());
  }
}
