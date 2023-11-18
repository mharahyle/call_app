// import 'dart:io';
// import 'dart:math';
// import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
//
// import '../../../../main.dart';
// import '../../../common/resources/utils.dart';
// import '../../../core/model/call.dart';
// import '../../../core/model/chat_user.dart';
//
// const appID = "YOUR OWN APP ID PROVIDED BY AGORA";
// const tokenBaseUrl = "https://[LINK NAME].herokuapp.com";
//
// class VideoPage extends StatefulWidget {
//   final ChatUser user;
//   final CallModel call;
//   final String appId;
//   final String token;
//   final String channelName;
//   const VideoPage({super.key,
//     required this.user,
//     required this.call,
//     required this.appId,
//     required this.token,
//     required this.channelName,
//   });
//
//   @override
//   State<VideoPage> createState() => _VideoPageState();
// }
//
// class _VideoPageState extends State<VideoPage> {
//   late final RtcEngine _agoraEngine;
//   String? token;
//   int uid = 0;
//   bool localUserJoined = false;
//   String? callID;
//   int? remoteUid;
//   int? _currentUid;
//   bool _isMicEnabled = false;
//   bool _isCameraEnabled = false;
//   late double _viewAspectRatio;
//   late final _users = <ChatUser>{};
//
//   @override
//   void initState() {
//     setState(() {
//       callID = widget.call.id;
//       _initialize();
//     });
//     super.initState();
//     Future.delayed(const Duration(milliseconds: 1000)).then(
//           (_) {
//         getToken();
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     _disposeAgora();
//     super.dispose();
//   }
//
//   Future<void> getToken() async {
//     final response = await http.get(Uri.parse(
//         '$tokenBaseUrl/rtc/${widget.call.channel}/publisher/uid/$uid?expiry=3600'));
//     if (response.statusCode == 200) {
//       setState(() {
//         token = jsonDecode(response.body)['rtcToken'];
//       });
//       initializeCall();
//     }
//   }
//
//
//   Future<void> _disposeAgora() async {
//     await _agoraEngine.leaveChannel();
//     await _agoraEngine.destroy();
//   }
//
//   Future<void> _initialize() async {
//     // Set aspect ratio for video according to platform
//     if (kIsWeb) {
//       _viewAspectRatio = 3 / 2;
//     } else if (Platform.isAndroid || Platform.isIOS) {
//       _viewAspectRatio = 2 / 3;
//     } else {
//       _viewAspectRatio = 3 / 2;
//     }
//     // Initialize microphone and camera
//
//     await _initAgoraRtcEngine();
//     _addAgoraEventHandlers();
//     final options = ChannelMediaOptions(
//       publishLocalAudio: _isMicEnabled,
//       publishLocalVideo: _isCameraEnabled,
//     );
//     await _agoraEngine.joinChannel(
//       null,
//       widget.channelName,
//       null,
//       0,
//       options,
//     );
//   }
//
//   Future<void> _initAgoraRtcEngine() async {
//     _agoraEngine = await RtcEngine.create(widget.appId);
//     VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
//     configuration.orientationMode = VideoOutputOrientationMode.Adaptative;
//     await _agoraEngine.setVideoEncoderConfiguration(configuration);
//     await _agoraEngine.enableAudio();
//     await _agoraEngine.enableVideo();
//     await _agoraEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
//     await _agoraEngine.setClientRole(ClientRole.Broadcaster);
//     await _agoraEngine.muteLocalAudioStream(!_isMicEnabled);
//     await _agoraEngine.muteLocalVideoStream(!_isCameraEnabled);
//   }
//
//
//   void _addAgoraEventHandlers() => _agoraEngine.setEventHandler(
//     RtcEngineEventHandler(
//       error: (code) {
//         final info = 'LOG::onError: $code';
//         debugPrint(info);
//       },
//       joinChannelSuccess: (channel, uid, elapsed) {
//         final info = 'LOG::onJoinChannel: $channel, uid: $uid';
//         debugPrint(info);
//         setState(() {
//           _currentUid = uid;
//           _users.add(
//
//             ChatUser(
//               id: widget.user.id,
//               isAudioEnabled: _isMicEnabled,
//               isVideoEnabled: _isCameraEnabled,
//               view: const rtc_local_view.SurfaceView(),
//               uid: uid,
//               name: widget.user.name,
//               chatIds: widget.user.chatIds,
//             ),
//           );
//         });
//       },
//       firstLocalAudioFrame: (elapsed) {
//         final info = 'LOG::firstLocalAudio: $elapsed';
//         debugPrint(info);
//         for (ChatUser user in _users) {
//           if (user.uid == _currentUid) {
//             setState(() => user.isAudioEnabled = _isMicEnabled);
//           }
//         }
//       },
//       firstLocalVideoFrame: (width, height, elapsed) {
//         debugPrint('LOG::firstLocalVideo');
//         for (ChatUser user in _users) {
//           if (user.uid == _currentUid) {
//             setState(
//                   () => user
//                 ..isVideoEnabled = _isCameraEnabled
//                 ..view = const rtc_local_view.SurfaceView(
//                   renderMode: VideoRenderMode.Hidden,
//                 ),
//             );
//           }
//         }
//       },
//       leaveChannel: (stats) {
//         debugPrint('LOG::onLeaveChannel');
//         setState(() => _users.clear());
//       },
//       userJoined: (uid, elapsed) {
//         final info = 'LOG::userJoined: $uid';
//         debugPrint(info);
//
//         setState(
//               () => _users.add(
//             ChatUser(
//               uid: uid,
//               view: rtc_remote_view.SurfaceView(
//                 channelId: widget.channelName,
//                 uid: uid,
//               ), id: '',
//               name: '',
//               chatIds: [],
//               isAudioEnabled: null,
//               isVideoEnabled: null,
//             ),
//           ),
//         );
//       },
//       userOffline: (uid, elapsed) {
//         final info = 'LOG::userOffline: $uid';
//         debugPrint(info);
//         ChatUser? userToRemove;
//         for (ChatUser user in _users) {
//           if (user.uid == uid) {
//             userToRemove = user;
//           }
//         }
//         setState(() => _users.remove(userToRemove));
//       },
//       firstRemoteAudioFrame: (uid, elapsed) {
//         final info = 'LOG::firstRemoteAudio: $uid';
//         debugPrint(info);
//         for (ChatUser user in _users) {
//           if (user.uid == uid) {
//             setState(() => user.isAudioEnabled = true);
//           }
//         }
//       },
//       firstRemoteVideoFrame: (uid, width, height, elapsed) {
//         final info = 'LOG::firstRemoteVideo: $uid ${width}x $height';
//         debugPrint(info);
//         for (ChatUser user in _users) {
//           if (user.uid == uid) {
//             setState(
//                   () => user
//                 ..isVideoEnabled = true
//                 ..view = rtc_remote_view.SurfaceView(
//                   channelId: widget.channelName,
//                   uid: uid,
//                 ),
//             );
//           }
//         }
//       },
//       remoteVideoStateChanged: (uid, state, reason, elapsed) {
//         final info = 'LOG::remoteVideoStateChanged: $uid $state $reason';
//         debugPrint(info);
//         for (ChatUser user in _users) {
//           if (user.uid == uid) {
//             setState(() =>
//             user.isVideoEnabled = state != VideoRemoteState.Stopped);
//           }
//         }
//       },
//       remoteAudioStateChanged: (uid, state, reason, elapsed) {
//         final info = 'LOG::remoteAudioStateChanged: $uid $state $reason';
//         debugPrint(info);
//         for (ChatUser user in _users) {
//           if (user.uid == uid) {
//             setState(() =>
//             user.isAudioEnabled = state != AudioRemoteState.Stopped);
//           }
//         }
//       },
//     ),
//   );
//
//
//   makeCall() async {
//     DocumentReference callDocRef = callsCollection.doc();
//     setState(() {
//       callID = callDocRef.id;
//     });
//     await callDocRef.set(
//       {
//         'id': callDocRef.id,
//         'channel': widget.call.channel,
//         'caller': widget.call.caller,
//         'called': widget.call.called,
//         'active': true,
//         'accepted': false,
//         'rejected': false,
//         'connected': false,
//       },
//     );
//   }
//
//   // Future joinVideoChannel() async {
//   //   await rtcEngine?.startPreview();
//   //
//   //   ChannelMediaOptions options = const ChannelMediaOptions(
//   //     clientRoleType: ClientRoleType.clientRoleBroadcaster,
//   //     channelProfile: ChannelProfileType.channelProfileCommunication,
//   //   );
//   //
//   //   await rtcEngine?.joinChannel(
//   //       token: token!,
//   //       channelId: widget.call.channel,
//   //       uid: uid,
//   //       options: options);
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           elevation: 0,
//           centerTitle: true,
//           title: Text(
//             widget.user.name,
//             style: const TextStyle(
//               color: Colors.black,
//             ),
//           ),
//         ),
//         body: localUserJoined == false || callID == null
//             ? const Center(
//           child: CircularProgressIndicator(),
//         )
//             : StreamBuilder<DocumentSnapshot>(
//           stream: callsCollection.doc(callID!).snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//
//               CallModel call = CallModel(
//                 id: snapshot.data!['id'],
//                 channel: snapshot.data!['channel'],
//                 caller: snapshot.data!['caller'],
//                 called: snapshot.data!['called'],
//                 active: snapshot.data!['active'],
//                 accepted: snapshot.data!['accepted'],
//                 rejected: snapshot.data!['rejected'],
//                 connected: snapshot.data!['connected'],
//               );
//
//               return call.rejected == true
//                   ? const Text("Call Declined")
//                   : Stack(
//                 children: [
//                   //OTHER USER'S VIDEO WIDGET
//                   Center(
//                     child: remoteVideo(call: call),
//                   ),
//                   //LOCAL USER VIDEO WIDGET
//                   if (_agoraEngine != null)
//                     Positioned.fill(
//                       child: Align(
//                         alignment: Alignment.topLeft,
//                         child: SizedBox(
//                           width: 100,
//                           height: 150,
//                           child: AgoraVideoView(
//                             controller: VideoViewController(
//                               rtcEngine: rtcEngine!,
//                               canvas: VideoCanvas(uid: uid),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   Positioned.fill(
//                     child: Align(
//                       alignment: Alignment.bottomCenter,
//                       child: Padding(
//                         padding: const EdgeInsets.only(bottom: 40),
//                         child: FloatingActionButton(
//                           backgroundColor: Colors.red,
//                           onPressed: () {
//                             _agoraEngine?.leaveChannel();
//                           },
//                           child: const Icon(
//                             Icons.call_end_rounded,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }
//             return const SizedBox.shrink();
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget remoteVideo({required CallModel call}) {
//     return Stack(
//       children: [
//         if (remoteUid != null)
//           AgoraVideoView(
//             controller: VideoViewController.remote(
//               rtcEngine: rtcEngine!,
//               canvas: VideoCanvas(uid: remoteUid),
//               connection: RtcConnection(channelId: call.channel),
//             ),
//           ),
//         if (remoteUid == null)
//           Positioned.fill(
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   userPhoto(radius: 50, url: widget.user.photo),
//                   Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Text(call.connected == false
//                         ? "Connecting to ${widget.user.name}"
//                         : "Waiting Response"),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
