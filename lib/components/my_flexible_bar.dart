import 'package:flutter/material.dart';

class MyFlexiableAppBar extends StatelessWidget {
  final double appBarHeight = 66.0;
  const MyFlexiableAppBar();

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      height: statusBarHeight + appBarHeight,
      child: Center(
        child: Text('height'),
      ),
    );
  }
}
