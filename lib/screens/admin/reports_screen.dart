import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<Map<String, dynamic>> _reports = [
    {
      'type': 'Inappropriate Content', 'target': 'Review on Jaipur Palace',
      'reporter': '@travel_guru', 'severity': 'high', 'time': '1h ago',
      'description': 'Contains offensive language and false claims.',
    },
    {
      'type': 'Spam', 'target': 'Attraction: Best Hotel Deals',
      'reporter': '@priya_sharma', 'severity': 'medium', 'time': '3h ago',
      'description': 'Promotional listing disguised as a tourist attraction.',
    },
    {
      'type': 'Safety Concern', 'target': 'Mountain Trail, Kodaikanal',
      'reporter': '@hiker_ravi', 'severity': 'high', 'time': '5h ago',
      'description': 'Landslide has made this trail dangerous. Needs warning.',
    },
    {
      'type': 'Incorrect Info', 'target': 'Meenakshi Temple Timing',
      'reporter': '@temple_visitor', 'severity': 'low', 'time': '1d ago',
      'description': 'Listed timing is wrong. Closes at 9:30 PM, not 10 PM.',
    },
    {
      'type': 'Safety Concern', 'target': 'Night Market, Goa',
      'reporter': '@solo_wanderer', 'severity': 'medium', 'time': '1d ago',
      'description': 'Multiple pickpocketing instances reported by tourists.',
    },
  ];

  Color _sevColor(String s) =>
      s == 'high' ? AppColors.danger : s == 'medium' ? AppColors.orange : AppColors.textSecondary;

  IconData _typeIcon(String t) {
    if (t.contains('Inappropriate')) return Icons.warning_rounded;
    if (t.contains('Spam')) return Icons.report_rounded;
    if (t.contains('Safety')) return Icons.health_and_safety_rounded;
    return Icons.info_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Reports & Flags', style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length,
        itemBuilder: (context, i) {
          final r = _reports[i];
          final c = _sevColor(r['severity']);
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card, borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.withValues(alpha: 0.2)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 38, height: 38,
                  decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Icon(_typeIcon(r['type']), color: c, size: 20))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r['type'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(r['target'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(r['severity'].toString().toUpperCase(), style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w800))),
              ]),
              const SizedBox(height: 14),
              Text(r['description'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
              const SizedBox(height: 10),
              Row(children: [
                Text(r['reporter'], style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const Spacer(),
                Text(r['time'], style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: SizedBox(height: 38, child: OutlinedButton(
                  onPressed: () { setState(() => _reports.removeAt(i)); },
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.borderGreen.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Dismiss', style: TextStyle(fontSize: 13))))),
                const SizedBox(width: 12),
                Expanded(child: SizedBox(height: 38, child: ElevatedButton(
                  onPressed: () { setState(() => _reports.removeAt(i)); },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.black, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Resolve', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700))))),
              ]),
            ]),
          );
        },
      ),
    );
  }
}
