import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flamejam2025/provider.dart';
import 'package:flutter/material.dart';
import 'package:flame_riverpod/flame_riverpod.dart';

math.Random random = math.Random();

enum Box { vertical, horizontal }

class SpaceShooterGame extends FlameGame with RiverpodGameMixin {
  @override
  Color backgroundColor() => const Color(0x00FFFFFF);
  SpaceShooterGame();
  late final Player player = Player();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(player);
  }

  @override
  void onBuild() {
    if (player.click >= 39) {
      player.startGame();
    }
    super.onBuild();
  }
}

class BoxGuess extends PositionComponent {
  final Box orientation;
  BoxGuess({required this.orientation})
    : super(size: Vector2(100, 100), anchor: Anchor.center);

  static final _paint =
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white;

  final random = math.Random();

  @override
  void onMount() {
    final minus = random.nextInt(10).toDouble() * 2;
    if (orientation == Box.vertical) {
      size = Vector2(100, 70 - minus);
    }

    if (orientation == Box.horizontal) {
      size = Vector2(80 - minus, 100);
    }

    angle = minus * 10;
    super.onMount();
  }

  @override
  void render(Canvas canvas) {
    random.nextInt(100);

    canvas.drawRect(size.toRect(), _paint);
  }
}

class GuessContainer extends PositionComponent
    with HasGameReference<SpaceShooterGame> {
  List<BoxGuess> box = [
    BoxGuess(orientation: Box.vertical),
    BoxGuess(orientation: Box.horizontal),
    BoxGuess(orientation: Box.horizontal),
  ];

  @override
  void onMount() {
    addAll(box);

    for (final (index, boxGuess) in box.indexed) {
      boxGuess.position = Vector2(game.size.x / 2, index * 150 + 200);
      add(boxGuess);
    }

    super.onMount();
  }
}

class Player extends PositionComponent
    with
        HasGameReference<SpaceShooterGame>,
        TapCallbacks,
        DragCallbacks,
        RiverpodComponentMixin {
  Player() : super(size: Vector2(100, 100), anchor: Anchor.center);

  int click = 0;
  bool playState = false;

  static final _paint =
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white;

  @override
  FutureOr<void> onLoad() {
    position = game.size - size;
  }

  bool _isDragged = false;
  var dragPosition = Vector2(0, 0);

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragged = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!playState) return;
    dragPosition += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!playState) {
      dragPosition = Vector2(0, 0);
      return;
    }
    if (dragPosition.x.abs() > dragPosition.y.abs()) {
      add(
        SequenceEffect([
          SizeEffect.by(
            Vector2(-150, 0),
            CurvedEffectController(0.1, Curves.easeOut),
          ),
          SizeEffect.by(
            Vector2(150, 0),
            CurvedEffectController(0.1, Curves.easeOut),
          ),
        ]),
      );
      FlameAudio.play('jump_02.wav');
      ref.read(counterProvider.notifier).increment();
    } else {
      add(
        SequenceEffect([
          SizeEffect.by(
            Vector2(0, -150),
            CurvedEffectController(0.1, Curves.easeOut),
          ),
          SizeEffect.by(
            Vector2(0, 150),
            CurvedEffectController(0.1, Curves.easeOut),
          ),
        ]),
      );
      FlameAudio.play('jump_01.wav');
      ref.read(counterProvider.notifier).increment();
    }
    dragPosition = Vector2(0, 0);

    _isDragged = false;
  }

  void startGame() {
    addAll([
      MoveEffect.to(
        Vector2(game.size.x / 2, game.size.y / 4 * 3),
        CurvedEffectController(0.5, Curves.easeOut),
      ),
      SizeEffect.to(
        Vector2(150, 150),
        CurvedEffectController(0.5, Curves.easeOut),
      ),
    ]);

    game.add(GuessContainer());

    playState = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    final value = ref.watch(counterProvider);
    click = value;
    if (value >= 40) {
      return;
    }
    ref.read(counterProvider.notifier).increment();
    final sound = (value / 10).floor();
    FlameAudio.play('shoot_0$sound.wav');
  }

  @override
  void render(Canvas canvas) {
    if (!playState) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(size.toRect(), Radius.circular(20)),
        _paint,
      );
      canvas.drawLine(
        size.toOffset() - Offset(size.x / 2, size.y / 4),
        size.toOffset() - Offset(size.x / 2, size.y - size.y / 4),
        _paint,
      );
      canvas.drawLine(
        size.toOffset() - Offset(size.x / 4, size.y / 2),
        size.toOffset() - Offset(size.x - size.x / 4, size.y / 2),
        _paint,
      );
    } else {
      canvas.drawRect(size.toRect(), _paint);
    }
  }

  void move(Vector2 delta) {
    position.add(delta);
  }
}
