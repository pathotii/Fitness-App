import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flame Game Example')),
        body: const MyWorld(),
      ),
    );
  }
}

class MyWorld extends StatefulWidget {
  const MyWorld({super.key});

  @override
  State<MyWorld> createState() => _MyWorldState();
}

class _MyWorldState extends State<MyWorld> {
  @override
  Widget build(BuildContext context) {
    // This returns the FlameGame widget to render inside the stateful widget.
    return GameWidget(
      game: FlameGame(world: FlameGameWorld()),
    );
  }
}

// The game logic stays almost the same, but integrated into the Game class structure.
class FlameGameWorld extends World with TapCallbacks {
  @override
  Future<void> onLoad() async {
    // Start with adding one square in the center
    add(Square(Vector2.zero()));
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    // On a tap anywhere else, a square will be added
    if (!event.handled) {
      final touchPoint = event.localPosition;
      add(Square(touchPoint));
    }
  }
}

class Square extends RectangleComponent with TapCallbacks {
  static const speed = 3; // Speed for square rotation
  static const squareSize = 128.0; // Size of the square
  static const indicatorSize = 6.0; // Size of the indicators inside the square

  // Paint colors for the square and the internal indicator
  static final Paint red = BasicPalette.red.paint();
  static final Paint blue = BasicPalette.blue.paint();

  Square(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(squareSize),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Blue inner square
    add(
      RectangleComponent(
        size: Vector2.all(indicatorSize),
        paint: blue,
      ),
    );
    // Red inner square at the center
    add(
      RectangleComponent(
        position: size / 2,
        size: Vector2.all(indicatorSize),
        anchor: Anchor.center,
        paint: red,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Rotation of the square
    angle += speed * dt;
    angle %= 2 * math.pi; // Keep angle between 0 and 2π
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Remove the square when it's tapped
    removeFromParent();
    event.handled = true;
  }
}
