import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import 'verify_attractions_screen.dart';
import 'manage_users_screen.dart';
import 'reports_screen.dart';
import 'analytics_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final userName = user?.name ?? 'Admin';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Panel',
                        style: GoogleFonts.syne(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome, $userName',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_rounded, color: AppColors.orange, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Admin',
                          style: TextStyle(
                            color: AppColors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Stats overview
              Row(
                children: [
                  _StatCard(
                    icon: Icons.people_rounded,
                    value: '1,248',
                    label: 'Total Users',
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.map_rounded,
                    value: '856',
                    label: 'Trips Created',
                    color: AppColors.accentGreen,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(
                    icon: Icons.pending_actions_rounded,
                    value: '23',
                    label: 'Pending Reviews',
                    color: AppColors.orange,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.report_problem_rounded,
                    value: '7',
                    label: 'Open Reports',
                    color: AppColors.danger,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Quick Actions
              const Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 14),

              _ActionCard(
                icon: Icons.verified_rounded,
                title: 'Verify Attractions',
                subtitle: '23 pending community submissions',
                badgeCount: 23,
                badgeColor: AppColors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VerifyAttractionsScreen()),
                ),
              ),
              const SizedBox(height: 10),
              _ActionCard(
                icon: Icons.people_alt_rounded,
                title: 'Manage Users',
                subtitle: 'View, edit roles, ban users',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
                ),
              ),
              const SizedBox(height: 10),
              _ActionCard(
                icon: Icons.flag_rounded,
                title: 'Reports & Flags',
                subtitle: '7 unresolved community reports',
                badgeCount: 7,
                badgeColor: AppColors.danger,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportsScreen()),
                ),
              ),
              const SizedBox(height: 10),
              _ActionCard(
                icon: Icons.analytics_rounded,
                title: 'Analytics',
                subtitle: 'User growth, trip trends, revenue',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                ),
              ),
              const SizedBox(height: 28),

              // Recent Activity
              const Text(
                'RECENT ACTIVITY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 14),

              _ActivityItem(
                icon: Icons.location_on_rounded,
                iconColor: AppColors.primaryGreen,
                title: 'New attraction submitted',
                subtitle: 'Hidden Falls, Coorg — by @priya_travels',
                time: '12 min ago',
              ),
              _ActivityItem(
                icon: Icons.person_add_rounded,
                iconColor: AppColors.accentGreen,
                title: 'New user registered',
                subtitle: 'rahul.kumar@gmail.com — End User',
                time: '28 min ago',
              ),
              _ActivityItem(
                icon: Icons.flag_rounded,
                iconColor: AppColors.danger,
                title: 'Content reported',
                subtitle: 'Inappropriate review on Jaipur Palace',
                time: '1h ago',
              ),
              _ActivityItem(
                icon: Icons.verified_rounded,
                iconColor: AppColors.primaryGreen,
                title: 'Attraction approved',
                subtitle: 'Bamboo Forest Trail, Wayanad',
                time: '2h ago',
              ),
              _ActivityItem(
                icon: Icons.tour_rounded,
                iconColor: AppColors.orange,
                title: 'New guide registered',
                subtitle: 'Meena K. — Ooty, Tamil Nadu',
                time: '3h ago',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, color: color, size: 20)),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: GoogleFonts.syne(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int? badgeCount;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badgeCount,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(icon, color: AppColors.primaryGreen, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeCount != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? AppColors.primaryGreen).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      color: badgeColor ?? AppColors.primaryGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ] else
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
