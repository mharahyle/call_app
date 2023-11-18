import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class showCallOption extends StatefulWidget {
  const showCallOption({
    super.key,
    required this.token,
    required this.channelName,
  });

  final String token;
  final String channelName;

  @override
  State<showCallOption> createState() => _showCallOptionState();
}

class _showCallOptionState extends State<showCallOption> {
  bool _isJoining = false;


  // Future<void> _joinCall() async {
  //   setState(() => _isJoining = true);
  //   await dotenv.load(fileName: "functions/.env");
  //   final appId = dotenv.env['APP_ID'];
  //   if (appId == null) {
  //     throw Exception('Please add your APP_ID to .env file');
  //   }
  //   setState(() => _isJoining = false);
  //   if (context.mounted) {
  //     Navigator.of(context).pop();
  //     await Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (context) => VideoCallPage(
  //           appId: appId,
  //           token: widget.token,
  //           channelName: widget.channelName, user: null,
  //         ),
  //       ),
  //     );
  //   }
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _showBottomSheet(context);

  }


   _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(

                title: Text('Voice Call'),
                onTap: () {
                  // Handle Option 1
                  Navigator.pop(context);
                },
              ),
              ListTile(

                title: Text('Video Call'),
                onTap: () {},
              )
            ],
          ),
        );
      },
    );
  }
}

