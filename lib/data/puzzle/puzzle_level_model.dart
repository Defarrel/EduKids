import 'package:flutter/material.dart';

class PuzzleLevel {
  final String title;
  final String imagePath;
  final int gridSize;
  final Color boardColor;

  PuzzleLevel({
    required this.title,
    required this.imagePath,
    required this.gridSize,
    this.boardColor = const Color(0xFFFFFFFF),
  });
}
