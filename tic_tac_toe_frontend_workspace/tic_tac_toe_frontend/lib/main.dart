import 'package:flutter/material.dart';

void main() {
  runApp(const TicTacToeApp());
}

/// PUBLIC_INTERFACE
class TicTacToeApp extends StatelessWidget {
  /// The main app widget, setting up theme and home screen for the game.
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define color palette
    const primaryColor = Color(0xFF1976d2);
    const secondaryColor = Color(0xFF424242);
    const accentColor = Color(0xFFffca28);

    return MaterialApp(
      title: 'Modern Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 18,
            color: secondaryColor,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: secondaryColor,
          ),
          titleLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
          titleMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: secondaryColor,
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const TicTacToePage(),
    );
  }
}

/// PUBLIC_INTERFACE
class TicTacToePage extends StatefulWidget {
  /// The home page widget, rendering the game board and controls.
  const TicTacToePage({super.key});

  @override
  State<TicTacToePage> createState() => _TicTacToePageState();
}

enum Player { x, o }

enum GameResult { ongoing, draw, winX, winO }

class _TicTacToePageState extends State<TicTacToePage>
    with SingleTickerProviderStateMixin {
  static const int boardSize = 3;
  List<List<Player?>> _board = List.generate(
      boardSize, (_) => List.filled(boardSize, null, growable: false),
      growable: false);
  Player _currentPlayer = Player.x;
  int _scoreX = 0;
  int _scoreO = 0;
  GameResult _gameResult = GameResult.ongoing;
  bool _triggerBoardAnim = false;

  // Animation controller for board transition (for reset)
  late AnimationController _boardAnimationController;

  @override
  void initState() {
    super.initState();
    _boardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    // Initial state
    _resetBoard(animated: false);
  }

  @override
  void dispose() {
    _boardAnimationController.dispose();
    super.dispose();
  }

  /// PUBLIC_INTERFACE
  void _handleCellTap(int x, int y) {
    if (_board[x][y] != null || _gameResult != GameResult.ongoing) {
      // Ignore tap if cell not empty or game over
      return;
    }
    setState(() {
      _board[x][y] = _currentPlayer;
      _gameResult = _detectGameResult();
      if (_gameResult == GameResult.ongoing) {
        _currentPlayer = _currentPlayer == Player.x ? Player.o : Player.x;
      } else {
        // Update score if needed
        if (_gameResult == GameResult.winX) {
          _scoreX++;
        } else if (_gameResult == GameResult.winO) {
          _scoreO++;
        }
      }
    });
  }

  /// PUBLIC_INTERFACE
  void _resetBoard({bool animated = true}) {
    setState(() {
      // Animate board opacity out, then reset grid and fade in
      if (animated) {
        _triggerBoardAnim = true;
        _boardAnimationController.reverse(from: 1.0).then((_) {
          setState(() {
            _board =
                List.generate(boardSize, (_) => List.filled(boardSize, null));
            _gameResult = GameResult.ongoing;
            _currentPlayer = (_scoreX + _scoreO) % 2 == 0 ? Player.x : Player.o;
            _triggerBoardAnim = false;
            _boardAnimationController.forward(from: 0.0);
          });
        });
      } else {
        _board =
            List.generate(boardSize, (_) => List.filled(boardSize, null));
        _gameResult = GameResult.ongoing;
        _currentPlayer = Player.x;
        _triggerBoardAnim = false;
      }
    });
  }

  /// PUBLIC_INTERFACE
  GameResult _detectGameResult() {
    // Win conditions
    for (var i = 0; i < boardSize; i++) {
      // Check rows
      if (_board[i][0] != null &&
          _board[i][0] == _board[i][1] &&
          _board[i][1] == _board[i][2]) {
        return _board[i][0] == Player.x ? GameResult.winX : GameResult.winO;
      }
      // Check columns
      if (_board[0][i] != null &&
          _board[0][i] == _board[1][i] &&
          _board[1][i] == _board[2][i]) {
        return _board[0][i] == Player.x ? GameResult.winX : GameResult.winO;
      }
    }
    // Diagonals
    if (_board[0][0] != null &&
        _board[0][0] == _board[1][1] &&
        _board[1][1] == _board[2][2]) {
      return _board[0][0] == Player.x ? GameResult.winX : GameResult.winO;
    }
    if (_board[0][2] != null &&
        _board[0][2] == _board[1][1] &&
        _board[1][1] == _board[2][0]) {
      return _board[0][2] == Player.x ? GameResult.winX : GameResult.winO;
    }
    // Draw if board is full
    if (_board.expand((row) => row).every((cell) => cell != null)) {
      return GameResult.draw;
    }
    return GameResult.ongoing;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const boardPadding = 16.0;
    const boardSizePx = 320.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: boardPadding, vertical: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Above board: Player turn indicator and Score
                _buildStatusAndScore(theme),
                const SizedBox(height: 32),
                // Game board with animated transitions
                AnimatedBuilder(
                  animation: _boardAnimationController,
                  builder: (context, child) {
                    final opacity = _triggerBoardAnim
                        ? _boardAnimationController.value
                        : 1.0;
                    return Opacity(
                      opacity: opacity,
                      child: child,
                    );
                  },
                  child: Container(
                    width: boardSizePx,
                    height: boardSizePx,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.secondary.withOpacity(0.10),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(boardSize, (x) {
                        return Expanded(
                          child: Row(
                            children: List.generate(boardSize, (y) {
                              return Expanded(
                                  child: _buildCell(x, y, theme));
                            }),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Below board: result, reset button
                _buildResultAndReset(theme)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusAndScore(ThemeData theme) {
    // Layout: (Turn Indicator)    (Score X | Score O)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Current player/turn indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: (255 * 0.20).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                _currentPlayer == Player.x ? Icons.close : Icons.panorama_fish_eye,
                color: theme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 7),
              Text(
                'Turn ${_currentPlayer == Player.x ? "X" : "O"}',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
        // Score
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: (255 * 0.07).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                WidgetSpan(
                  child: Icon(Icons.close,
                      color: Colors.blueGrey[700], size: 20),
                ),
                TextSpan(
                  text: "  $_scoreX",
                  style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                const TextSpan(
                  text: "   :   ",
                  style: TextStyle(
                      color: Color(0xFFB0B0B0), fontSize: 18),
                ),
                WidgetSpan(
                  child: Icon(Icons.panorama_fish_eye,
                      color: Color(0xFFffca28), size: 20),
                ),
                TextSpan(
                  text: "  $_scoreO",
                  style: TextStyle(
                      color: Color(0xFFffca28),
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultAndReset(ThemeData theme) {
    String result;
    Color? resultColor;

    switch (_gameResult) {
      case GameResult.ongoing:
        result = '';
        break;
      case GameResult.draw:
        result = "It's a Draw!";
        resultColor = theme.colorScheme.secondary;
        break;
      case GameResult.winX:
        result = "Player X Wins!";
        resultColor = theme.primaryColor;
        break;
      case GameResult.winO:
        result = "Player O Wins!";
        resultColor = const Color(0xFFffca28);
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Result display
        if (result.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: child,
              ),
              child: Text(
                result,
                key: ValueKey(result),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: resultColor,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        // Reset button
        SizedBox(
          width: 140,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFffca28),
              foregroundColor: theme.colorScheme.secondary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            onPressed: () => _resetBoard(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
        ),
      ],
    );
  }

  Widget _buildCell(int x, int y, ThemeData theme) {
    final Player? player = _board[x][y];
    final isWinningCell = _isPartOfWinningLine(x, y);

    return Padding(
      padding: const EdgeInsets.all(3.2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isWinningCell
              ? theme.primaryColor.withValues(alpha: (255 * 0.17).round())
              : Colors.white,
          border: Border.all(
            color: theme.colorScheme.secondary.withValues(alpha: (255 * 0.17).round()),
            width: 1.6,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            splashColor: theme.primaryColor.withValues(alpha: (255 * 0.35).round()),
            onTap: () => _handleCellTap(x, y),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: _buildCellMark(player, theme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCellMark(Player? player, ThemeData theme) {
    if (player == Player.x) {
      return Icon(
        Icons.close,
        key: const ValueKey('X'),
        color: theme.primaryColor,
        size: 48,
      );
    } else if (player == Player.o) {
      return Icon(
        Icons.panorama_fish_eye,
        key: const ValueKey('O'),
        color: const Color(0xFFffca28),
        size: 48,
      );
    } else {
      return const SizedBox.shrink(key: ValueKey('empty'));
    }
  }

  bool _isPartOfWinningLine(int x, int y) {
    // Highlight winning line cells if game is won
    if (_gameResult != GameResult.winX && _gameResult != GameResult.winO) {
      return false;
    }
    Player? winPlayer = _gameResult == GameResult.winX ? Player.x : Player.o;
    // Check all win lines
    // Rows
    for (var i = 0; i < boardSize; i++) {
      if (_board[i][0] == winPlayer &&
          _board[i][1] == winPlayer &&
          _board[i][2] == winPlayer) {
        if (x == i) return true;
      }
    }
    // Columns
    for (var i = 0; i < boardSize; i++) {
      if (_board[0][i] == winPlayer &&
          _board[1][i] == winPlayer &&
          _board[2][i] == winPlayer) {
        if (y == i) return true;
      }
    }
    // Diagonal
    if (_board[0][0] == winPlayer &&
        _board[1][1] == winPlayer &&
        _board[2][2] == winPlayer) {
      if (x == y) return true;
    }
    if (_board[0][2] == winPlayer &&
        _board[1][1] == winPlayer &&
        _board[2][0] == winPlayer) {
      if (x + y == 2) return true;
    }
    return false;
  }
}
