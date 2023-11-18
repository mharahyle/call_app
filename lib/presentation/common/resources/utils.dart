import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class ResponsiveUtils {
  static late MediaQueryData mediaQueryData;

  static void init(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
  }
}


class AgoraUser {
  final int uid;
  String? name;
  bool? isAudioEnabled;
  bool? isVideoEnabled;
  Widget? view;

  AgoraUser({
    required this.uid,
    this.name,
    this.isAudioEnabled,
    this.isVideoEnabled,
    this.view,
  });
}


CollectionReference usersCollection =
FirebaseFirestore.instance.collection("users");

CollectionReference callsCollection =
FirebaseFirestore.instance.collection("calls");