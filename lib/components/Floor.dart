import 'dart:ui';

import 'package:box2d_flame/box2d.dart' hide Timer;
import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';
import 'package:webgame/game.dart';

class Floor extends Component {
  final MyGame game;
  Body body;

  bool first;

  Paint paint;
  Rect rect;

  Floor(this.game, Offset offset) {
    Vector2 position = Vector2(offset.dx, offset.dy);

    PolygonShape shape = PolygonShape();
    shape.setAsBoxXY(16, 1.5);
    
    rect = Rect.fromPoints(Offset(shape.vertices[0].x, shape.vertices[0].y), Offset(shape.vertices[2].x, shape.vertices[2].y));

    paint = Paint();
    paint.color = Colors.white;

    BodyDef bd = BodyDef();
    bd.linearVelocity = Vector2.zero();
    bd.position = position;
    bd.fixedRotation = true;
    bd.type = BodyType.STATIC;
    body = game.world.createBody(bd);
    body.userData = this;

    FixtureDef fd = FixtureDef();
    fd.density = 0;
    fd.restitution = 0;
    fd.friction = 0;
    fd.shape = shape;
    Fixture ff = body.createFixtureFromFixtureDef(fd);
    ff.userData = 'floor';
  }

  void render(Canvas c) {
    c.save();
    c.translate(body.position.x, body.position.y);
    c.drawRect(rect, paint);
    c.restore();
  }

  void update(double dt) {
  }
}