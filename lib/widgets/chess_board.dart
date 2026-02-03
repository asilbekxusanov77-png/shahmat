import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/piese.dart';

class ChessBoard extends StatelessWidget {
  final List<List<Piece?>> board;
  final Map<String, int>? selectedPiece;
  final Function(int, int) onCellTap;
  final bool Function(int, int) isValidMove;
  final double cellSize;

  const ChessBoard({
    Key? key,
    required this.board,
    required this.selectedPiece,
    required this.onCellTap,
    required this.isValidMove,
    required this.cellSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF78350F), width: 4),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Column(
          children: List.generate(8, (row) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(8, (col) {
                bool isBlackSquare = (row + col) % 2 == 1;
                bool isSelected = selectedPiece != null &&
                    selectedPiece!['row'] == row &&
                    selectedPiece!['col'] == col;
                bool isValid = isValidMove(row, col);
                Piece? piece = board[row][col];

                return GestureDetector(
                  onTap: () => onCellTap(row, col),
                  child: Container(
                    width: cellSize,
                    height: cellSize,
                    decoration: BoxDecoration(
                      color: isBlackSquare
                          ? const Color(0xFF92400E)
                          : const Color(0xFFFDE68A),
                      border: isSelected
                          ? Border.all(color: Colors.blue, width: 3)
                          : isValid
                              ? Border.all(color: Colors.green, width: 3)
                              : null,
                    ),
                    child: piece != null
                        ? Center(
                            child: Container(
                              width: cellSize * 0.75,
                              height: cellSize * 0.75,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: piece.color == 'white'
                                      ? [const Color(0xFFF3F4F6), const Color(0xFFD1D5DB)]
                                      : [const Color(0xFF374151), const Color(0xFF1F2937)],
                                ),
                                border: Border.all(
                                  color: piece.color == 'white'
                                      ? const Color(0xFF9CA3AF)
                                      : Colors.black,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: piece.isKing
                                  ? Icon(
                                      Icons.stars,
                                      color: piece.color == 'white'
                                          ? const Color(0xFFEAB308)
                                          : const Color(0xFFFBBF24),
                                      size: cellSize * 0.5,
                                    )
                                  : null,
                            ),
                          )
                        : null,
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}