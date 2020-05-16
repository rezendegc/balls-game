import 'dart:math';
import 'dart:ui';
import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:webgame/game.dart';

class ScoreDisplay extends Component {
  final MyGame game;
  TextPainter painter;
  TextStyle textStyle;
  TextStyle multiplerStyle;
  TextPainter multiplierPainter;
  Offset position;
  Offset multiplierPosition;

  ScoreDisplay(this.game) {
    painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    multiplierPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textStyle = TextStyle(
      color: Colors.white,
      fontSize: 1,
      shadows: <Shadow>[
        Shadow(
          blurRadius: 7,
          color: Color(0xff000000),
          offset: Offset(0.05, 0.05),
        ),
      ],
    );

    multiplerStyle = TextStyle(
      color: Colors.green,
      fontSize: .75,
      fontWeight: FontWeight.bold,
      shadows: <Shadow>[
        Shadow(
          blurRadius: 7,
          color: Color(0xff000000),
          offset: Offset(0.05, 0.05),
        ),
      ],
    );

    position = Offset.zero;
    multiplierPosition = Offset.zero;
  }

  bool isHud() => true;

  void render(Canvas canvas) {
    canvas.save();

    // canvas.rotate(-pi / 2);

    if (painter.text?.toPlainText() != null)
      painter.paint(canvas, position);

    canvas.translate(-position.dx, position.dy);
    canvas.rotate(pi / 4);

    if (multiplierPainter.text?.toPlainText() != null && game.multiplier > 1)
      multiplierPainter.paint(canvas, multiplierPosition);

    canvas.restore();
  }

  void update(double t) {
    if ((painter.text?.toPlainText()) != game.score.toString()) {
      painter.text = TextSpan(
        text: "Score: ${game.score.toString()}",
        style: textStyle,
      );

      painter.layout();

      position = Offset(
        -painter.width / 2,
        - (15 * game.size.height / game.size.width),
      );
    }

    if ((multiplierPainter.text?.toPlainText()) != game.multiplier.toString()) {
      multiplierPainter.text = TextSpan(
        text: "${game.multiplier.toString()}x",
        style: multiplerStyle,
      );

      multiplierPainter.layout();

      multiplierPosition = Offset(
        -multiplierPainter.width / 2,
        -painter.height / 2,
      );
    }
  }
}
