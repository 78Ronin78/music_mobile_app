import 'package:flutter/material.dart';

class IconTransperentButton extends StatelessWidget {
  final String title;
  final Function onPressed;
  final double fontSize;
  final String imageAssets;

  const IconTransperentButton({
    Key key,
    this.title,
    this.onPressed,
    this.fontSize,
    this.imageAssets
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(55.0),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: FlatButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imageAssets, width: 35),
            SizedBox(width: 18,),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText2
            ),
          ],
        ),
      ),
    );
  }
}
