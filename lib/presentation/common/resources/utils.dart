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