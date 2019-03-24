import 'package:flutter/material.dart';
import 'package:pwfinal/widgets/google_sign_in_button.dart';
import 'package:pwfinal/state_widget.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
//  BoxDecoration _buildBackground() {
//    return BoxDecoration(
//      image: DecorationImage(
//        image: AssetImage(""),
//        fit: BoxFit.cover,
//      ),
//    );
//  }

  Text _buildText() {
    return Text(
      'Placement Wizard',
      style: Theme.of(context).textTheme.headline,
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
//        decoration: _buildBackground(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildText(),
              SizedBox(height: 50.0),
              GoogleSignInButton(
                onPressed: () => StateWidget.of(context).signInWithGoogle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
