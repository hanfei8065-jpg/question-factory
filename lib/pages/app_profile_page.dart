import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/user_progress_service.dart';

class AppProfilePage extends StatefulWidget {
  const AppProfilePage({super.key});

  @override
  State<AppProfilePage> createState() => _AppProfilePageState();
}

class _AppProfilePageState extends State<AppProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  late Animation<double> _radarAnimation;

  // User Progress Service
  final _progressService = UserProgressService();

  // User data - loaded from service
  final String userName = "Student Name";
  final String grade = "Grade 10";
  late String tier;
  late int currentXP;
  late int maxXP;
  late int totalQuestions;
  final double accuracy = 0.87;
  final String focusTime = "42h";

  // Radar chart data (0-10 scale)
  final List<double> skillLevels = [
    8.5,
    7.2,
    6.8,
    7.5,
    9.0,
  ]; // Algebra, Geometry, Physics, Chem, Logic
  final List<String> skillLabels = ['代数', '几何', '物理', '化学', '逻辑'];

  @override
  void initState() {
    super.initState();

    // Load real user stats
    final stats = _progressService.getStats();
    tier = stats.rankTitle;
    currentXP = stats.totalXP;
    totalQuestions = stats.questionsSolved;

    // Calculate XP for next rank
    final xpForNext = _progressService.getXPForNextRank();
    if (xpForNext == 0) {
      // Max rank reached
      maxXP = currentXP;
    } else {
      // Find the threshold for next rank
      final nextRankTitle = _progressService.getNextRankTitle();
      // Calculate max XP based on rank thresholds
      final rankThresholds = {
        'Bronze Learner': 500,
        'Silver Scholar': 1000,
        'Gold Achiever': 2500,
        'Platinum Master': 5000,
        'Diamond Legend': 10000,
        'Ultimate Sage': 20000,
      };
      maxXP = rankThresholds[nextRankTitle] ?? currentXP;
    }

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _radarAnimation = CurvedAnimation(
      parent: _radarController,
      curve: Curves.easeOutCubic,
    );
    _radarController.forward();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _showCertificateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.workspace_premium, color: Color(0xFFFFD700)),
            SizedBox(width: 8),
            Text('荣誉证书'),
          ],
        ),
        content: const Text('达到 Legend 段位解锁官方推荐信'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _showParentReportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.analytics, color: Color(0xFF3B82F6)),
            SizedBox(width: 8),
            Text('家长周报'),
          ],
        ),
        content: const Text('升级 VIP 解锁深度分析'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _onSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('设置功能开发中...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已退出登录')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgGrey = Color(0xFFF5F7FA);
    const Color wechatGreen = Color(0xFF07C160);
    const Color darkSlate = Color(0xFF1E293B);
    const Color lightGrey = Color(0xFF94A3B8);
    const Color progressBg = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section A: Identity Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Stack(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xFFE2E8F0),
                            child: Text(
                              'SN',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkSlate,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFC0C0C0), // Silver
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkSlate,
                        ),
                      ),
                      subtitle: Text(
                        '$grade • $tier',
                        style: const TextStyle(fontSize: 14, color: lightGrey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Progress bar
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: currentXP / maxXP,
                          backgroundColor: progressBg,
                          valueColor: const AlwaysStoppedAnimation(wechatGreen),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$currentXP / $maxXP XP',
                          style: const TextStyle(
                            fontSize: 12,
                            color: lightGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section B: Stats Row
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(
                      totalQuestions.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                      '刷题总数',
                      darkSlate,
                      lightGrey,
                    ),
                    Container(width: 1, height: 40, color: progressBg),
                    _buildStatColumn(
                      '${(accuracy * 100).toInt()}%',
                      '正确率',
                      darkSlate,
                      lightGrey,
                    ),
                    Container(width: 1, height: 40, color: progressBg),
                    _buildStatColumn(focusTime, '专注时长', darkSlate, lightGrey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section C: Brain Map (Radar Chart)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '能力雷达',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkSlate,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 250,
                      child: AnimatedBuilder(
                        animation: _radarAnimation,
                        builder: (context, child) {
                          return RadarChart(
                            RadarChartData(
                              dataSets: [
                                RadarDataSet(
                                  dataEntries: skillLevels
                                      .map(
                                        (v) => RadarEntry(
                                          value: v * _radarAnimation.value,
                                        ),
                                      )
                                      .toList(),
                                  borderColor: wechatGreen,
                                  fillColor: wechatGreen.withOpacity(0.2),
                                  entryRadius: 3,
                                  borderWidth: 2,
                                ),
                              ],
                              radarBackgroundColor: Colors.transparent,
                              borderData: FlBorderData(show: false),
                              radarBorderData: const BorderSide(
                                color: lightGrey,
                                width: 1,
                              ),
                              titlePositionPercentageOffset: 0.15,
                              getTitle: (index, angle) {
                                return RadarChartTitle(
                                  text: skillLabels[index],
                                  angle: angle,
                                );
                              },
                              titleTextStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: darkSlate,
                              ),
                              tickCount: 5,
                              ticksTextStyle: const TextStyle(
                                fontSize: 10,
                                color: lightGrey,
                              ),
                              tickBorderData: const BorderSide(
                                color: progressBg,
                                width: 1,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section D: The Vault (Monetization)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                '专属权益',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkSlate,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildVaultItem(
                    icon: Icons.workspace_premium,
                    iconColor: const Color(0xFFFFD700),
                    title: '荣誉证书',
                    subtitle: 'Legend解锁',
                    onTap: _showCertificateDialog,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVaultItem(
                    icon: Icons.analytics,
                    iconColor: const Color(0xFF3B82F6),
                    title: '家长周报',
                    subtitle: 'VIP解锁',
                    onTap: _showParentReportDialog,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Section E: Settings
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.05),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.settings_outlined,
                      color: darkSlate,
                    ),
                    title: const Text('设置'),
                    trailing: const Icon(Icons.chevron_right, color: lightGrey),
                    onTap: _onSettings,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                    title: const Text(
                      '退出登录',
                      style: TextStyle(color: Color(0xFFEF4444)),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: lightGrey),
                    onTap: _onLogout,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String value,
    String label,
    Color valueColor,
    Color labelColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
      ],
    );
  }

  Widget _buildVaultItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 32, color: iconColor),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            // Lock overlay
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
