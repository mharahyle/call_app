import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:call_app/presentation/common/notification_services.dart';
import 'package:call_app/presentation/common/resources/utils.dart';
import 'package:call_app/presentation/pages/onboarding/splash_screen/splash.dart';
import 'package:call_app/presentation/pages/screens/chat_overview/chat_overview_page.dart';
import 'package:call_app/presentation/pages/screens/single_chat/single_chat_page.dart';
import 'package:call_app/presentation/resources/Theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'presentation/pages/screens/login/login_page.dart';
const appId = "58e47c933da546c7acc40a0fe39b0181";
const token =  "9242dc01e9524024b6e7482ba7e6528b";

Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage remoteMessage) async {
  await  await Firebase.initializeApp(
    name: 'com.example.call_appChoikangta',
    options: const FirebaseOptions(
      apiKey: "AAAAkDy68S8:APA91bE4TiwNo1uHlSeugugJ9duTM8gqfmFEAG8ASNjePCiKe8gORYCjeykGt2wfSLYCZZ0F-BhMVu2GYzLniJrp7Zc_DuUTeaKcdDrQ5PC-oJeeZJVxF9MPuRo5T-KIOfD6-MD5_EDu",
      appId: "1:619494175023:android:81c81fb5763491641471da",
      messagingSenderId: "619494175023",
      projectId: "call-app-c3cbf",
    ),
  );
  //SHOW NOTIFICATION
  await NotificationServices.showNotification(remoteMessage: remoteMessage);
  await callsCollection.doc(remoteMessage.data['id']).update(
    {
      'connected': true,
    },
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'com.example.call_appChoikangta',
    options: const FirebaseOptions(
      apiKey: "AAAAkDy68S8:APA91bE4TiwNo1uHlSeugugJ9duTM8gqfmFEAG8ASNjePCiKe8gORYCjeykGt2wfSLYCZZ0F-BhMVu2GYzLniJrp7Zc_DuUTeaKcdDrQ5PC-oJeeZJVxF9MPuRo5T-KIOfD6-MD5_EDu",
      appId: "1:619494175023:android:81c81fb5763491641471da",
      messagingSenderId: "619494175023",
      projectId: "call-app-c3cbf",
    ),
  );
  await NotificationServices.initializeNotification();
  await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications(
          channelKey: "high_importance_channel");
    }
  });

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(
        (RemoteMessage remoteMessage) async {
      await NotificationServices.showNotification(remoteMessage: remoteMessage);
      await callsCollection.doc(remoteMessage.data['id']).update(
        {
          'connected': true,
        },
      );
    },
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const  MyApp({Key? key}) : super(key: key);

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  static const String routeHome = '/', routeNotification = '/call-page';

  @override
  void initState() {
    NotificationServices.startListeningNotificationEvents();
    super.initState();
  }

  List<Route<dynamic>> onGenerateInitialRoutes(String initialRouteName) {
    List<Route<dynamic>> pageStack = [];

    pageStack.add(MaterialPageRoute(builder: (_) =>  LoginPage()));

    if (NotificationServices.initialAction != null) {
      pageStack.add(MaterialPageRoute(
          builder: (_) => ChatOverviewPage(
            null,
            NotificationServices.initialAction,
          )));
    }

    return pageStack;
  }

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case routeHome:
        ReceivedAction receivedAction = settings.arguments as ReceivedAction;
        return MaterialPageRoute(
            builder: (_) => ChatOverviewPage(
              null,
              receivedAction,
            ));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      onGenerateInitialRoutes: onGenerateInitialRoutes,
      onGenerateRoute: onGenerateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
// This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return  MaterialApp(
//       title: 'Simple Call App',
//       debugShowCheckedModeBanner: false,
//       themeMode: ThemeMode.light,
//       theme: MyTheme.lightTheme,
//       darkTheme: MyTheme.darkTheme,
//       home:  SplashScreen(),
//     );
//   }
// }
