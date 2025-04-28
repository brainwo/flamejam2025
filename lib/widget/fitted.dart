import 'package:flutter/material.dart';

class FittedWidget extends StatelessWidget {
  const FittedWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: const MediaQueryData(
        size: Size(720, 1280),
        platformBrightness: Brightness.dark,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = MediaQuery.of(context).size;

          return ColoredBox(
            color: Colors.black,
            child: Center(
              child: FittedBox(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: size.width,
                    maxHeight: size.height,
                  ),
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
