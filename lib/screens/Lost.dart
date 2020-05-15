import 'package:flutter/material.dart';

class LostScreen extends StatelessWidget {
  const LostScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
          child: Text("Restart"),
        ),
      ),
    );
  }
}