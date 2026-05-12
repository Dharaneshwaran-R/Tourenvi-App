import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Analytics', style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Period selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
            child: Row(children: ['7 Days', '30 Days', '90 Days'].map((p) {
              final sel = p == '30 Days';
              return Expanded(child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppColors.chipActive : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text(p, style: TextStyle(
                  color: sel ? AppColors.primaryGreen : AppColors.textSecondary,
                  fontSize: 13, fontWeight: FontWeight.w600))),
              ));
            }).toList()),
          ),
          const SizedBox(height: 24),

          // Metric cards
          Row(children: [
            _MetricCard(label: 'New Users', value: '342', change: '+18%', isUp: true),
            const SizedBox(width: 12),
            _MetricCard(label: 'Trips Created', value: '189', change: '+24%', isUp: true),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _MetricCard(label: 'Active Guides', value: '28', change: '+6', isUp: true),
            const SizedBox(width: 12),
            _MetricCard(label: 'Avg Trip Cost', value: '₹4.2k', change: '-8%', isUp: false),
          ]),
          const SizedBox(height: 28),

          // Bar chart placeholder
          const Text('TRIPS BY CATEGORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.5)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3))),
            child: Column(children: [
              _BarRow('Beach', 0.72, '34%'),
              _BarRow('Hill Station', 0.55, '26%'),
              _BarRow('Heritage', 0.38, '18%'),
              _BarRow('Adventure', 0.28, '13%'),
              _BarRow('Pilgrimage', 0.19, '9%'),
            ]),
          ),
          const SizedBox(height: 28),

          // Top destinations
          const Text('TOP DESTINATIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.5)),
          const SizedBox(height: 14),
          ...[
            {'rank': '1', 'name': 'Goa', 'trips': '89', 'emoji': '🏖️'},
            {'rank': '2', 'name': 'Ooty', 'trips': '67', 'emoji': '⛰️'},
            {'rank': '3', 'name': 'Jaipur', 'trips': '52', 'emoji': '🏰'},
            {'rank': '4', 'name': 'Pondicherry', 'trips': '48', 'emoji': '🌊'},
            {'rank': '5', 'name': 'Munnar', 'trips': '41', 'emoji': '🍃'},
          ].map((d) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.2))),
            child: Row(children: [
              SizedBox(width: 24, child: Text(d['rank']!, style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w700))),
              Text(d['emoji']!, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(child: Text(d['name']!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
              Text('${d['trips']} trips', style: const TextStyle(color: AppColors.primaryGreen, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          )),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label, value, change;
  final bool isUp;
  const _MetricCard({required this.label, required this.value, required this.change, required this.isUp});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 6),
        Row(children: [
          Icon(isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: isUp ? AppColors.primaryGreen : AppColors.danger, size: 16),
          const SizedBox(width: 4),
          Text(change, style: TextStyle(color: isUp ? AppColors.primaryGreen : AppColors.danger, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ]),
    ));
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double pct;
  final String pctLabel;
  const _BarRow(this.label, this.pct, this.pctLabel);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
      Expanded(child: Container(height: 8, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(4)),
        child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: pct,
          child: Container(decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(colors: [AppColors.primaryGreen, AppColors.accentGreen])))))),
      const SizedBox(width: 12),
      SizedBox(width: 30, child: Text(pctLabel, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
    ]));
  }
}
