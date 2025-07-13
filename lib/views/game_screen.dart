import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tetriz/constants/tetromino.dart';
import 'package:tetriz/views/controller_section.dart';
import 'package:tetriz/views/game_over_dialog.dart';
import 'package:tetriz/views/score_and_next_block_section.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int score = 0;
  bool isPaused = false;
  static const int boardWidth = 10;
  static const int boardHeight = 16;

  TetrominoType currentType = TetrominoType.J;
  TetrominoType nextType = TetrominoType.L;
  int rotationIndex = 0;
  int currentX = 4;
  int currentY = 0;

  late List<List<Color?>> gameBoard;
  final Random random = Random();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    gameBoard = List.generate(
      boardHeight,
      (_) => List.filled(boardWidth, null),
    );

    currentType =
        TetrominoType.values[random.nextInt(TetrominoType.values.length)];
    nextType =
        TetrominoType.values[random.nextInt(TetrominoType.values.length)];
    rotationIndex = 0;
    currentX = 3;
    currentY = 0;
    score = 0;

    _timer?.cancel();
    _startGameLoop();
  }

  void _startGameLoop() {
    const Duration speed = Duration(milliseconds: 500);

    _timer = Timer.periodic(speed, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_checkCollision(currentX, currentY + 1, rotationIndex)) {
          _lockTetromino();
          _spawnNewTetromino();
        } else {
          currentY++;
        }
      });
    });
  }

  void _spawnNewTetromino() {
    currentType = nextType;
    nextType =
        TetrominoType.values[random.nextInt(TetrominoType.values.length)];
    rotationIndex = 0;
    currentX = 3;
    currentY = 0;

    if (_checkCollision(currentX, currentY, rotationIndex)) {
      _timer?.cancel(); // Stop the timer to pause the game
      _showGameOverDialog();
    }
  }

  bool _checkCollision(int x, int y, int rotation) {
    final shape = Tetromino.shapes[currentType]![rotation];

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (shape[i][j] == 1) {
          int newX = x + j;
          int newY = y + i;

          if (newX < 0 || newX >= boardWidth || newY >= boardHeight) {
            return true;
          }
          if (newY >= 0 && gameBoard[newY][newX] != null) return true;
        }
      }
    }
    return false;
  }

  void _lockTetromino() {
    final shape = Tetromino.shapes[currentType]![rotationIndex];
    final color = Tetromino.colors[currentType]!;

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (shape[i][j] == 1) {
          int boardX = currentX + j;
          int boardY = currentY + i;

          if (boardY >= 0 &&
              boardY < boardHeight &&
              boardX >= 0 &&
              boardX < boardWidth) {
            gameBoard[boardY][boardX] = color;
          }
        }
      }
    }
    _clearFullRows();
  }

  void _clearFullRows() {
    int clearedRows = 0;

    for (int y = boardHeight - 1; y >= 0; y--) {
      if (gameBoard[y].every((cell) => cell != null)) {
        gameBoard.removeAt(y);
        gameBoard.insert(0, List.filled(boardWidth, null));
        clearedRows++;
        y++; // Recheck the same index after shifting rows down
      }
    }

    if (clearedRows > 0) {
      score += clearedRows * 10;
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameOverDialog(
          score: score,
          onNewGame: () {
            Navigator.of(context).pop();
            setState(() {
              _initializeGame();
            });
          },
        );
      },
    );
  }

  void moveLeft() {
    setState(() {
      if (!_checkCollision(currentX - 1, currentY, rotationIndex)) {
        currentX--;
      }
    });
  }

  void moveRight() {
    setState(() {
      if (!_checkCollision(currentX + 1, currentY, rotationIndex)) {
        currentX++;
      }
    });
  }

  void moveDown() {
    setState(() {
      if (_checkCollision(currentX, currentY + 1, rotationIndex)) {
        _lockTetromino();
        _spawnNewTetromino();
      } else {
        currentY++;
      }
    });
  }

  void rotate() {
    int nextRotation = (rotationIndex + 1) % 4;
    setState(() {
      if (!_checkCollision(currentX, currentY, nextRotation)) {
        rotationIndex = nextRotation;
      }
    });
  }

  Widget _buildGameBoard() {
    final currentShape = Tetromino.shapes[currentType]![rotationIndex];
    final currentColor = Tetromino.colors[currentType]!;

    return Expanded(
      flex: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 38, 43, 57),
            borderRadius: BorderRadius.circular(16),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: boardWidth,
            ),
            itemCount: boardWidth * boardHeight,
            itemBuilder: (context, index) {
              final x = index % boardWidth;
              final y = index ~/ boardWidth;

              Color cellColor =
                  gameBoard[y][x] ?? Color.fromARGB(255, 38, 43, 57);

              for (int i = 0; i < 4; i++) {
                for (int j = 0; j < 4; j++) {
                  if (currentShape[i][j] == 1) {
                    final blockX = currentX + j;
                    final blockY = currentY + i;
                    if (x == blockX && y == blockY) {
                      cellColor = currentColor;
                    }
                  }
                }
              }

              return Container(
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Color.fromARGB(255, 44, 50, 66),
                  ),
                ),
                // child: Center(
                //   child: Text(
                //     '$x,$y',
                //     style: const TextStyle(
                //       color: Colors.white70,
                //       fontSize: 10,
                //     ),
                //   ),
                // ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildTetrominoBlock(TetrominoType type, int rotation) {
    final shape = Tetromino.shapes[type]![rotation];
    final color = Tetromino.colors[type]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: shape.map((row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: row.map((cell) {
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.all(0.5),
              color: cell == 1 ? color : Colors.transparent,
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 242, 247, 255),
      body: SafeArea(
        child: Column(
          children: [
            ScoreAndNextBlockSection(
              score: score,
              nextType: nextType,
              buildTetrominoBlock: buildTetrominoBlock,
            ),
            const SizedBox(height: 16),
            _buildGameBoard(),
            const SizedBox(height: 16),
            _buildBottomSection()
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Expanded(
      flex: 1,
      child: Stack(
        children: [
          ControllerSection(
            onDown: () {
              if (!isPaused) moveDown();
            },
            onLeft: () {
              if (!isPaused) moveLeft();
            },
            onRight: () {
              if (!isPaused) moveRight();
            },
            onRotate: () {
              if (!isPaused) rotate();
            },
          ),
          Positioned(
            bottom: 0,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  width: 1,
                  color: Color.fromARGB(255, 38, 43, 57),
                ),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    isPaused = !isPaused;
                    if (isPaused) {
                      _timer?.cancel();
                    } else {
                      _startGameLoop();
                    }
                  });
                },
                icon: Icon(
                  isPaused ? Icons.play_arrow : Icons.pause_outlined,
                  size: 28,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
