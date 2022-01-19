import 'package:flutter/material.dart';

class BigAppBar extends StatelessWidget with PreferredSizeWidget {
  const BigAppBar({Key key, this.background, this.title, this.subtitle}) : super(key: key);
  final int background;
  final String title;
  final String subtitle;

  @override
  Size get preferredSize => Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        height: 150,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/topplate_${background + 1}.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      title: Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(
          children: [
            (subtitle != null)
                ? Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Gilroy',
                    ),
                  )
                : SizedBox(),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 22,
                fontWeight: FontWeight.w400,
                fontFamily: 'Gilroy',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
