import 'package:flutter/material.dart';

class TransparentButton extends StatelessWidget {
  final String title;
  final Function onPressed;
  final double fontSize;

  const TransparentButton({
    Key key,
    this.title,
    this.onPressed,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: Colors.white),
      ),
      child: FlatButton(
        onPressed: onPressed,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ),
    );
  }
}
