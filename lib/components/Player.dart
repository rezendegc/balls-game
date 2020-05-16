import 'dart:math';
import 'dart:ui' as ui;

import 'package:box2d_flame/box2d.dart' hide Timer;
import 'package:flame/components/component.dart';
import 'package:flame/particles/computed_particle.dart';
import 'package:flame/particles/moving_particle.dart';
import 'package:flutter/material.dart';
import 'package:webgame/components/Coin.dart';
import 'package:webgame/components/HealthBall.dart';
import 'package:webgame/components/PurpleBall.dart';
import 'package:webgame/components/RedBall.dart';
import 'package:webgame/game.dart';

const double SIZE = .5;

class Player extends Component with ContactListener {
  final MyGame game;
  Body body;
  double currentHealth = 100;
  double maxHealth = 100;

  Paint paint;
  Rect rect;

  Paint linePaint;

  Random rnd = Random();

  bool drawLine = false;
  Offset pointPosition = Offset.zero;
  bool canJump = true;

  int priority() => 10;

  Player(this.game, Offset offset) {
    Vector2 position = Vector2(offset.dx, offset.dy);

    CircleShape shape = CircleShape();
    shape.p.setFrom(Vector2(0, 0));
    shape.radius = SIZE;

    paint = Paint();
    paint.color = Colors.blue;

    linePaint = Paint();
    linePaint.strokeWidth = .2;
    linePaint.strokeCap = StrokeCap.round;

    BodyDef bd = BodyDef();
    bd.linearVelocity = Vector2.zero();
    bd.position = position;
    bd.fixedRotation = true;
    bd.bullet = true;
    bd.type = BodyType.DYNAMIC;
    body = game.world.createBody(bd);
    body.userData = this;

    FixtureDef fd = FixtureDef();
    fd.density = .65;
    fd.restitution = .1;
    fd.friction = 0;
    fd.shape = shape;
    Fixture ff = body.createFixtureFromFixtureDef(fd);
    ff.userData = 'player';

    game.world.setContactListener(this);
  }

  void render(Canvas c) {

    c.save();
    c.translate(body.position.x, body.position.y);
    if (drawLine) {
      linePaint.shader = ui.Gradient.linear(Offset(0,0), pointPosition, [Colors.white, Colors.white10]);
      c.drawLine(Offset.zero, pointPosition, linePaint);
    }

    c.drawCircle(Offset.zero, SIZE, paint);
    c.restore();
  }

  void update(double dt) {
    // if (!drawLine) {
    //   currentHealth -= dt * 3;
    // } else {
    //   currentHealth -= dt * 50;
    // }
    if (currentHealth < 0) { // loses
      currentHealth = 0;
      game.loseGame();
    }

    if (body.linearVelocity.x.abs() > 0 || body.linearVelocity.y.abs() > 0) {
      _spawnParticlesTrail();
    }
  }

  void applyDragForce() {
    final force = Vector2(pointPosition.dx, pointPosition.dy);
    body.linearVelocity *= 0.3; // deaccelerate body before apply force
    body.applyLinearImpulse(force, Vector2(body.position.x, body.position.y), true);

    pointPosition = Offset.zero;
    canJump = false;

    _spawnDragForceParticles();
  }

  void applyContactForce() {
    double deacelleration = rnd.nextDouble() + .3;
    deacelleration = deacelleration > .7 ? .7 : deacelleration;

    final force = Vector2(0, -8 + .15 * body.linearVelocity.y);
    body.linearVelocity.y = 0; // deaccelerate body before apply force
    body.linearVelocity.x *= deacelleration; // deaccelerate body before apply force
    body.applyLinearImpulse(force, Vector2(body.position.x, body.position.y), true);
  }

  void applyRandomForce() {
    final xForce = rnd.nextInt(7) + 3.0;
    final yForce = rnd.nextInt(7) + 3.0;
    final invertXforce = rnd.nextBool();
    final invertYforce = rnd.nextBool();

    final force = Vector2(invertXforce ? -xForce : xForce, invertYforce ? -yForce : yForce);
    body.linearVelocity = Vector2.zero(); // stops body before apply force
    body.applyLinearImpulse(force, Vector2(body.position.x, body.position.y), true);
  }

  void resetJump() {
    canJump = true;
  }

  void healHealth(double amount) {
    currentHealth += amount;
    if (currentHealth > maxHealth) currentHealth = maxHealth;
  }

  void _spawnParticlesTrail() {
    final position = Offset(body.position.x, body.position.y);

    final computedParticle = ComputedParticle(
      lifespan: 1.0,
      renderer: (canvas, particle) {
        final progress = particle.progress > 1 ? 0 : (1 - particle.progress);
        return canvas.drawRect(
          Rect.fromCenter(center: position, width: .2 * progress, height: .2 * progress),
          Paint()..color = Colors.white,
        );
      }
    );

    game.add(computedParticle.asComponent());
  }

  void _spawnHitGroundParticles() {
    final position = Offset(body.position.x, body.position.y);

    final computedParticle = ComputedParticle(
      renderer: (canvas, particle) {
        return canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: .2, height: .2),
          Paint()..color = Colors.white.withOpacity((1 - particle.progress).abs()),
        );
      }
    );

    final particles = [
      MovingParticle(
        from: position,
        to: position + Offset((.5 + rnd.nextDouble() * 5),(.5 + rnd.nextDouble() * 5)),
        lifespan: 3.0,
        curve: Curves.decelerate,
        child: computedParticle
      ),
      MovingParticle(
        from: position,
        to: position + Offset((.5 + rnd.nextDouble() * 5),(.5 + rnd.nextDouble() * 5)),
        lifespan: 3.0,
        curve: Curves.decelerate,
        child: computedParticle
      ),
      MovingParticle(
        from: position,
        to: position + Offset(-(.5 + rnd.nextDouble() * 5),-(.5 + rnd.nextDouble() * 5)),
        lifespan: 3.0,
        curve: Curves.decelerate,
        child: computedParticle
      ),
      MovingParticle(
        from: position,
        to: position + Offset(-(.5 + rnd.nextDouble() * 5),-(.5 + rnd.nextDouble() * 5)),
        lifespan: 3.0,
        curve: Curves.decelerate,
        child: computedParticle
      ),
      MovingParticle(
        from: position,
        to: position + Offset(-(.5 + rnd.nextDouble() * 5),(.5 + rnd.nextDouble() * 5)),
        lifespan: 3.0,
        curve: Curves.decelerate,
        child: computedParticle
      ),
      MovingParticle(
        from: position,
        to: position + Offset(-(.5 + rnd.nextDouble() * 5),(.5 + rnd.nextDouble() * 5)),
        lifespan: 3.0,
        curve: Curves.decelerate,
        child: computedParticle
      ),
      MovingParticle(
        from: position,
        to: position + Offset((.5 + rnd.nextDouble() * 5),-(.5 + rnd.nextDouble() * 5)),
        lifespan: 3.0,
        curve: Curves.decelerate,
        child: computedParticle
      ),
      MovingParticle(
        from: position,
        to: position + Offset((.5 + rnd.nextDouble() * 3),-(.5 + rnd.nextDouble() * 3)),
        lifespan: 3.0,
        curve: Curves.decelerate,
        child: computedParticle
      ),
    ];

    particles.forEach((particle) => game.add(particle.asComponent()));
  }

  void _spawnDragForceParticles() {
    final position = Offset(body.position.x, body.position.y);

    final computedParticle = ComputedParticle(
      renderer: (canvas, particle) {
        return canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: .3, height: .3),
          Paint()..color = Colors.white.withOpacity((1 - particle.progress).abs()),
        );
      }
    );

    final particles = [
      MovingParticle(
        from: position,
        to: position + Offset((.5 + rnd.nextDouble() * 7),(.5 + rnd.nextDouble() * 7)),
        lifespan: 4.0,
        curve: Curves.decelerate,
        child: computedParticle
      ),
      MovingParticle(
        from: position,
        to: position + Offset(-(.5 + rnd.nextDouble() * 7),-(.5 + rnd.nextDouble() * 7)),
        lifespan: 4.0,
        curve: Curves.decelerate,
        child: computedParticle
      ),
      MovingParticle(
        from: position,
        to: position + Offset(-(.5 + rnd.nextDouble() * 7),(.5 + rnd.nextDouble() * 7)),
        lifespan: 4.0,
        curve: Curves.decelerate,
        child: computedParticle
      ),
      MovingParticle(
        from: position,
        to: position + Offset((.5 + rnd.nextDouble() * 7),-(.5 + rnd.nextDouble() * 7)),
        lifespan: 4.0,
        curve: Curves.decelerate,
        child: computedParticle
      ),
    ];

    particles.forEach((particle) => game.add(particle.asComponent()));
  }

  void _solveContact(Contact contact) {
    Fixture fixture = contact.fixtureB.userData == 'player'
        ? contact.fixtureA
        : contact.fixtureB;

    if (fixture.userData == 'floor') {
      resetJump();
      _spawnHitGroundParticles();
    } else if (fixture.userData == 'lava') {
      currentHealth = 0;
      game.loseGame();
    } else if (fixture.userData == 'redBall') {
      final ballBody = fixture.getBody().userData as RedBall;
      ballBody.markToDestroy();
      resetJump();
      healHealth(10);
      applyContactForce();
      game.addScore(200);
    } else if (fixture.userData == 'coin') {
      final coinBody = fixture.getBody().userData as Coin;
      resetJump();
      coinBody.markToDestroy();
      applyContactForce();
      game.addScore(2000);
    } else if (fixture.userData == 'purpleBall') {
      final ballBody = fixture.getBody().userData as PurpleBall;
      resetJump();
      ballBody.markToDestroy();
      applyRandomForce();
      game.addScore(1000);
      healHealth(5);
    } else if (fixture.userData == 'healthBall') {
      final ballBody = fixture.getBody().userData as HealthBall;
      healHealth(30);
      resetJump();
      ballBody.markToDestroy();
      applyContactForce();
      game.addScore(400);
    }
  }

  void beginContact(contact) {
    _solveContact(contact);
  }
  void endContact(contact) {}
  void postSolve(contact, impulse) {}
  void preSolve(contact, oldManifold) {}
}