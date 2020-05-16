import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webgame/game.dart';

const HEALTH_HEIGHT = 1.0;
const HEALTH_WIDTH = 8.0;

class Health extends Component {
  Rect currentHealthRect;
  Offset textPosition;
  MyGame game;

  Rect maxHealthRect;

  bool first = true;

  Health(this.game) {
    maxHealthRect = Rect.fromLTWH(
      -HEALTH_WIDTH / 2,
      -HEALTH_HEIGHT / 2 - (12 * game.size.height / game.size.width),
      HEALTH_WIDTH,
      HEALTH_HEIGHT,
    );
    currentHealthRect = Rect.fromLTWH(
      -HEALTH_WIDTH / 2,
      -HEALTH_HEIGHT / 2 - (12 * game.size.height / game.size.width),
      HEALTH_WIDTH,
      HEALTH_HEIGHT,
    );
  }

  void update(dt) {
    final healthPercentage = game.player.currentHealth / game.player.maxHealth;

    currentHealthRect = Rect.fromLTWH(
      -HEALTH_WIDTH / 2,
      -HEALTH_HEIGHT / 2 - (12 * game.size.height / game.size.width),
      HEALTH_WIDTH * healthPercentage,
      HEALTH_HEIGHT,
    );
  }

  void render(canvas) {
    canvas.save();
    canvas.drawRect(maxHealthRect, Paint()..color = Colors.red);
    canvas.drawRect(currentHealthRect, Paint()..color = Colors.green);
    canvas.restore();
  }

  bool isHud() => true;
}
