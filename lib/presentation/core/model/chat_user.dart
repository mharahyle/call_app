import 'package:flutter/material.dart';

class ChatUser {
  ChatUser({
    required this.uid,
    required this.id,
    required this.name,
    required this.chatIds,
    required this.isAudioEnabled,
    required this.isVideoEnabled,
    required this.view,
    required this.fcmToken

  });
  final int uid;
  final String id;
  final String name;
  final List<String> chatIds;
 late final bool? isAudioEnabled;
late final  bool? isVideoEnabled;
 late final  Widget? view;
 late final String? fcmToken;
  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      chatIds: json["chatIds"] == null
          ? []
          : List<String>.from(json["chatIds"]!.map((x) => x)),
      isAudioEnabled:  json['isAudioEnabled'] ?? null,
      isVideoEnabled: json['isVideoEnabled'] ?? null,
      view:  json['view'] ?? null,
      uid: json["uid"] ?? 0,
      fcmToken: json["fcmToken"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "chatIds": chatIds.map((x) => x).toList(),
    "isAudioEnabled":isAudioEnabled,
    "isVideoEnabled":isVideoEnabled,
    "view":view,
    "uid":uid,
    "fcmToken":fcmToken
  };
}