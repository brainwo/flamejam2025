import 'dart:math' as math;

import 'package:flame_audio/flame_audio.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flamejam2025/game.dart';
import 'package:flamejam2025/provider.dart';
import 'package:flamejam2025/widget/fitted.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  runApp(ProviderScope(child: FittedWidget(child: const MyApp())));
}

final gameInstance = SpaceShooterGame();
final GlobalKey<RiverpodAwareGameWidgetState> gameWidgetKey =
    GlobalKey<RiverpodAwareGameWidgetState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.material(
      title: 'Enhanced 3/82^6',
      themeMode: ThemeMode.dark,
      materialThemeBuilder: (context, theme) {
        return ThemeData(
          brightness: Brightness.dark,
          fontFamily: "SpaceGrotesk",
        );
      },
      darkTheme: ShadThemeData(
        textTheme: ShadTextTheme(family: "SpaceGrotesk"),
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool played = false;
  Future<void> startBgmMusic() async {
    await FlameAudio.bgm.initialize();
    Future.delayed(const Duration(seconds: 3), () async {
      await FlameAudio.bgm.play('bgm01.ogg');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Consumer(
              builder: (context, ref, widget) {
                int counterValue = ref.watch(counterProvider);
                final pushedMesage = const Text(
                  'You have pushed the button this many times:',
                );
                if (counterValue >= 40) {
                  if (!played) {
                    FlameAudio.play('boink.mp3');
                    startBgmMusic();
                    played = true;
                  }
                  return Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Text("counter_"),
                          Text(
                            "$counterValue",
                            style: TextStyle(fontSize: 40),
                          ), //
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    switch (counterValue) {
                      < 29 =>
                        pushedMesage
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .shimmer(),
                      < 35 => pushedMesage.animate().fadeOut(),
                      _ => SizedBox(),
                    },
                    Text(
                          "$counterValue",
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.copyWith(
                            fontSize:
                                counterValue < 20
                                    ? 30
                                    : math.pow(counterValue - 19, 2) + 30,
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shakeY(hz: counterValue.toDouble()),
                  ],
                );
              },
            ),
            RiverpodAwareGameWidget(key: gameWidgetKey, game: gameInstance),
          ],
        ),
      ),
    );
  }
}
