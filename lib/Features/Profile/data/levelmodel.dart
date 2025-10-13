class Level {
  final String name;
  final String description;
  final String imagePath;
  
  final int pointsRequired;
  final bool isUnlocked;

  Level({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.pointsRequired,
    required this.isUnlocked,
  });

  Level copyWith({bool? isUnlocked}) {
    return Level(
      name: name,
      description: description,
      imagePath: imagePath,
      pointsRequired: pointsRequired,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}