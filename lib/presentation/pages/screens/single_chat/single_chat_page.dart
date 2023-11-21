import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:call_app/presentation/pages/screens/single_chat/single_chat_controller.dart';
import 'package:call_app/presentation/pages/screens/single_chat/widgets/chat_message_widget.dart';
import 'package:call_app/presentation/pages/screens/single_chat/widgets/send_message_field_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../../main.dart';
import '../../../core/model/call.dart';
import '../../../core/model/chat.dart';
import '../../../core/model/chat_user.dart';
import '../../../widgets/call_option.dart';
import '../../../widgets/loading.dart';
import '../video_call/video_call_page.dart';

class SingleChatPage extends StatefulWidget {
  final Chat chat;
  final ChatUser user;
  final ReceivedAction? receivedAction;

  const SingleChatPage(this.chat, this.user,this.receivedAction, {Key? key}) : super(key: key);

  @override

  State<SingleChatPage> createState() => _SingleChatPageState();
}

class _SingleChatPageState extends State<SingleChatPage> {
  final SingleChatController _controller = SingleChatController();
  bool _isJoining = false;
  String? firebasetoken ;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  void _initializeFirebaseMessaging() async{
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String? title=message.notification!.title;
      String? body=message.notification!.body;
      AwesomeNotifications().createNotification(
          content: NotificationContent(id: 123,
              channelKey: 'call_channel',
              color: Colors.white,
              title: title,
              body: body,
              category: NotificationCategory.Call,
              wakeUpScreen: true,
              fullScreenIntent: true,
              autoDismissible: false,
              backgroundColor: Colors.blue
          ),
          actionButtons: [
            NotificationActionButton(key: 'ACCEPT', label: 'Accept Call',color: Colors.green,autoDismissible: true),
            NotificationActionButton(key: 'REJECT', label: 'Reject Call',color: Colors.red,autoDismissible: true)
          ]
      );
      AwesomeNotifications().setListeners(onActionReceivedMethod:onActionReceivedMethod );
      _showIncomingCallOverlay(message.data['callerName']);
    }
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle when the app is opened by tapping the notification.
      // You can navigate to the call screen here.
    });

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    _firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      provisional: false,
    );
  }

   Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == "ACCEPT") {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoCallPage(
            appId: appId,
            token: token,
            channelName: 'Simple Call App',
            user: widget.user,
            call:  CallModel(
              id: null,
              channel: "video${widget.user.id}",
              caller: widget.user.name,
              called: widget.user.id,
              active: null,
              accepted: null,
              rejected: null,
              connected: null,
            ),
          ),
        ),
      );


    }
    if (receivedAction.buttonKeyPressed == "REJECT") {
      Navigator.of(context).pop();
    }
  }

  Future<void> sendPushNotification() async {
    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=AAAAkDy68S8:APA91bE4TiwNo1uHlSeugugJ9duTM8gqfmFEAG8ASNjePCiKe8gORYCjeykGt2wfSLYCZZ0F-BhMVu2GYzLniJrp7Zc_DuUTeaKcdDrQ5PC-oJeeZJVxF9MPuRo5T-KIOfD6-MD5_EDu',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': 'Dave',
              'title': 'Incoming Call',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': widget.chat.users.where((item) => item.id != widget.user.id).toList().first.fcmToken,

          },
        ),
      );
      response;
    } catch (e) {
      e;
    }
  }

  void _showIncomingCallOverlay(String callerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Incoming Call from $callerName'),
        actions: [
          TextButton(
            onPressed: () {
              // Answer call logic
            },
            child: Text('Answer'),
          ),
          TextButton(
            onPressed: () {
              // Decline call logic
            },
            child: Text('Decline'),
          ),
        ],
      ),
    );
  }
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handle the background message (notification) when the app is in the background
 ;
  }

  Future<void> _sendFcmNotification(String? receiverFcmToken, String callerName) async {
    await FirebaseMessaging.instance.sendMessage(
      to: receiverFcmToken,
      data: {
        'type': 'incoming_call',
        'callerName': callerName,
      },
    ).catchError((error) {
      print('Error sending FCM notification: $error');
    });
  }
  void _handleFcmMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == 'incoming_call') {
        // Handle incoming call notification
        _showIncomingCallOverlay(message.data['callerName']);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['type'] == 'incoming_call') {
        // Handle opening the app from incoming call notification
        _showIncomingCallOverlay(message.data['callerName']);
      }
    });
  }

  void _initiateCallAndNotify() async {
    // Send FCM notification to the other device
    await sendPushNotification();// Get the caller's name
   // await _sendFcmNotification(widget.user.fcmToken, callerName);
    // Make the call
    _joinCall();

  }
  Future<void> _joinCall() async {
    setState(() => _isJoining = true);
   // await dotenv.load(fileName: "functions/.env");
    final appId = "548f443b3f7d4a5987b0b1bb7ba5a4d3";
    setState(() => _isJoining = false);
    if (context.mounted) {
      Navigator.of(context).pop();
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoCallPage(
              appId: appId,
              token: token,
              channelName: 'Simple Call App',
            user: widget.user,
            call:  CallModel(
              id: null,
              channel: "video${widget.user.id}",
              caller: widget.user.name,
              called: widget.user.id,
              active: null,
              accepted: null,
              rejected: null,
              connected: null,
            ),
          ),
        ),
      );
    }
  }
  Future<void> _joinRoom() async {
    final input = <String, dynamic>{
      'channelName':'simple Call App',
      'expiryTime': 3600, // 1 hour
    };
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('generateToken')
          .call(input);
      final token = response.data as String?;
      if (token != null) {
        debugPrint('Token generated successfully!');
        await Future.delayed(
          const Duration(seconds: 1),
        );
        if (context.mounted) {
          await

          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                child: Wrap(
                  children: <Widget>[
                    Center(
                      child:Text('Select a call ')
                    ),
                    SizedBox(height: 5),
                    ListTile(
                      title: Text('Voice Call'),
                      onTap: () {
                        // Handle Option 1
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(

                      title: Text('Video Call'),
                      onTap: _initiateCallAndNotify,
                    )
                  ],
                ),
              );
            },
          );

        }
      }
    } catch (e) {
      debugPrint('Error generating token: $e');
    }
  }
  void initState() {

    _initializeFirebaseMessaging();
    // Handle FCM messages
    _handleFcmMessages();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage("assets/images/background.png"),
    fit: BoxFit.cover,
    ),
    ),
    child:
      Scaffold(
        bottomSheet: SendMessageFieldWidget(onPressed: _sendMessage),
        appBar: AppBar(
            title: Text(_controller.getChatName(widget.chat, widget.user)),
          backgroundColor: Color(0xFF075E54),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.video_call),
            ),
            IconButton(
              onPressed:  _joinRoom,
              icon: const Icon(Icons.call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ]),
        body: _buildMessagesWidget())
    );
  }

  Widget _buildMessagesWidget() {
    return widget.chat.messages.isEmpty
        ? const Center(child: Text("Start a conversation!"))
        : Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 68),
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chats")
                    .doc(widget.chat.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  var myChat = snapshot.hasData
                      ? Chat.fromJson(snapshot.data!.data()!)
                      : null;

                  return myChat == null
                      ? const LoadingWidget()
                      : ListView.separated(
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 5),
                          itemCount: myChat.messages.length,
                          itemBuilder: (context, index) {
                            var message = myChat.messages[index];
                            var isLocal = message.sender.id == widget.user.id;

                            return ChatMessageWidget(
                                timestamp: message.timestamp,
                                content: message.content,
                                isLocalSender: isLocal);
                          });
                }),
          );
  }

  Future _sendMessage(String message) async {
    await _controller.sendMessage(widget.chat.id, widget.user, message);

    setState(() {});
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.star),
                title: Text('Option 1'),
                onTap: () {
                  // Handle Option 1
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text('Option 2'),
                onTap: () {
                  // Handle Option 2
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.send),
                title: Text('Option 3'),
                onTap: () {
                  // Handle Option 3
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
