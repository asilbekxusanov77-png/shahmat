import 'package:flutter/material.dart';
import '../services/player_stats_service.dart';

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  late Future<Map<String, dynamic>> _playerStats;

  @override
  void initState() {
    super.initState();
    _playerStats = _loadPlayerStats();
  }

  Future<Map<String, dynamic>> _loadPlayerStats() async {
    final coins = await PlayerStatsService.getCoins();
    final wins = await PlayerStatsService.getWins();
    final games = await PlayerStatsService.getGamesPlayed();
    final winRate = await PlayerStatsService.getWinRate();

    return {
      'coins': coins,
      'wins': wins,
      'games': games,
      'winRate': winRate,
    };
  }

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
          child: FutureBuilder<Map<String, dynamic>>(
            future: _playerStats,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData) {
                return const Center(child: Text('Xatolik yuz berdi'));
              }

              final stats = snapshot.data!;
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    backgroundColor: const Color(0xFFFBBF24),
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text(
                        'Sizning Statistika',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFBBF24),
                              const Color(0xFFF59E0B),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person_outline,
                            size: 80,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Tangalar kartasi
                        _buildStatCard(
                          icon: Icons.monetization_on,
                          title: 'Jami Tangalar',
                          value: stats['coins'].toString(),
                          color: const Color(0xFFFBBF24),
                          backgroundColor: const Color(0xFFFEF3C7),
                        ),
                        const SizedBox(height: 16),

                        // G'alabalar kartasi
                        _buildStatCard(
                          icon: Icons.emoji_events,
                          title: 'G\'alabalar',
                          value: stats['wins'].toString(),
                          color: const Color(0xFF10B981),
                          backgroundColor: const Color(0xFFD1FAE5),
                        ),
                        const SizedBox(height: 16),

                        // O'yinlar kartasi
                        _buildStatCard(
                          icon: Icons.sports_esports,
                          title: 'O\'yinlar',
                          value: stats['games'].toString(),
                          color: const Color(0xFF3B82F6),
                          backgroundColor: const Color(0xFFDEF0FF),
                        ),
                        const SizedBox(height: 16),

                        // G'alabalar foizi kartasi
                        _buildStatCard(
                          icon: Icons.trending_up,
                          title: 'G\'alabalar Foizi',
                          value: '${stats['winRate'].toStringAsFixed(1)}%',
                          color: const Color(0xFF8B5CF6),
                          backgroundColor: const Color(0xFFF3E8FF),
                        ),
                        const SizedBox(height: 32),

                        // Statistika qatorlari
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ko\'rsatkich',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF78350F),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildStatRow(
                                'Jami Tangalar',
                                stats['coins'].toString(),
                              ),
                              const Divider(height: 16),
                              _buildStatRow(
                                'G\'alabalar',
                                stats['wins'].toString(),
                              ),
                              const Divider(height: 16),
                              _buildStatRow(
                                'O\'yinlar',
                                stats['games'].toString(),
                              ),
                              const Divider(height: 16),
                              _buildStatRow(
                                'Yo\'qotishlar',
                                (stats['games'] - stats['wins']).toString(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Statistikani tozalash tugmasi
                        ElevatedButton.icon(
                          onPressed: _resetStats,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Statistikani Tozalash'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  void _resetStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistikani Tozalash'),
        content: const Text(
          'Haqiqatan ham barcha statistikani tozalamoqchisiz? Bu amal qaytarilishi mumkin emas!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () async {
              await PlayerStatsService.setCoins(0);
              await PlayerStatsService.setWins(0);
              await PlayerStatsService.setGamesPlayed(0);
              Navigator.pop(context);
              setState(() {
                _playerStats = _loadPlayerStats();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Statistika tozalandi'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Tozalash', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
