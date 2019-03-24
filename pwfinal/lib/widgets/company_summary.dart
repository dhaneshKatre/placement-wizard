import 'package:flutter/material.dart';
import 'package:pwfinal/widgets/separator.dart';

final baseTextStyle = const TextStyle(fontFamily: 'Poppins');
final headerTextStyle = baseTextStyle.copyWith(
    color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold);
final regularTextStyle = baseTextStyle.copyWith(
    color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w400);
final subHeaderTextStyle = regularTextStyle.copyWith(fontSize: 12.0);

class CompanySummary extends StatelessWidget {
  final String ctc, field, name;
  CompanySummary({@required this.name, this.ctc, this.field});

  @override
  Widget build(BuildContext context) {
    Widget _planetValue(String value, IconData icon) {
      return Container(
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Icon(icon, size: 20.0, color: Theme.of(context).accentColor),
          Container(width: 8.0),
          Text(
            value,
            style: regularTextStyle,
          ),
        ]),
      );
    }

    final companyCardContent = Container(
      margin: EdgeInsets.fromLTRB(16.0, 22.0, 16.0, 0.0),
      constraints: BoxConstraints.expand(width: 300.0, height: 300.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: this.ctc != null
            ? <Widget>[
                Container(height: 4.0),
                Text(this.name, style: headerTextStyle),
                Container(height: 10.0),
                Separator(),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _planetValue(this.field, Icons.work),
                    _planetValue('${this.ctc} LPA', Icons.attach_money),
                  ],
                )
              ]
            : <Widget>[
                Container(height: 4.0),
                Text(this.name, style: headerTextStyle),
                Container(height: 10.0),
                Separator(),
              ],
      ),
    );

    return Container(
      margin: EdgeInsets.symmetric(
          vertical: this.ctc != null ? 16.0 : 40.0, horizontal: 24.0),
      child: Container(
        child: companyCardContent,
        height: this.ctc != null ? 154.0 : 100.0,
        margin: EdgeInsets.only(top: 120.0),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Color(0xFF333366)
              : Colors.deepPurple[300],
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
      ),
    );
  }
}
