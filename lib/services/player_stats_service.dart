import 'package:shared_preferences/shared_preferences.dart';

class PlayerStatsService {
  static const String _coinsKey = 'player_coins';
  static const String _winsKey = 'player_wins';
  static const String _gamesPlayedKey = 'games_played';

  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinsKey) ?? 0;
  }

  static Future<void> setCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, coins);
  }

  static Future<void> addCoins(int amount) async {
    final currentCoins = await getCoins();
    await setCoins(currentCoins + amount);
  }

  static Future<int> getWins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_winsKey) ?? 0;
  }

  static Future<void> setWins(int wins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_winsKey, wins);
  }

  static Future<void> addWin() async {
    final currentWins = await getWins();
    await setWins(currentWins + 1);
  }

  static Future<int> getGamesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_gamesPlayedKey) ?? 0;
  }

  static Future<void> setGamesPlayed(int games) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_gamesPlayedKey, games);
  }

  static Future<void> addGamePlayed() async {
    final currentGames = await getGamesPlayed();
    await setGamesPlayed(currentGames + 1);
  }

  static Future<double> getWinRate() async {
    final wins = await getWins();
    final games = await getGamesPlayed();
    if (games == 0) return 0;
    return (wins / games) * 100;
  }
}
