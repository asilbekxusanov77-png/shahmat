class Piece {
  final String color;
  bool isKing;

  Piece({required this.color, this.isKing = false});

  Piece copyWith({String? color, bool? isKing}) {
    return Piece(
      color: color ?? this.color,
      isKing: isKing ?? this.isKing,
    );
  }
}