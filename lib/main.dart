import 'package:flame/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webgame/game.dart';
import 'package:webgame/screens/Lost.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());

  Util flameUtil = Util();
  flameUtil.fullScreen();
  flameUtil.setOrientation(DeviceOrientation.portraitDown);
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': _startGame,
        '/lost': (_) => LostScreen(),
      },
    );
  }

  Widget _startGame(BuildContext context) {
    final navigateCB = (String name) => Navigator.of(context).pushNamed(name);

    return MyGame(navigateCB).widget;
  }
}