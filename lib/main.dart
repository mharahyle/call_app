import 'dart:async';
import 'package:call_app/presentation/core/providers/app_provider.dart';
import 'package:call_app/presentation/pages/onboarding/splash_screen/splash.dart';
import 'package:call_app/presentation/resources/Theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
const appId = "548f443b3f7d4a5987b0b1bb7ba5a4d3";
const token =  "9242dc01e9524024b6e7482ba7e6528b";
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
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
 const  MyApp({Key? key}) : super(key: key);

  static void restartApp(BuildContext context) {
    try {
      context.findAncestorStateOfType<_MyAppState>()?.restartApp();
    } catch (_) {}
  }


  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Key _key = UniqueKey();
  void restartApp() {
    if (mounted) setState(() => _key = UniqueKey());
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Simple Call App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: MyTheme.lightTheme,
      darkTheme: MyTheme.darkTheme,
      home:  SplashScreen(),
    );
  }
}
