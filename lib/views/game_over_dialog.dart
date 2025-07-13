import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final int score;
  final VoidCallback onNewGame;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.onNewGame,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 242, 247, 255),
      title: Center(
        child: Text(
          'Score',
          style: const TextStyle(
            color: Color.fromARGB(255, 38, 43, 57),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      content: Text(
        '$score',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        TextButton(
          onPressed: onNewGame,
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 38, 43, 57),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: const Text(
              'NEW GAME',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color.fromARGB(255, 242, 247, 255)),
            ),
          ),
        ),
      ],
    );
  }
}
