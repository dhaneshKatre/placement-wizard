import 'package:flutter/material.dart';

class Separator extends StatelessWidget {
  final Color color;
  Separator({this.color});
  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: new EdgeInsets.symmetric(vertical: 8.0),
        height: 2.0,
        width: 18.0,
        color: this.color ?? Theme.of(context).accentColor);
  }
}
