import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AppProfilePage extends StatefulWidget {
  const AppProfilePage({Key? key}) : super(key: key);

  @override
  State<AppProfilePage> createState() => _AppProfilePageState();
}

class _AppProfilePageState extends State<AppProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radarAnim;

  final int xp = 4200;
  final int xpMax = 5000;
  final String username = 'Feihan';
  final List<double> radarData = [
    7,
    6,
    8,
    5,
    9,
  ]; // Algebra, Geometry, Physics, Chem, Logic
  final List<String> radarLabels = [
    'Algebra',
    'Geometry',
    'Physics',
    'Chem',
    'Logic',
  ];
  final int streak = 7;
  final int activeDay = DateTime.now().weekday % 7;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _radarAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showVipToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('升级VIP解锁家长报告！'),
        backgroundColor: Color(0xFF358373),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header: Identity Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF358373), Color(0xFF2E6B5E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 34,
                      backgroundImage: AssetImage(
                        'assets/images/guide/avatar.png',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      S.of(context).currentRank,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // XP Bar
                  Stack(
                    children: [
                      Container(
                        height: 18,
                        width: 220,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        height: 18,
                        width: 220 * (xp / xpMax),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB9E4D4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            '$xp / $xpMax XP',
                            style: const TextStyle(
                              color: Color(0xFF358373),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // 2. Brain Map (Radar Chart)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 12,
                  ),
                  child: Column(
                    children: [
                      Text(
                        S.of(context).brainMap,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF358373),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: AnimatedBuilder(
                          animation: _radarAnim,
                          builder: (context, child) {
                            return RadarChart(
                              RadarChartData(
                                dataSets: [
                                  RadarDataSet(
                                    dataEntries: radarData
                                        .map(
                                          (v) => RadarEntry(
                                            value: v * _radarAnim.value,
                                          ),
                                        )
                                        .toList(),
                                    borderColor: const Color(0xFF358373),
                                    fillColor: const Color(
                                      0xFF358373,
                                    ).withOpacity(0.2),
                                    entryRadius: 3,
                                    borderWidth: 2.5,
                                  ),
                                ],
                                radarBackgroundColor: Colors.transparent,
                                tickCount: 5,
                                ticksTextStyle: const TextStyle(
                                  color: Color(0xFF64748B),
                                ),
                                getTitle: (idx, angle) => RadarChartTitle(
                                  text: radarLabels[idx],
                                  angle: angle,
                                ),
                                titleTextStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF358373),
                                ),
                                gridBorderData: const BorderSide(
                                  color: Color(0xFF358373),
                                  width: 1.2,
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
            ),
            const SizedBox(height: 28),
            // 3. Streak Strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 12,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '7 Day Streak! Keep it up!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF358373),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(7, (i) {
                          final isActive = i == activeDay;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive
                                    ? const Color(0xFFFFB86B)
                                    : Colors.white,
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFFFB86B,
                                          ).withOpacity(0.5),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : [],
                                border: Border.all(
                                  color: isActive
                                      ? const Color(0xFFFFB86B)
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: isActive
                                  ? const Icon(
                                      Icons.local_fire_department,
                                      color: Colors.white,
                                      size: 22,
                                    )
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            // 4. Parent Report
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description,
                        color: Color(0xFFFFD700),
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              S.of(context).weeklyReport,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF358373),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              S.of(context).parentAnalysis,
                              style: const TextStyle(color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _showVipToast,
                        child: const Icon(
                          Icons.lock,
                          color: Color(0xFFFFD700),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            // 5. Settings Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.workspace_premium,
                        color: Color(0xFF358373),
                      ),
                      title: Text(S.of(context).mySubscription),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.notifications,
                        color: Color(0xFF358373),
                      ),
                      title: Text(S.of(context).notificationSettings),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Color(0xFF358373),
                      ),
                      title: Text(S.of(context).logout),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
