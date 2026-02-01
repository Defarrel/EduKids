class PuzzleLevel {
  final String title;       
  final String imagePath;   
  final int gridSize;       

  PuzzleLevel({
    required this.title,
    required this.imagePath,
    this.gridSize = 3, 
  });
}