import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../pages/screens/home.dart';
import '../model/chat_user.dart';

class LoginController {


  Future<ChatUser>login(String email, String password,BuildContext context) async {

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
    return user;

  }



  Future<void> register(String email, String password, String username, BuildContext context) async {
    try {
      var cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

      var user = ChatUser(id: cred.user?.uid ?? "", name: username, chatIds: <String>[], isAudioEnabled: null, isVideoEnabled: null, view: null, uid: 0);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(cred.user?.uid ?? "")
          .set(user.toJson());

      // Registration successful, show a success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration successful'),
          duration: Duration(seconds: 2),
        ),
      );

    } catch (e) {

      // Show an error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during registration: $e'),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red, // You can customize the color
        ),
      );
    }
  }
}