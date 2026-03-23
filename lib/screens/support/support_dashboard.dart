import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class SupportDashboard extends StatefulWidget {
  const SupportDashboard({super.key});

  @override
  State<SupportDashboard> createState() => _SupportDashboardState();
}

class _SupportDashboardState extends State<SupportDashboard> {
  String _filter = 'Open';

  final List<Map<String, dynamic>> _tickets = [
    {
      'id': 'TKT-1042', 'subject': 'Cannot find my saved trip',
      'user': 'Priya S.', 'priority': 'medium', 'status': 'open', 'time': '14 min ago',
      'messages': 3,
    },
    {
      'id': 'TKT-1041', 'subject': 'Fuel cost estimate seems too high',
      'user': 'Rahul K.', 'priority': 'low', 'status': 'open', 'time': '1h ago',
      'messages': 5,
    },
    {
      'id': 'TKT-1040', 'subject': 'App crashes when selecting vehicle',
      'user': 'Arun P.', 'priority': 'high', 'status': 'open', 'time': '2h ago',
      'messages': 2,
    },
    {
      'id': 'TKT-1038', 'subject': 'Wrong toll amount shown for NH44',
      'user': 'Deepa N.', 'priority': 'medium', 'status': 'open', 'time': '5h ago',
      'messages': 4,
    },
    {
      'id': 'TKT-1035', 'subject': 'How to become a local guide?',
      'user': 'Meena K.', 'priority': 'low', 'status': 'resolved', 'time': '1d ago',
      'messages': 6,
    },
    {
      'id': 'TKT-1030', 'subject': 'Hotel suggestion was closed permanently',
      'user': 'Vikram R.', 'priority': 'medium', 'status': 'resolved', 'time': '2d ago',
      'messages': 8,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'All') return _tickets;
    return _tickets.where((t) => t['status'] == _filter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final openCount = _tickets.where((t) => t['status'] == 'open').length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Support Panel', style: GoogleFonts.syne(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Welcome, ${user?.name ?? "Agent"}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA78BFA).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA78BFA).withValues(alpha: 0.3)),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.support_agent_rounded, color: Color(0xFFA78BFA), size: 16),
                      SizedBox(width: 6),
                      Text('Support', style: TextStyle(color: Color(0xFFA78BFA), fontSize: 12, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                _MiniStat(value: '$openCount', label: 'Open', color: AppColors.orange),
                const SizedBox(width: 12),
                _MiniStat(value: '${_tickets.length}', label: 'Total', color: AppColors.primaryGreen),
                const SizedBox(width: 12),
                _MiniStat(value: '4.2', label: 'Avg Rating', color: const Color(0xFF60A5FA)),
              ]),
            ),
            const SizedBox(height: 20),

            // Filter tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: ['Open', 'Resolved', 'All'].map((f) {
                final sel = _filter == f;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.chipActive : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? AppColors.primaryGreen.withValues(alpha: 0.5) : AppColors.borderGreen.withValues(alpha: 0.4)),
                    ),
                    child: Text(f, style: TextStyle(color: sel ? AppColors.primaryGreen : AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList()),
            ),
            const SizedBox(height: 14),

            // Tickets list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filtered.length,
                itemBuilder: (context, i) {
                  final t = _filtered[i];
                  final pColor = t['priority'] == 'high' ? AppColors.danger
                      : t['priority'] == 'medium' ? AppColors.orange : AppColors.textSecondary;
                  final isOpen = t['status'] == 'open';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card, borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: pColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                          child: Text(t['priority'].toString().toUpperCase(), style: TextStyle(color: pColor, fontSize: 10, fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 8),
                        Text(t['id'], style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: isOpen ? AppColors.primaryGreen : AppColors.textMuted),
                        ),
                        const SizedBox(width: 6),
                        Text(isOpen ? 'Open' : 'Resolved', style: TextStyle(color: isOpen ? AppColors.primaryGreen : AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 10),
                      Text(t['subject'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Icon(Icons.person_outline, color: AppColors.textMuted, size: 14),
                        const SizedBox(width: 4),
                        Text(t['user'], style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        const SizedBox(width: 14),
                        Icon(Icons.chat_bubble_outline, color: AppColors.textMuted, size: 14),
                        const SizedBox(width: 4),
                        Text('${t['messages']} messages', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        const Spacer(),
                        Text(t['time'], style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ]),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _MiniStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(children: [
        Text(value, style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    ));
  }
}
