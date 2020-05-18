import 'dart:math';

import 'package:box2d_flame/box2d.dart' hide Timer;
import 'package:flame/components/component.dart';
import 'package:flame/particle.dart';
import 'package:flame/particles/accelerated_particle.dart';
import 'package:flame/particles/computed_particle.dart';
import 'package:flutter/material.dart';
import 'package:webgame/game.dart';

const double SIZE = .4;

class Coin extends Component {
  final MyGame game;
  Body body;

  Paint paint;
  Rect rect;

  final rnd = Random();

  bool _willDestroy = false;

  @override
  bool destroy() => _willDestroy;

  Coin(this.game, Offset offset) {
    Vector2 position = Vector2(offset.dx, offset.dy);

    CircleShape shape = CircleShape();
    shape.p.setFrom(Vector2(0, 0));
    shape.radius = SIZE;

    paint = Paint();
    paint.color = Colors.yellowAccent;

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
    ff.userData = 'coin';
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
    _spawnDestroyedParticles();
  }

  void _spawnDestroyedParticles() {
    final position = Offset(body.position.x, body.position.y);

    final computedParticle = ComputedParticle(
      renderer: (canvas, particle) {
        return canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: .4, height: .4),
          Paint()..color = Colors.yellowAccent,
        );
      }
    );

    final particle1 = Particle.generate(
      count: 20,
      lifespan: 2,
      generator: (i) => AcceleratedParticle(
        position: position,
        speed: Offset(-rnd.nextDouble() * 1.5, -rnd.nextDouble()) * 30,
        acceleration: const Offset(40, 0),
        child: computedParticle,
      ),
    );
    final particle2 = Particle.generate(
      count: 20,
      lifespan: 2,
      generator: (i) => AcceleratedParticle(
        position: position,
        speed: Offset(-rnd.nextDouble() * 1.5, rnd.nextDouble()) * 30,
        acceleration: const Offset(40, 0),
        child: computedParticle,
      ),
    );
    game.add(particle1.asComponent());
    game.add(particle2.asComponent());
  }

}