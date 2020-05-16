import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:box2d_flame/box2d.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webgame/components/Coin.dart';
import 'package:webgame/components/Floor.dart';
import 'package:webgame/components/Health.dart';
import 'package:webgame/components/HealthBall.dart';
import 'package:webgame/components/Lava.dart';
import 'package:webgame/components/Player.dart';
import 'package:webgame/components/PurpleBall.dart';
import 'package:webgame/components/RedBall.dart';
import 'package:webgame/components/Score.dart';
import 'package:webgame/constants.dart';

class MyGame extends BaseGame with PanDetector {
  World world;
  bool pause = false;
  Player player;
  int score = 0;
  int multiplier = 1;
  int maxMultipler = 5;
  double timeToLoseMultiplier = 0;
  Function(String) navigate;

  MyGame(this.navigate) : super() {
    world = World.withPool(
      Vector2(0, 10),
      DefaultWorldPool(100, 10),
    );

    _initialize();
  }

  void _initialize() async {
    resize(await Flame.util.initialDimensions());

    add(Floor(this, Offset(0, 0)));
    add(Lava(this, Offset(0, 1.5)));
    add(player = Player(this, Offset(0,0)));
    add(Health(this));

    add(RedBall(this, Offset(-2, 2)));
    add(Coin(this, Offset(2, 2)));
    add(PurpleBall(this, Offset(6, 2)));
    add(HealthBall(this, Offset(-6, 2)));
    add(ScoreDisplay(this));
  }

  @override
  void render(Canvas c) {
    if (size == null) {
      return;
    }

    c.save();
    c.translate(size.width / 2, size.height / 2);
    c.scale(size.width / SCREEN_WIDTH);
    super.render(c);

    c.restore();
  }

  @override
  void update(double dt) {
    if (size == null || pause) return;

    double slowedDt = player?.drawLine == true ? dt / 4 : dt;

    world.stepDt(slowedDt, 100, 100);

    timeToLoseMultiplier -= slowedDt;
    if (timeToLoseMultiplier < 0) {
      multiplier = 1;
      timeToLoseMultiplier = 0;
    }

    _cameraFollowPlayer();
    
    super.update(slowedDt);
  }

  void _cameraFollowPlayer() {
    camera.x = player?.body?.position?.x ?? 0;
    camera.y = player?.body?.position?.y ?? 0;
  }

  void onPanStart(details) {
    if (!player.canJump) return;

    player.drawLine = true;
    player.pointPosition = tapPositionToLocalPosition(details.globalPosition);
  }
  void onPanUpdate(details) {
    if (!player.canJump) return;

    player.pointPosition = tapPositionToLocalPosition(details.globalPosition);
  }

  void onPanEnd(details) {
    if (!player.canJump) return;

    player.drawLine = false;
    player.applyDragForce();
  }

  void onPanCancel() {
    if (!player.canJump) return;
    if (!player.drawLine) return;

    player.drawLine = false;
    player.applyDragForce();
  }

  Offset tapPositionToLocalPosition(Offset position) {
    return (position - Offset(size.width / 2, size.height / 2)) / (size.width / SCREEN_WIDTH);
  }

  void loseGame() {
    pause = true;
    navigate('/lost');
  }

  void addScore(int amount) {
    score += amount * multiplier;
    timeToLoseMultiplier = 5;
    multiplier += 1;
    if (multiplier > maxMultipler) multiplier = maxMultipler;
  }
}