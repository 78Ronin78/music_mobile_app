import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget with PreferredSizeWidget {
  const MainAppBar({Key key, this.transperency = false}) : super(key: key);
  final bool transperency;

  @override
  Size get preferredSize => Size.fromHeight(40);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: (transperency) ? Colors.transparent : Color(0xFF1D1D1D),
      automaticallyImplyLeading: false,

      title: Container(
        width: 100,
        child: GestureDetector(
          onTap: () {},
          //=> Navigator.of(context).pushNamed('/spoty'),
          child: Text(
            'LOGO',
            style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 22, fontWeight: FontWeight.w400, fontFamily: 'Gilroy'),
          ),
        ),
      ),
      // child: child,
    );
  }
}
