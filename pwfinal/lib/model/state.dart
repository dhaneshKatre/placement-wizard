import 'package:firebase_auth/firebase_auth.dart';
import 'package:pwfinal/model/data.dart';

class StateModel {
  bool isLoading;
  FirebaseUser user;
  Data data;
  List<String> fields;
  StateModel({this.isLoading = false, this.user, this.data, this.fields});
}
