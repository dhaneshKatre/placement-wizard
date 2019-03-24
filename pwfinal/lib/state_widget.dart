import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pwfinal/model/data.dart';

import 'package:pwfinal/model/state.dart';
import 'package:pwfinal/utils/auth.dart';

class StateWidget extends StatefulWidget {
  final StateModel state;
  final Widget child;

  StateWidget({@required this.child, this.state});

  static _StateWidgetState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_StateDataWidget)
            as _StateDataWidget)
        .data;
  }

  @override
  _StateWidgetState createState() => _StateWidgetState();
}

class _StateWidgetState extends State<StateWidget> {
  StateModel state;
  FirebaseMessaging _messaging;
  GoogleSignInAccount googleAccount;
  final GoogleSignIn googleSignIn =
      new GoogleSignIn(scopes: ['email', 'profile']);

  @override
  void initState() {
    super.initState();
    _messaging = FirebaseMessaging();
    if (widget.state != null) {
      state = widget.state;
    } else {
      state = new StateModel(isLoading: true);
      initUser();
      _messaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          debugPrint('on msg $message');
        },
        onResume: (Map<String, dynamic> message) async {
          debugPrint('on resume $message');
        },
        onLaunch: (Map<String, dynamic> message) async {
          debugPrint('on launch $message');
        },
      );
    }
  }

  Future<Null> initUser() async {
    googleAccount = await getSignedInAccount(googleSignIn);
    DataSnapshot listSnapshot = await FirebaseDatabase.instance
        .reference()
        .child('Fields')
        .once()
        .timeout(Duration(seconds: 10));
    List<dynamic> temp = listSnapshot.value;
    List<String> fields = temp.map((f) => f.toString()).toList();
    if (googleAccount == null) {
      setState(() {
        state.isLoading = false;
      });
    } else {
      await signInWithGoogle();
    }
    setState(() {
      state.fields = fields;
    });
  }


  Future<Null> signInWithGoogle() async {
    if (googleAccount == null) {
      googleAccount = await googleSignIn.signIn();
    }
    FirebaseUser firebaseUser = await signInToFirebase(googleAccount);
    if (firebaseUser != null)
      setState(() {
        state.isLoading = false;
        state.user = firebaseUser;
//        _messaging.getToken().then((token) => FirebaseDatabase.instance
//            .reference()
//            .child("tokens")
//            .child(firebaseUser.uid)
//            .set(token));
        _messaging.subscribeToTopic("newCompany");
      });
  }

  void handleData(Data data) {
    setState(() {
      state.data = data;
    });
  }

  Future<Null> signOut() async {
    await signOutFromFirebase(googleSignIn);
    setState(() {
      googleAccount = null;
      state.isLoading = false;
      state.user = null;
      state.data = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _StateDataWidget(data: this, child: widget.child);
  }
}

class _StateDataWidget extends InheritedWidget {
  final _StateWidgetState data;

  _StateDataWidget({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);
  @override
  bool updateShouldNotify(_StateDataWidget old) => true;
}
