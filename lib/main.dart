import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:music_mobile_app/routes.dart';
import 'package:music_mobile_app/screen/preloader.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RouteGenerator.generateRoute,
      title: 'Liveinthree',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],
        accentColor: Colors.cyan[600],
        fontFamily: 'Georgia',
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 72.0,
            fontFamily: 'HelveticaNeue',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          bodyText2:
              TextStyle(fontSize: 20.0, fontFamily: 'HelveticaNeue', color: Colors.white, fontWeight: FontWeight.w400),
          bodyText1: TextStyle(
              fontSize: 22.0, fontFamily: 'HelveticaNeue', color: Color(0xFF1B1B1B), fontWeight: FontWeight.w800),
          subtitle1: TextStyle(
              fontSize: 14.0, fontFamily: 'HelveticaNeue', color: Color(0xFF1B1B1B), fontWeight: FontWeight.w400),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  MyHomePage({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool preload = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void initState() {
    super.initState();

    configureFirebase();

    _firebaseMessaging.getToken().then((String token) {
      try {
        assert(token != null);
        log(token);
      } catch (e) {
        print('token error');
      }
    });
    _getLocationPermission();
  }

  void _getLocationPermission() async {
    var location = new Location();
    try {
      await location.requestPermission();
    } on Exception catch (_) {}
  }

  void configureFirebase() {
    try {
      _firebaseMessaging.configure(
        onMessage: notificationOnMessage,
        onLaunch: notificationOnLaunch,
        onResume: notificationOnResume,
      );
    } catch (e) {}
  }

  Future notificationOnResume(Map<String, dynamic> message) async {}

  Future notificationOnLaunch(Map<String, dynamic> message) async {}

  Future notificationOnMessage(Map<String, dynamic> message) async {}

  @override
  Widget build(BuildContext context) {
    return Preloader();
  }
}
