
import 'package:call_app/presentation/pages/screens/login/login_page.dart';
import 'package:flutter/material.dart';

import '../../../common/resources/utils.dart';
import '../../../resources/image_definition.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();
    // Simulate an async operation, like fetching data, for 3 seconds
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _animationComplete = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
   // double screenWidth= ResponsiveUtils.mediaQueryData.size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _animationComplete ? 0.0 : 1.0,
          duration: const Duration(seconds: 1),
          child: AnimatedContainer(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            width: _animationComplete ? 0.0 : 100,
            height: _animationComplete ? 0.0 : 100,
            decoration: BoxDecoration(
              image: _animationComplete
                  ? null
                  : DecorationImage(
                image: AssetImage(ImageDefinition.SplashScreenImage()),
                fit: BoxFit.contain,
              ),
            ),
            onEnd: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Estate Management"),
      ),
      body: Center(
        child: Text("Welcome to Estate Management"),
      ),
    );
  }
}