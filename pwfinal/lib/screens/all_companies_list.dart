import 'package:async_loader/async_loader.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pwfinal/screens/company_detail.dart';
import 'package:pwfinal/widgets/shimmer_card.dart';

final GlobalKey<AsyncLoaderState> allCompaniesAsyncLoaderState = GlobalKey();

class AllCompanies extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<DataSnapshot> _getAllCompanies() async {
      return FirebaseDatabase.instance
          .reference()
          .child("Companies")
          .once()
          .timeout(Duration(seconds: 30));
    }

    Widget _errorWidget() {
      return Card(
        elevation: 2,
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red,
            child: Icon(
              Icons.signal_wifi_off,
              color: Colors.white,
            ),
          ),
          title: Text('No Internet!'),
          subtitle: Text('Please check your connectivity!'),
          onTap: () => allCompaniesAsyncLoaderState.currentState.reloadState(),
        ),
      );
    }

    AsyncLoader getList() {
      return AsyncLoader(
        initState: () async => await _getAllCompanies(),
        renderError: ([error]) => _errorWidget(),
        renderLoad: () {
          List<Widget> shimmers = List();
          for (int i = 0; i < 7; i++) shimmers.add(ShimmerCard());
          return Column(
            children: shimmers,
          );
        },
        renderSuccess: ({data}) {
          Map<dynamic, dynamic> companies = data.value;
          return ListView.builder(
            itemCount: companies.keys.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.check),
                  ),
                  title: Text(companies.keys.toList().elementAt(index)),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CompanyDetailScreen(
                              name: companies.keys.toList().elementAt(index),
                            )));
                  },
                ),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("All Companies")),
      body: Container(
        child: getList(),
      ),
    );
  }
}
