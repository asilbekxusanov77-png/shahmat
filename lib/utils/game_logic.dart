import 'package:flutter_application_1/models/capture_move.dart';
import 'package:flutter_application_1/models/piese.dart';
import 'package:flutter_application_1/models/possible_moves.dart';


class GameLogic {
  static PossibleMoves getPossibleMoves(
    List<List<Piece?>> board,
    int row,
    int col,
    Piece piece,
  ) {
    List<List<int>> moves = [];
    List<CaptureMove> captures = [];

    if (piece.isKing) {
      // Damka - butun diagonal bo'ylab harakat (barcha yo'nalishda)
      List<List<int>> directions = [[-1, -1], [-1, 1], [1, -1], [1, 1]];
      
      for (var dir in directions) {
        int distance = 1;
        bool blocked = false;
        Piece? enemyPiece;
        int? enemyRow, enemyCol;
        
        while (!blocked) {
          int newRow = row + (dir[0] * distance);
          int newCol = col + (dir[1] * distance);
          
          if (newRow < 0 || newRow >= 8 || newCol < 0 || newCol >= 8) break;
          
          if (board[newRow][newCol] == null) {
            if (enemyPiece == null) {
              moves.add([newRow, newCol]);
            } else {
              captures.add(CaptureMove(
                targetRow: newRow,
                targetCol: newCol,
                capturedRow: enemyRow!,
                capturedCol: enemyCol!,
              ));
            }
          } else {
            if (board[newRow][newCol]!.color != piece.color) {
              if (enemyPiece == null) {
                enemyPiece = board[newRow][newCol];
                enemyRow = newRow;
                enemyCol = newCol;
              } else {
                blocked = true;
              }
            } else {
              blocked = true;
            }
          }
          distance++;
        }
      }
    } else {
      // Oddiy shashka
      // Oddiy yurish uchun faqat oldinga
      List<List<int>> forwardDirections = piece.color == 'white'
          ? [[-1, -1], [-1, 1]]  // Oq tepaga
          : [[1, -1], [1, 1]];    // Qora pastga

      for (var dir in forwardDirections) {
        int newRow = row + dir[0];
        int newCol = col + dir[1];

        if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
          if (board[newRow][newCol] == null) {
            moves.add([newRow, newCol]);
          }
        }
      }

      // Yeb olish uchun barcha yo'nalishlar (oldinga va orqaga ham)
      List<List<int>> allDirections = [
        [-1, -1], [-1, 1],  // Tepaga
        [1, -1], [1, 1]      // Pastga
      ];

      for (var dir in allDirections) {
        int newRow = row + dir[0];
        int newCol = col + dir[1];

        if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
          if (board[newRow][newCol] != null && board[newRow][newCol]!.color != piece.color) {
            // Yeb olish
            int jumpRow = newRow + dir[0];
            int jumpCol = newCol + dir[1];
            if (jumpRow >= 0 && jumpRow < 8 && jumpCol >= 0 && jumpCol < 8 && 
                board[jumpRow][jumpCol] == null) {
              captures.add(CaptureMove(
                targetRow: jumpRow,
                targetCol: jumpCol,
                capturedRow: newRow,
                capturedCol: newCol,
              ));
            }
          }
        }
      }
    }

    return PossibleMoves(moves: moves, captures: captures);
  }

  static List<Map<String, dynamic>> getAllCaptures(
    List<List<Piece?>> board,
    String color,
  ) {
    List<Map<String, dynamic>> allCaptures = [];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        Piece? piece = board[row][col];
        if (piece != null && piece.color == color) {
          var result = getPossibleMoves(board, row, col, piece);
          if (result.captures.isNotEmpty) {
            allCaptures.add({'row': row, 'col': col, 'captures': result.captures});
          }
        }
      }
    }
    return allCaptures;
  }

  static bool checkWinCondition(List<List<Piece?>> board) {
    int whitePieces = board
        .expand((row) => row)
        .where((p) => p != null && p.color == 'white')
        .length;
    int blackPieces = board
        .expand((row) => row)
        .where((p) => p != null && p.color == 'black')
        .length;

    return whitePieces == 0 || blackPieces == 0;
  }

  static String? getWinner(List<List<Piece?>> board) {
    int whitePieces = board
        .expand((row) => row)
        .where((p) => p != null && p.color == 'white')
        .length;
    int blackPieces = board
        .expand((row) => row)
        .where((p) => p != null && p.color == 'black')
        .length;

    if (whitePieces == 0) return 'black';
    if (blackPieces == 0) return 'white';
    return null;
  }
}