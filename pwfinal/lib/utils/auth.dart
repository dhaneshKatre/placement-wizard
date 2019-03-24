import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<GoogleSignInAccount> getSignedInAccount(
    GoogleSignIn googleSignIn) async {
  GoogleSignInAccount account = googleSignIn.currentUser;
  if (account == null) account = await googleSignIn.signInSilently();
  return account;
}

Future<FirebaseUser> signInToFirebase(GoogleSignInAccount account) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignInAuthentication googleAuth;
  if(account == null)
    return null;
  else googleAuth = await account.authentication;
  AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken
  );
  return await _auth.signInWithCredential(credential);
}

Future<Null> signOutFromFirebase(GoogleSignIn signin) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  return await _auth.signOut().whenComplete(() => signin.signOut());
}

showIt(BuildContext context) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.symmetric(vertical: 20.0),
            width: 300.0,
            height: 220.0,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.done_all,
                      size: 40.0,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Form Submitted Successfully!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                  FlatButton(
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      'DONE',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
