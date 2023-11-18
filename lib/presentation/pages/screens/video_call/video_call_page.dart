import 'dart:io';
import 'dart:math';



import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../common/resources/utils.dart';
import '../../../core/model/chat_user.dart';
import '../../../widgets/call_row_button.dart';



class VideoCallPage extends StatefulWidget {
  const VideoCallPage({
    super.key,
    required this.appId,
    required this.token,
    required this.channelName,
    required this.user
  });

  final String appId;
  final String token;
  final String channelName;
  final ChatUser user;

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late final RtcEngine _agoraEngine;
  late final _users = <ChatUser>{};
  late double _viewAspectRatio;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  int? _currentUid;
  bool _isMicEnabled = false;
  bool _isCameraEnabled = false;
  bool _isJoining = false;

  Future<void> _getMicPermissions() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final micPermission = await Permission.microphone.request();
      if (micPermission == PermissionStatus.granted) {
        setState(() => _isMicEnabled = true);
      }
    } else {
      setState(() => _isMicEnabled = !_isMicEnabled);
    }
  }

  Future<void> _getCameraPermissions() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final cameraPermission = await Permission.camera.request();
      if (cameraPermission == PermissionStatus.granted) {
        setState(() => _isCameraEnabled = true);
      }
    } else {
      setState(() => _isCameraEnabled = !_isCameraEnabled);
    }
  }

  Future<void> _getPermissions() async {
    await _getMicPermissions();
    await _getCameraPermissions();
  }

  @override
  void initState() {
    _getPermissions();
    _initialize();
    initNotifications();
    super.initState();
  }

  @override
  void dispose() {
    _users.clear();
    _disposeAgora();
    super.dispose();
  }

  Future<void> _disposeAgora() async {
    await _agoraEngine.leaveChannel();
    await _agoraEngine.destroy();
  }

  Future<void> _initialize() async {
    // Set aspect ratio for video according to platform
    if (kIsWeb) {
      _viewAspectRatio = 3 / 2;
    } else if (Platform.isAndroid || Platform.isIOS) {
      _viewAspectRatio = 2 / 3;
    } else {
      _viewAspectRatio = 3 / 2;
    }
    // Initialize microphone and camera

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    final options = ChannelMediaOptions(
      publishLocalAudio: _isMicEnabled,
      publishLocalVideo: _isCameraEnabled,
    );
    await _agoraEngine.joinChannel(
      null,
      widget.channelName,
      null,
      0,
      options,
    );
  }
  void initNotifications() {
    var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _showIncomingCallNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'incoming_call_channel',
      'simple Call App',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );


    await flutterLocalNotificationsPlugin.show(
      0,
      'Incoming Call',
      'You have an incoming call',
      const NotificationDetails(android: androidPlatformChannelSpecifics),
      payload: 'incoming_call',
    );
  }

  Future<void> _initAgoraRtcEngine() async {
    _agoraEngine = await RtcEngine.create(widget.appId);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.orientationMode = VideoOutputOrientationMode.Adaptative;
    await _agoraEngine.setVideoEncoderConfiguration(configuration);
    await _agoraEngine.enableAudio();
    await _agoraEngine.enableVideo();
    await _agoraEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _agoraEngine.setClientRole(ClientRole.Broadcaster);
    await _agoraEngine.muteLocalAudioStream(!_isMicEnabled);
    await _agoraEngine.muteLocalVideoStream(!_isCameraEnabled);
  }

  void _addAgoraEventHandlers() => _agoraEngine.setEventHandler(
    RtcEngineEventHandler(
      error: (code) {
        final info = 'LOG::onError: $code';
        debugPrint(info);
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        _showIncomingCallNotification();
        final info = 'LOG::onJoinChannel: $channel, uid: $uid';
        debugPrint(info);
        setState(() {
          _currentUid = uid;
          _users.add(

            ChatUser(
              id: widget.user.id,
              isAudioEnabled: _isMicEnabled,
              isVideoEnabled: _isCameraEnabled,
              view: const rtc_local_view.SurfaceView(),
            uid: uid,
            name: widget.user.name,
            chatIds: widget.user.chatIds,
            ),
          );
        });
      },
      firstLocalAudioFrame: (elapsed) {
        final info = 'LOG::firstLocalAudio: $elapsed';
        debugPrint(info);
        for (ChatUser user in _users) {
          if (user.uid == _currentUid) {
            setState(() => user.isAudioEnabled = _isMicEnabled);
          }
        }
      },
      firstLocalVideoFrame: (width, height, elapsed) {
        debugPrint('LOG::firstLocalVideo');
        for (ChatUser user in _users) {
          if (user.uid == _currentUid) {
            setState(
                  () => user
                ..isVideoEnabled = _isCameraEnabled
                ..view = const rtc_local_view.SurfaceView(
                  renderMode: VideoRenderMode.Hidden,
                ),
            );
          }
        }
      },
      leaveChannel: (stats) {
        debugPrint('LOG::onLeaveChannel');
        setState(() => _users.clear());
      },
      userJoined: (uid, elapsed) {
        final info = 'LOG::userJoined: $uid';
        debugPrint(info);

        setState(
              () => _users.add(
            ChatUser(
              uid: uid,
              view: rtc_remote_view.SurfaceView(
                channelId: widget.channelName,
                uid: uid,
              ), id: '',
              name: '',
              chatIds: [],
              isAudioEnabled: null,
              isVideoEnabled: null,
            ),
          ),
        );
      },
      userOffline: (uid, elapsed) {
        final info = 'LOG::userOffline: $uid';
        debugPrint(info);
        ChatUser? userToRemove;
        for (ChatUser user in _users) {
          if (user.uid == uid) {
            userToRemove = user;
          }
        }
        setState(() => _users.remove(userToRemove));
      },
      firstRemoteAudioFrame: (uid, elapsed) {
        final info = 'LOG::firstRemoteAudio: $uid';
        debugPrint(info);
        for (ChatUser user in _users) {
          if (user.uid == uid) {
            setState(() => user.isAudioEnabled = true);
          }
        }
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        final info = 'LOG::firstRemoteVideo: $uid ${width}x $height';
        debugPrint(info);
        for (ChatUser user in _users) {
          if (user.uid == uid) {
            setState(
                  () => user
                ..isVideoEnabled = true
                ..view = rtc_remote_view.SurfaceView(
                  channelId: widget.channelName,
                  uid: uid,
                ),
            );
          }
        }
      },
      remoteVideoStateChanged: (uid, state, reason, elapsed) {
        final info = 'LOG::remoteVideoStateChanged: $uid $state $reason';
        debugPrint(info);
        for (ChatUser user in _users) {
          if (user.uid == uid) {
            setState(() =>
            user.isVideoEnabled = state != VideoRemoteState.Stopped);
          }
        }
      },
      remoteAudioStateChanged: (uid, state, reason, elapsed) {
        final info = 'LOG::remoteAudioStateChanged: $uid $state $reason';
        debugPrint(info);
        for (ChatUser user in _users) {
          if (user.uid == uid) {
            setState(() =>
            user.isAudioEnabled = state != AudioRemoteState.Stopped);
          }
        }
      },
    ),
  );

  Future<void> _onCallEnd(BuildContext context) async {
    await _agoraEngine.leaveChannel();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  void _onToggleAudio() {
    setState(() {
      _isMicEnabled = !_isMicEnabled;
      for (ChatUser user in _users) {
        if (user.uid == _currentUid) {
          user.isAudioEnabled = _isMicEnabled;
        }
      }
    });
    _agoraEngine.muteLocalAudioStream(!_isMicEnabled);
  }

  void _onToggleCamera() {
    setState(() {
      _isCameraEnabled = !_isCameraEnabled;
      for (ChatUser user in _users) {
        if (user.uid == _currentUid) {
          setState(() => user.isVideoEnabled = _isCameraEnabled);
        }
      }
    });
    _agoraEngine.muteLocalVideoStream(!_isCameraEnabled);
  }

  void _onSwitchCamera() => _agoraEngine.switchCamera();

  List<int> _createLayout(int n) {
    int rows = (sqrt(n).ceil());
    int columns = (n / rows).ceil();

    List<int> layout = List<int>.filled(rows, columns);
    int remainingScreens = rows * columns - n;

    for (int i = 0; i < remainingScreens; i++) {
      layout[layout.length - 1 - i] -= 1;
    }

    return layout;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.black,
        centerTitle: false,
        title: Row(
          children: [
            const Icon(
              Icons.meeting_room_rounded,
              color: Colors.white54,
            ),
            const SizedBox(width: 6.0),
            // const Text(
            //   'Channel name: ',
            //   style: TextStyle(
            //     color: Colors.white54,
            //     fontSize: 16.0,
            //   ),
            // ),
            // Text(
            //   widget.channelName,
            //   style: const TextStyle(
            //     color: Colors.white,
            //     fontSize: 16.0,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.people_alt_rounded,
                  color: Colors.white54,
                ),
                const SizedBox(width: 6.0),
                Text(
                  _users.length.toString(),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    final isPortrait = orientation == Orientation.portrait;
                    if (_users.isEmpty) {
                      return const SizedBox();
                    }
                    WidgetsBinding.instance.addPostFrameCallback(
                          (_) => setState(
                              () => _viewAspectRatio = isPortrait ? 2 / 3 : 3 / 2),
                    );
                    final layoutViews = _createLayout(_users.length);
                    return AgoraVideoLayout(
                      users: _users,
                      views: layoutViews,
                      viewAspectRatio: _viewAspectRatio,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: CallActionsRow(
                isMicEnabled: _isMicEnabled,
                isVideoEnabled: _isCameraEnabled,
                onCallEnd: () => _onCallEnd(context),
                onToggleAudio: _onToggleAudio,
                onToggleCamera: _onToggleCamera,
                onSwitchCamera: _onSwitchCamera,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AgoraVideoLayout extends StatelessWidget {
  const AgoraVideoLayout({
    super.key,
    required Set<ChatUser> users,
    required List<int> views,
    required double viewAspectRatio,
  })  : _users = users,
        _views = views,
        _viewAspectRatio = viewAspectRatio;

  final Set<ChatUser> _users;
  final List<int> _views;
  final double _viewAspectRatio;

  @override
  Widget build(BuildContext context) {
    int totalCount = _views.reduce((value, element) => value + element);
    int rows = _views.length;
    int columns = _views.reduce(max);

    List<Widget> rowsList = [];
    for (int i = 0; i < rows; i++) {
      List<Widget> rowChildren = [];
      for (int j = 0; j < columns; j++) {
        int index = i * columns + j;
        if (index < totalCount) {
          rowChildren.add(
            AgoraVideoView(
              user: _users.elementAt(index),
              viewAspectRatio: _viewAspectRatio,
            ),
          );
        } else {
          rowChildren.add(
            const SizedBox.shrink(),
          );
        }
      }
      rowsList.add(
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowChildren,
          ),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: rowsList,
    );
  }
}

class AgoraVideoView extends StatelessWidget {
  const AgoraVideoView({
    super.key,
    required double viewAspectRatio,
    required ChatUser user,
  })  : _viewAspectRatio = viewAspectRatio,
        _user = user;

  final double _viewAspectRatio;
    final ChatUser _user;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: AspectRatio(
          aspectRatio: _viewAspectRatio,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: _user.isAudioEnabled ?? false ? Colors.blue : Colors.red,
                width: 2.0,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    maxRadius: 18,
                    child: Icon(
                      Icons.person,
                      color: Colors.grey.shade600,
                      size: 24.0,
                    ),
                  ),
                ),
                if (_user.isVideoEnabled ?? false)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8 - 2),
                    child: _user.view,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
