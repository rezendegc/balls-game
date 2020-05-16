import 'dart:math';

import 'package:flame/components/component.dart';
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
  double distance = 0;
  double lastDistanceUsed = 0;
  double distanceToNewEnemy = 0;
  double lastLavaPosition = 0;
  Random rnd = Random();
  List<Component> manualComponents = List<Component>();
  double currentZoom = 1;
  double desiredZoom = 1;

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
    add(player = Player(this, Offset(0,-2)));
    manualComponents.addAll([
      Health(this),
      ScoreDisplay(this),
    ]);
  }

  @override
  void render(Canvas c) {
    if (size == null || player == null) {
      return;
    }

    c.save();
    c.translate(size.width / 2, size.height / 2);
    c.scale(size.width / SCREEN_WIDTH);
    c.scale(1 / currentZoom);
    super.render(c);
    c.scale(currentZoom);
    manualComponents.forEach((element) => element.render(c));

    c.restore();
  }

  @override
  void update(double dt) {
    if (size == null || pause || player == null) return;

    double slowedDt = player?.drawLine == true ? dt / 4 : dt;

    world.stepDt(slowedDt, 100, 100);

    timeToLoseMultiplier -= slowedDt;
    if (timeToLoseMultiplier < 0) {
      multiplier = 1;
      timeToLoseMultiplier = 0;
    }

    _cameraFollowPlayer();

    _spawnEnemies();

    _zoomCamera(dt);

    distance = player.body.position.x;

    super.update(slowedDt);

    manualComponents.forEach((element) => element.update(slowedDt));
  }

  void _zoomCamera(double dt) {
    double speed = player.body.linearVelocity.x.abs() + player.body.linearVelocity.y.abs();
    speed = speed < MAX_SPEED ? speed : MAX_SPEED;
    final zoomAmount = 1 + (1.5 * speed / MAX_SPEED);
    desiredZoom = zoomAmount;

    if ((currentZoom - desiredZoom).abs() > .4) {
      if (currentZoom > desiredZoom) currentZoom -= dt / 1.5;
      else currentZoom += dt / 1.5;
    }
  }

  void _cameraFollowPlayer() {
    final double horizontalOffset = 6;
    final double verticalOffset = 4;

    if ((camera.x - player.body.position.x).abs() > horizontalOffset) {
      if (camera.x > player.body.position.x) camera.x = player.body.position.x + horizontalOffset;
      else camera.x = player.body.position.x - horizontalOffset;
    }
    if ((camera.y - player.body.position.y).abs() > verticalOffset) {
      if (camera.y > player.body.position.y) camera.y = player.body.position.y + verticalOffset;
      else camera.y = player.body.position.y - verticalOffset;
    }
  }

  void onPanStart(details) {
    if (!player.canJump) return;

    player.drawLine = true;
    player.pointPosition = tapPositionToLocalPosition(details.globalPosition);
  }
  void onPanUpdate(details) {
    if (!player.canJump) return;

    player.drawLine = true;
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
    return (position - Offset(size.width / 2, size.height / 2)) / (size.width / SCREEN_WIDTH / currentZoom) + Offset(camera.x - player.body.position.x, camera.y - player.body.position.y);
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

  void _spawnEnemies() {
    if (lastLavaPosition < (player.body.position.x).abs() + 16) {
      lastLavaPosition += 16;
      add(Lava(this, Offset(lastLavaPosition + 16, 1.5)));
      add(Lava(this, Offset(-lastLavaPosition - 16, 1.5)));
    }

    if (distanceToNewEnemy == 0) distanceToNewEnemy = (.1 + rnd.nextDouble()) * 2;

    if (lastDistanceUsed < (player.body.position.x).abs() + 32) { // spawn new enemy
      lastDistanceUsed += distanceToNewEnemy;
      distanceToNewEnemy = (.1 + rnd.nextDouble()) * 2;
      final yPos = (rnd.nextDouble() - rnd.nextDouble()).abs() * (1 + 96 - 3) + 3;
      final yPos2 = (rnd.nextDouble() - rnd.nextDouble()).abs() * (1 + 96 - 3) + 3;

      final ballType = rnd.nextInt(12);


      switch(ballType) {
        case 1:
          add(HealthBall(this, Offset(lastDistanceUsed, -yPos)));
          add(HealthBall(this, Offset(-lastDistanceUsed, -yPos2)));
          break;
        case 2:
          add(Coin(this, Offset(lastDistanceUsed, -yPos)));
          add(Coin(this, Offset(-lastDistanceUsed, -yPos2)));
          break;
        case 3:
          add(PurpleBall(this, Offset(lastDistanceUsed, -yPos)));
          add(PurpleBall(this, Offset(-lastDistanceUsed, -yPos2)));
          break;
        default:
          add(RedBall(this, Offset(lastDistanceUsed, -yPos)));
          add(RedBall(this, Offset(-lastDistanceUsed, -yPos2)));
          break;
      }
    }
  }
}