import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/piese.dart';
import 'dart:async';
import 'dart:math';
import '../models/capture_move.dart';
import '../models/possible_moves.dart';
import '../utils/game_logic.dart';
import '../widgets/chess_board.dart';
import '../widgets/score_card.dart';
import '../widgets/result_dialog.dart';

class GameScreen extends StatefulWidget {
  final int difficulty;
  
  const GameScreen({Key? key, required this.difficulty}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<List<Piece?>> board = [];
  Map<String, int>? selectedPiece;
  String currentPlayer = 'white';
  Map<String, int> capturedPieces = {'white': 0, 'black': 0};
  bool gameOver = false;
  String? winner;
  Map<String, int> timer = {'white': 600, 'black': 600};
  bool isTimerActive = false;
  Timer? gameTimer;
  
  int playerWins = 0;
  int robotWins = 0;
  int coins = 0; // Tangalar tizimi
  bool showResult = false;
  String resultMessage = '';
  final Random random = Random();
  
  // Ketma-ket yeb olishni kuzatish uchun
  int currentCaptureStreak = 0;
  String lastCapturePlayer = '';

  @override
  void initState() {
    super.initState();
    initializeBoard();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void initializeBoard() {
    board = List.generate(8, (i) => List.generate(8, (j) => null));

    // Qora shashkalar tepada (0-2 qatorlar)
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 8; col++) {
        if ((row + col) % 2 == 1) {
          board[row][col] = Piece(color: 'black');
        }
      }
    }

    // Oq shashkalar pastda (5-7 qatorlar)
    for (int row = 5; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if ((row + col) % 2 == 1) {
          board[row][col] = Piece(color: 'white');
        }
      }
    }

    setState(() {
      currentPlayer = 'white';
      capturedPieces = {'white': 0, 'black': 0};
      gameOver = false;
      winner = null;
      timer = {'white': 600, 'black': 600};
      selectedPiece = null;
      isTimerActive = false;
      showResult = false;
      currentCaptureStreak = 0;
      lastCapturePlayer = '';
    });

    gameTimer?.cancel();
  }

  void startTimer() {
    if (!isTimerActive) {
      isTimerActive = true;
      gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!gameOver) {
          setState(() {
            this.timer[currentPlayer] = this.timer[currentPlayer]! - 1;
            if (this.timer[currentPlayer]! <= 0) {
              endGame(currentPlayer == 'white' ? 'black' : 'white');
            }
          });
        }
      });
    }
  }

  void handleCellClick(int row, int col) {
    if (gameOver || currentPlayer == 'black') return;

    if (!isTimerActive) startTimer();

    Piece? piece = board[row][col];
    List<Map<String, dynamic>> allCaptures = GameLogic.getAllCaptures(board, currentPlayer);

    if (selectedPiece == null) {
      if (piece != null && piece.color == currentPlayer) {
        if (allCaptures.isNotEmpty) {
          bool canCapture = allCaptures.any((c) => c['row'] == row && c['col'] == col);
          if (!canCapture) return;
        }
        // Yangi harakatni boshlash - capture countni reset qilish
        playerCaptureCount = 0;
        setState(() {
          selectedPiece = {'row': row, 'col': col};
        });
      }
    } else {
      int selectedRow = selectedPiece!['row']!;
      int selectedCol = selectedPiece!['col']!;
      Piece selectedPieceObj = board[selectedRow][selectedCol]!;

      PossibleMoves possibleMoves = GameLogic.getPossibleMoves(board, selectedRow, selectedCol, selectedPieceObj);

      if (allCaptures.isNotEmpty && possibleMoves.captures.isEmpty) {
        setState(() {
          selectedPiece = null;
        });
        return;
      }

      bool isCapture = possibleMoves.captures.any((c) => c.targetRow == row && c.targetCol == col);
      bool isMove = possibleMoves.moves.any((m) => m[0] == row && m[1] == col);

      if (isCapture) {
        CaptureMove captureInfo = possibleMoves.captures.firstWhere((c) => c.targetRow == row && c.targetCol == col);
        makeMove(selectedRow, selectedCol, row, col, captureInfo.capturedRow, captureInfo.capturedCol);
      } else if (isMove && allCaptures.isEmpty) {
        makeMove(selectedRow, selectedCol, row, col, null, null);
      } else {
        setState(() {
          selectedPiece = null;
        });
      }
    }
  }

  void makeMove(int fromRow, int fromCol, int toRow, int toCol, int? capturedRow, int? capturedCol) {
    Piece movingPiece = board[fromRow][fromCol]!;
    
    setState(() {
      board[toRow][toCol] = movingPiece.copyWith();
      board[fromRow][fromCol] = null;
      
      if (capturedRow != null && capturedCol != null) {
        board[capturedRow][capturedCol] = null;
        capturedPieces[currentPlayer] = capturedPieces[currentPlayer]! + 1;
        
        // Robot va o'yinchi uchun capture countni oshirish
        if (currentPlayer == 'black') {
          robotCaptureCount++;
        } else if (currentPlayer == 'white') {
          playerCaptureCount++;
        }
        
        // Ketma-ket yeb olishni hisoblash
        if (lastCapturePlayer == currentPlayer) {
          currentCaptureStreak++;
        } else {
          currentCaptureStreak = 1;
          lastCapturePlayer = currentPlayer;
        }
      } else {
        // Oddiy yurish - ketma-ketlik tugadi
        currentCaptureStreak = 0;
        lastCapturePlayer = '';
      }

      // Damkaga aylanish: oq 0-qatorda, qora 7-qatorda
      if ((toRow == 0 && movingPiece.color == 'white') ||
          (toRow == 7 && movingPiece.color == 'black')) {
        board[toRow][toCol]!.isKing = true;
      }
    });

    Piece newPiece = board[toRow][toCol]!;
    PossibleMoves nextMoves = GameLogic.getPossibleMoves(board, toRow, toCol, newPiece);

    if (capturedRow != null && nextMoves.captures.isNotEmpty) {
      // Ketma-ket yeb olish davom etadi
      if (currentPlayer == 'white') {
        setState(() {
          selectedPiece = {'row': toRow, 'col': toCol};
        });
      } else {
        // Robot uchun - avtomatik davom ettirish
        Future.delayed(const Duration(milliseconds: 300), () {
          // Eng yaxshi capture ni tanlash
          CaptureMove bestCapture = nextMoves.captures[0];
          if (nextMoves.captures.length > 1) {
            int bestScore = _evaluateCaptureMove(toRow, toCol, bestCapture);
            for (var capture in nextMoves.captures) {
              int score = _evaluateCaptureMove(toRow, toCol, capture);
              if (score > bestScore) {
                bestScore = score;
                bestCapture = capture;
              }
            }
          }
          makeMove(toRow, toCol, bestCapture.targetRow, bestCapture.targetCol, 
                   bestCapture.capturedRow, bestCapture.capturedCol);
        });
      }
      return;
    }

    // Yeb olish tugadi - tangalarni hisoblash
    setState(() {
      selectedPiece = null;
    });
    
    // Robot uchun tanga tizimini yangilash
    if (currentPlayer == 'black' && robotCaptureCount > 0) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (robotCaptureCount >= 2) {
          // Qora 2 yoki undan ko'p yeb oldi - har biri uchun 10 tanga berish
          setState(() {
            coins += robotCaptureCount * 10;
          });
          _showCoinNotification('+${robotCaptureCount * 10} 💰 (Robot ${robotCaptureCount} ta)', Colors.green);
        } else if (robotCaptureCount == 1) {
          // Qora 1 dona yeb oldi - 10 tanga kamaytirish
          setState(() {
            coins -= 10;
            if (coins < 0) coins = 0;
          });
          _showCoinNotification('-10 💰 (Robot 1 ta)', Colors.red);
        }
        robotCaptureCount = 0; // Reset
      });
    }
    
    // O'yinchi uchun tanga tizimini yangilash
    if (currentPlayer == 'white' && playerCaptureCount > 0) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (playerCaptureCount >= 2) {
          // Oq 2 yoki undan ko'p yeb oldi - har biri uchun 10 tanga berish
          setState(() {
            coins += playerCaptureCount * 10;
          });
          _showCoinNotification('+${playerCaptureCount * 10} 💰 (Siz ${playerCaptureCount} ta)', Colors.green);
        } else if (playerCaptureCount == 1) {
          // Oq 1 dona yeb oldi - 10 tanga kamaytirish
          setState(() {
            coins -= 10;
            if (coins < 0) coins = 0;
          });
          _showCoinNotification('-10 💰 (Siz 1 ta)', Colors.red);
        }
        playerCaptureCount = 0; // Reset
      });
    }

    if (!GameLogic.checkWinCondition(board)) {
      setState(() {
        currentPlayer = currentPlayer == 'white' ? 'black' : 'white';
      });
      
      if (currentPlayer == 'black') {
        Future.delayed(const Duration(milliseconds: 500), () {
          makeRobotMove();
        });
      }
    } else {
      String? gameWinner = GameLogic.getWinner(board);
      if (gameWinner != null) {
        endGame(gameWinner);
      }
    }
  }

  int robotCaptureCount = 0; // Robot bir harakatda nechta yeb olganini sanash
  int playerCaptureCount = 0; // O'yinchi bir harakatda nechta yeb olganini sanash
  
  void makeRobotMove() {
    if (gameOver) return;

    // Robot harakatini boshlashdan oldin hisobni reset qilish
    robotCaptureCount = 0;
    _performRobotMove();
  }

  void _performRobotMove() {
    List<Map<String, dynamic>> allCaptures = GameLogic.getAllCaptures(board, 'black');
    List<Map<String, dynamic>> allMoves = [];

    if (allCaptures.isEmpty) {
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          Piece? piece = board[row][col];
          if (piece != null && piece.color == 'black') {
            var result = GameLogic.getPossibleMoves(board, row, col, piece);
            if (result.moves.isNotEmpty) {
              allMoves.add({
                'row': row, 
                'col': col, 
                'moves': result.moves,
                'isKing': piece.isKing,
              });
            }
          }
        }
      }
    }

    if (widget.difficulty == 3) {
      // Qiyin daraja - Juda kuchli AI
      _makeHardMove(allCaptures, allMoves);
    } else if (widget.difficulty == 2) {
      // O'rtacha daraja - Yaxshi strategiya
      _makeMediumMove(allCaptures, allMoves);
    } else {
      // Oson daraja - Tasodifiy
      _makeEasyMove(allCaptures, allMoves);
    }
  }

  // Tanga bildirishnomasi
  void _showCoinNotification(String message, Color color) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: MediaQuery.of(context).size.width * 0.5 - 75,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  // Oson daraja - tasodifiy harakatlar
  void _makeEasyMove(List<Map<String, dynamic>> allCaptures, List<Map<String, dynamic>> allMoves) {
    if (allCaptures.isNotEmpty) {
      var selected = allCaptures[random.nextInt(allCaptures.length)];
      List<CaptureMove> captures = selected['captures'];
      CaptureMove move = captures[random.nextInt(captures.length)];
      makeMove(selected['row'], selected['col'], move.targetRow, move.targetCol, 
               move.capturedRow, move.capturedCol);
    } else if (allMoves.isNotEmpty) {
      var selected = allMoves[random.nextInt(allMoves.length)];
      List<List<int>> moves = selected['moves'];
      List<int> move = moves[random.nextInt(moves.length)];
      makeMove(selected['row'], selected['col'], move[0], move[1], null, null);
    }
  }

  // O'rtacha daraja - yaxshi strategiya
  void _makeMediumMove(List<Map<String, dynamic>> allCaptures, List<Map<String, dynamic>> allMoves) {
    if (allCaptures.isNotEmpty) {
      // Eng ko'p yeb olish imkoniyati borini tanlash
      var bestCapture = allCaptures[0];
      int maxCaptures = (bestCapture['captures'] as List).length;
      
      for (var capture in allCaptures) {
        int captureCount = (capture['captures'] as List).length;
        if (captureCount > maxCaptures) {
          maxCaptures = captureCount;
          bestCapture = capture;
        }
      }
      
      List<CaptureMove> captures = bestCapture['captures'];
      CaptureMove move = captures[random.nextInt(captures.length)];
      makeMove(bestCapture['row'], bestCapture['col'], move.targetRow, move.targetCol, 
               move.capturedRow, move.capturedCol);
    } else if (allMoves.isNotEmpty) {
      // Damkalarni oldinga sur, oddiy shashkalarni markazga
      var priorityMoves = <Map<String, dynamic>>[];
      var normalMoves = <Map<String, dynamic>>[];
      
      for (var moveData in allMoves) {
        if (moveData['isKing'] == true) {
          priorityMoves.add(moveData);
        } else {
          // Markazga yaqin harakatlarni afzal ko'r
          var moves = moveData['moves'] as List<List<int>>;
          bool hasCenter = moves.any((m) => m[1] >= 2 && m[1] <= 5);
          if (hasCenter) {
            priorityMoves.add(moveData);
          } else {
            normalMoves.add(moveData);
          }
        }
      }
      
      var selectedMoves = priorityMoves.isNotEmpty ? priorityMoves : normalMoves;
      if (selectedMoves.isNotEmpty) {
        var selected = selectedMoves[random.nextInt(selectedMoves.length)];
        List<List<int>> moves = selected['moves'];
        List<int> move = moves[random.nextInt(moves.length)];
        makeMove(selected['row'], selected['col'], move[0], move[1], null, null);
      }
    }
  }

  // Qiyin daraja - juda kuchli AI
  void _makeHardMove(List<Map<String, dynamic>> allCaptures, List<Map<String, dynamic>> allMoves) {
    if (allCaptures.isNotEmpty) {
      // Eng yaxshi yeb olishni topish
      var bestCapture = _findBestCapture(allCaptures);
      List<CaptureMove> captures = bestCapture['captures'];
      
      // Eng xavfli yeb olishni tanlash
      CaptureMove bestMove = captures[0];
      int bestScore = _evaluateCaptureMove(bestCapture['row'], bestCapture['col'], bestMove);
      
      for (var move in captures) {
        int score = _evaluateCaptureMove(bestCapture['row'], bestCapture['col'], move);
        if (score > bestScore) {
          bestScore = score;
          bestMove = move;
        }
      }
      
      makeMove(bestCapture['row'], bestCapture['col'], bestMove.targetRow, bestMove.targetCol, 
               bestMove.capturedRow, bestMove.capturedCol);
    } else if (allMoves.isNotEmpty) {
      // Eng yaxshi harakatni baholash
      var bestMove = _findBestMove(allMoves);
      if (bestMove != null) {
        makeMove(bestMove['fromRow'], bestMove['fromCol'], 
                 bestMove['toRow'], bestMove['toCol'], null, null);
      }
    }
  }

  // Eng yaxshi yeb olishni topish
  Map<String, dynamic> _findBestCapture(List<Map<String, dynamic>> allCaptures) {
    var bestCapture = allCaptures[0];
    int maxScore = 0;
    
    for (var capture in allCaptures) {
      int row = capture['row'];
      int col = capture['col'];
      List<CaptureMove> captures = capture['captures'];
      
      // Ko'p yeb olish imkoniyati
      int score = captures.length * 100;
      
      // Damka bilan yeb olish qo'shimcha ball
      Piece? piece = board[row][col];
      if (piece != null && piece.isKing) {
        score += 50;
      }
      
      if (score > maxScore) {
        maxScore = score;
        bestCapture = capture;
      }
    }
    
    return bestCapture;
  }

  // Yeb olish harakatini baholash
  int _evaluateCaptureMove(int fromRow, int fromCol, CaptureMove move) {
    int score = 100; // Asosiy ball
    
    // Markazda yeb olish yaxshiroq
    if (move.targetCol >= 2 && move.targetCol <= 5) {
      score += 20;
    }
    
    // Xavfsiz joyga o'tish (chekkaga yaqin emas)
    if (move.targetRow > 0 && move.targetRow < 7) {
      score += 10;
    }
    
    // Damkaga yaqinlashish
    if (move.targetRow == 7) {
      score += 100; // Damkaga aylanish juda muhim
    } else if (move.targetRow >= 5) {
      score += 30;
    }
    
    return score;
  }

  // Eng yaxshi harakatni topish
  Map<String, dynamic>? _findBestMove(List<Map<String, dynamic>> allMoves) {
    Map<String, dynamic>? bestMove;
    int maxScore = -1000;
    
    for (var moveData in allMoves) {
      int row = moveData['row'];
      int col = moveData['col'];
      bool isKing = moveData['isKing'];
      List<List<int>> moves = moveData['moves'];
      
      for (var move in moves) {
        int score = _evaluateMove(row, col, move[0], move[1], isKing);
        
        if (score > maxScore) {
          maxScore = score;
          bestMove = {
            'fromRow': row,
            'fromCol': col,
            'toRow': move[0],
            'toCol': move[1],
          };
        }
      }
    }
    
    return bestMove;
  }

  // Harakatni baholash
  int _evaluateMove(int fromRow, int fromCol, int toRow, int toCol, bool isKing) {
    int score = 0;
    
    // Damkaga aylanish - eng yuqori ustuvorlik
    if (toRow == 7 && !isKing) {
      score += 200;
    }
    
    // Damkaga yaqinlashish
    if (!isKing && toRow > fromRow) {
      score += (toRow - fromRow) * 30;
    }
    
    // Markazni nazorat qilish
    if (toCol >= 2 && toCol <= 5 && toRow >= 2 && toRow <= 5) {
      score += 40;
    }
    
    // Damkalarni oldinga sur
    if (isKing) {
      score += 50;
      // Damkani faol joyga o'tkazish
      if (toRow >= 3 && toRow <= 6) {
        score += 20;
      }
    }
    
    // Chekkadan uzoqlashish
    if (toCol > 0 && toCol < 7) {
      score += 10;
    }
    
    // Himoyalangan pozitsiya (qo'shni dona bor)
    int protectionCount = _countProtection(toRow, toCol);
    score += protectionCount * 15;
    
    // Raqib donalariga yaqinlashish
    int threatCount = _countThreats(toRow, toCol);
    score += threatCount * 25;
    
    return score;
  }

  // Himoyani hisoblash
  int _countProtection(int row, int col) {
    int count = 0;
    List<List<int>> directions = [[-1, -1], [-1, 1], [1, -1], [1, 1]];
    
    for (var dir in directions) {
      int newRow = row + dir[0];
      int newCol = col + dir[1];
      if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
        Piece? piece = board[newRow][newCol];
        if (piece != null && piece.color == 'black') {
          count++;
        }
      }
    }
    
    return count;
  }

  // Tahdidlarni hisoblash (raqib donalariga yaqinlik)
  int _countThreats(int row, int col) {
    int count = 0;
    List<List<int>> directions = [[-1, -1], [-1, 1], [1, -1], [1, 1]];
    
    for (var dir in directions) {
      int newRow = row + dir[0];
      int newCol = col + dir[1];
      if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
        Piece? piece = board[newRow][newCol];
        if (piece != null && piece.color == 'white') {
          count++;
        }
      }
    }
    
    return count;
  }

  void endGame(String winnerColor) {
    setState(() {
      gameOver = true;
      winner = winnerColor;
      isTimerActive = false;
      
      if (winnerColor == 'white') {
        playerWins++;
        resultMessage = '🎉 Siz yutdingiz! 🎉';
      } else {
        robotWins++;
        resultMessage = '🤖 Robot yutdi! 🤖';
      }
      
      showResult = true;
    });
    
    gameTimer?.cancel();
    
    if (playerWins + robotWins >= 5) {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          if (playerWins > robotWins) {
            resultMessage = '👑 TABRIKLAYMIZ! SIZ G\'OLIBSIZ! 👑';
          } else if (robotWins > playerWins) {
            resultMessage = '🤖 ROBOT G\'OLIB BO\'LDI! 🤖';
          } else {
            resultMessage = '🤝 DURRANG! 🤝';
          }
          showResult = true;
        });
        
        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            playerWins = 0;
            robotWins = 0;
            showResult = false;
          });
        });
      });
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          showResult = false;
        });
      });
    }
  }

  bool isValidMove(int row, int col) {
    if (selectedPiece == null) return false;
    int selectedRow = selectedPiece!['row']!;
    int selectedCol = selectedPiece!['col']!;
    Piece piece = board[selectedRow][selectedCol]!;

    PossibleMoves possibleMoves = GameLogic.getPossibleMoves(board, selectedRow, selectedCol, piece);
    List<Map<String, dynamic>> allCaptures = GameLogic.getAllCaptures(board, currentPlayer);

    if (allCaptures.isNotEmpty && possibleMoves.captures.isEmpty) return false;

    return possibleMoves.captures.any((c) => c.targetRow == row && c.targetCol == col) ||
        (allCaptures.isEmpty && possibleMoves.moves.any((m) => m[0] == row && m[1] == col));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final cellSize = (screenWidth * (isSmallScreen ? 0.9 : 0.5) / 8).clamp(40.0, 60.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFBEB), Color(0xFFFED7AA)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                  child: Column(
                    children: [
                      // Sarlavha
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Color(0xFF78350F)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(
                            child: Text(
                              'Shashka O\'yini',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF78350F),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tangalar ko'rsatkichi
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.white, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              '$coins',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // O'yin ma'lumotlari
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          ScoreCard(
                            label: 'Siz',
                            score: playerWins,
                            color: Colors.blue,
                            isActive: currentPlayer == 'white',
                          ),
                          ScoreCard(
                            label: 'Robot',
                            score: robotWins,
                            color: Colors.red,
                            isActive: currentPlayer == 'black',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: currentPlayer == 'white'
                                ? [const Color(0xFFF3F4F6), const Color(0xFFE5E7EB)]
                                : [const Color(0xFF374151), const Color(0xFF1F2937)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          gameOver
                              ? (winner == 'white' ? 'Siz yutdingiz!' : 'Robot yutdi!')
                              : 'Navbat: ${currentPlayer == 'white' ? 'Siz' : 'Robot'}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: currentPlayer == 'white' || gameOver 
                                ? const Color(0xFF1F2937) 
                                : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Shashka taxtasi
                      Center(
                        child: ChessBoard(
                          board: board,
                          selectedPiece: selectedPiece,
                          onCellTap: handleCellClick,
                          isValidMove: isValidMove,
                          cellSize: cellSize,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Yangi o'yin tugmasi
                      ElevatedButton.icon(
                        onPressed: initializeBoard,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Yangi O\'yin'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Natija ko'rsatish
              if (showResult)
                ResultDialog(message: resultMessage),
            ],
          ),
        ),
      ),
    );
  }
}