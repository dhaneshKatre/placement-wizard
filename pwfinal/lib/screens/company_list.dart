import 'dart:async';
import 'package:async_loader/async_loader.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pwfinal/screens/company_detail.dart';
import 'package:pwfinal/widgets/shimmer_card.dart';

class CompaniesListScreen extends StatelessWidget {
  final List<String> eligibleFields;
  CompaniesListScreen(this.eligibleFields);

  Future<DataSnapshot> fetchCompanies() async {
    DataSnapshot ds = await FirebaseDatabase.instance
        .reference()
        .child("Field_names")
        .once()
        .timeout(Duration(seconds: 30));
    debugPrint(ds.value.runtimeType.toString());
    debugPrint(ds.value.toString());
    return ds;
  }

  Widget _getPageShimmer() {
    return Container(
      child: ListView(
        children: <Widget>[
          ShimmerCard(),
          ShimmerCard(),
          ShimmerCard(),
          ShimmerCard(),
        ],
      ),
    );
  }

  AsyncLoader getList() {
    return AsyncLoader(
      initState: () async => await fetchCompanies(),
      renderLoad: () => _getPageShimmer(),
      renderError: ([error]) => Text(error.toString()),
      renderSuccess: ({data}) {
        Map<String, List> companies = Map();
        for (String i in this.eligibleFields) {
          if (i.endsWith("Marketing")) {
            if (data.value.containsKey("Marketing")) {
              data.value["Marketing"].forEach((k, v) => companies.putIfAbsent(
                  k, () => List()..add(v.toDouble())..add("Marketing")));
            }
          } else {
            String fieldName = i.substring(0, i.indexOf("_"));
            String fieldType = i.substring(i.indexOf("_") + 1);
            if (data.value.containsKey(fieldName)) {
              if (data.value[fieldName].containsKey(fieldType))
                data.value[fieldName][fieldType].forEach((k, v) =>
                    companies.putIfAbsent(
                        k, () => List()..add(v.toDouble())..add(fieldName)));
            }
          }
        }
        return Container(
          child: ListView.builder(
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
                              ctc: companies[
                                      companies.keys.toList().elementAt(index)]
                                  .elementAt(0)
                                  .toString(),
                              field: companies[
                                      companies.keys.toList().elementAt(index)]
                                  .elementAt(1)
                                  .toString(),
                            )));
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Eligible Companies")),
      body: Container(
        child: getList(),
      ),
    );
  }
}
