import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'player_profile_screen.dart';
import '../services/player_stats_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // Reitingi paneli
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlayerProfileScreen(),
                      ),
                    );
                  },
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: Future.wait([
                      PlayerStatsService.getCoins(),
                      PlayerStatsService.getWins(),
                      PlayerStatsService.getWinRate(),
                    ]).then((results) => {
                      'coins': results[0] as int,
                      'wins': results[1] as int,
                      'winRate': results[2] as double,
                    }),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildRatingCard(0, 0, 0.0);
                      }
                      if (!snapshot.hasData) {
                        return _buildRatingCard(0, 0, 0.0);
                      }
                      final stats = snapshot.data!;
                      return _buildRatingCard(
                        stats['coins'] as int,
                        stats['wins'] as int,
                        stats['winRate'] as double,
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              size: 100,
                              color: Color(0xFFCA8A04),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Sarlavha
                          const Text(
                            'Shashka O\'yini',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF78350F),
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Robot bilan o\'yinni boshlang!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 48),
                          
                          // Darajalar
                          _buildLevelButton(
                            context,
                            '🌱 Oson',
                            'Yangi boshlovchilar uchun',
                            const Color(0xFF10B981),
                            1,
                          ),
                          const SizedBox(height: 16),
                          _buildLevelButton(
                            context,
                            '⚡ O\'rtacha',
                            'Tajribali o\'yinchilar uchun',
                            const Color(0xFFF59E0B),
                            2,
                          ),
                          const SizedBox(height: 16),
                          _buildLevelButton(
                            context,
                            '🔥 Qiyin',
                            'Professionallar uchun',
                            const Color(0xFFEF4444),
                            3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingCard(int coins, int wins, double winRate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFBBF24), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildRatingItem(
            icon: Icons.monetization_on,
            label: 'Tangalar',
            value: coins.toString(),
            color: const Color(0xFFFBBF24),
          ),
          Container(
            width: 1,
            height: 60,
            color: Colors.grey.withOpacity(0.3),
          ),
          _buildRatingItem(
            icon: Icons.emoji_events,
            label: 'G\'alabalar',
            value: wins.toString(),
            color: const Color(0xFF10B981),
          ),
          Container(
            width: 1,
            height: 60,
            color: Colors.grey.withOpacity(0.3),
          ),
          _buildRatingItem(
            icon: Icons.trending_up,
            label: 'Foiz',
            value: '${winRate.toStringAsFixed(0)}%',
            color: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelButton(BuildContext context, String title, String subtitle, Color color, int level) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(difficulty: level),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}