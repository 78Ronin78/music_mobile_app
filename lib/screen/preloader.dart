import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_mobile_app/repo/user_repo.dart';

class Preloader extends StatefulWidget {
  Preloader({Key key}) : super(key: key);

  @override
  _PreloaderState createState() => _PreloaderState();
}

class _PreloaderState extends State<Preloader> {
  bool _visible = true;
  Timer _blink;
  bool firstOpen = true;

  @override
  void initState() {
    _blink = Timer.periodic(new Duration(seconds: 1), (timer) {
      setState(() {
        _visible = !_visible;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _blink.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (firstOpen) {
      userRepo.auth(context);
      firstOpen = false;
    }
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0xFF101010),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.5,
                duration: Duration(seconds: 1),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Image.asset('assets/images/preloader.png', fit: BoxFit.cover),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'LOGO',
                    style: TextStyle(
                      color: Color(0xFF3B6CEB),
                      fontSize: 22,
                      height: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Концерты в твоем городе',
                    style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 22,
                      height: 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
