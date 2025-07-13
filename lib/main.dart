import 'package:flutter/material.dart';
import 'package:tetriz/views/game_screen.dart';

void main() {
  runApp(TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tetris Game',
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}
