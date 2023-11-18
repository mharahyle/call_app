import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helper/authentication.dart';
import '../model/chat_user.dart';

class UserProvider with ChangeNotifier {
  ChatUser? _user;

  ChatUser? get user => _user;

  Future<void> login(String email, String password) async {
    var cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    var userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(cred.user?.uid)
        .get();

    _user = ChatUser.fromJson(userData.data() ?? {});
    notifyListeners();
  }
}
