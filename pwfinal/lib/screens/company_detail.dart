import 'package:async_loader/async_loader.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pwfinal/widgets/company_summary.dart';
import 'package:pwfinal/widgets/separator.dart';

class CompanyDetailScreen extends StatelessWidget {
  final String name, ctc, field;
  CompanyDetailScreen({this.name, this.ctc, this.field});
  @override
  Widget build(BuildContext context) {
    Future<DataSnapshot> _getCompanyInfo() async {
      return await FirebaseDatabase.instance
          .reference()
          .child("Companies")
          .child(name)
          .once();
    }

    _getBackground(String imageURL) => Container(
          child: Image.network(imageURL, fit: BoxFit.cover, height: 300.0),
          constraints: BoxConstraints.expand(height: 300.0),
        );

    _getGradient() => Container(
          margin: EdgeInsets.only(top: 190.0),
          height: 110.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0x00736AB7),
                Theme.of(context).primaryColor,
              ],
              stops: [0.0, 0.9],
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
            ),
          ),
        );

    _getContent(String description) => ListView(
          padding: EdgeInsets.fromLTRB(0.0, 72.0, 0.0, 32.0),
          children: <Widget>[
            CompanySummary(name: this.name, ctc: this.ctc, field: this.field),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "OVERVIEW",
                  ),
                  Separator(color: Theme.of(context).accentColor),
                  Text(description,
                      style: regularTextStyle.copyWith(
                          color: Theme.of(context).accentColor)),
                ],
              ),
            ),
          ],
        );

    _getToolbar(BuildContext context) => Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: BackButton(
            color: Colors.white,
          ),
        );

    return AsyncLoader(
      initState: () async => await _getCompanyInfo(),
      renderLoad: () => Center(child: CircularProgressIndicator()),
      renderError: ([error]) => Text(error.toString()),
      renderSuccess: ({data}) {
        return Scaffold(
          body: Container(
            constraints: BoxConstraints.expand(),
            color: Theme.of(context).primaryColor,
            child: Stack(
              children: <Widget>[
                _getBackground(data.value["url"]),
                _getGradient(),
                _getContent(data.value["desc"]),
                _getToolbar(context),
              ],
            ),
          ),
        );
      },
    );
  }
}
