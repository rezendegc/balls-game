import 'dart:ui' as ui;

import 'package:box2d_flame/box2d.dart' hide Timer;
import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';
import 'package:webgame/game.dart';

const double SIZE = .5;

class PurpleBall extends Component {
  final MyGame game;
  Body body;

  Paint paint;
  Rect rect;

  bool _willDestroy = false;

  @override
  bool destroy() => _willDestroy;

  PurpleBall(this.game, Offset offset) {
    Vector2 position = Vector2(offset.dx, offset.dy);

    CircleShape shape = CircleShape();
    shape.p.setFrom(Vector2(0, 0));
    shape.radius = SIZE;

    paint = Paint();
    paint.color = Colors.pinkAccent;

    BodyDef bd = BodyDef();
    bd.linearVelocity = Vector2.zero();
    bd.position = position;
    bd.fixedRotation = true;
    bd.type = BodyType.STATIC;
    body = game.world.createBody(bd);
    body.userData = this;

    FixtureDef fd = FixtureDef();
    fd.density = 1;
    fd.restitution = 0;
    fd.friction = 0;
    fd.shape = shape;
    fd.isSensor = true;
    Fixture ff = body.createFixtureFromFixtureDef(fd);
    ff.userData = 'purpleBall';
  }

  void render(Canvas c) {
    c.save();
    c.translate(body.position.x, body.position.y);
    c.drawCircle(Offset.zero, SIZE, paint);
    c.restore();
  }

  void update(double dt) {}

  void markToDestroy() => _willDestroy = true;

  @override
  void onDestroy() {
    game.world.destroyBody(body);
  }
}