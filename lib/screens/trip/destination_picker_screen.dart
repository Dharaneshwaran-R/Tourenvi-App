import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mood_selector.dart';
import '../../widgets/genre_filter.dart';

class DestinationPickerScreen extends StatefulWidget {
  final List<dynamic> tourismData;
  final Function(String destination) onSelected;

  const DestinationPickerScreen({
    super.key,
    required this.tourismData,
    required this.onSelected,
  });

  @override
  State<DestinationPickerScreen> createState() => _DestinationPickerScreenState();
}

class _DestinationPickerScreenState extends State<DestinationPickerScreen> {
  String _searchQuery = '';
  List<String> _selectedMoods = [];
  String _selectedGenre = 'All';
  String _budgetTier = 'All';
  String _selectedSeason = 'All';

  final List<String> _budgetTiers = ['All', 'Budget', 'Mid-Range', 'Luxury'];
  final List<String> _seasons = ['All', 'Summer', 'Monsoon', 'Winter', 'Spring'];

  // Simulated destination data
  final List<Map<String, dynamic>> _destinations = [
    {'name': 'Goa', 'state': 'Goa', 'emoji': '🏖️', 'moods': ['Beach', 'Food', 'Romantic'], 'genre': 'Romantic', 'budget': 'Mid-Range', 'season': 'Winter', 'distance': '590 km', 'rating': 4.5, 'bestFor': 'Couples & Groups'},
    {'name': 'Ooty', 'state': 'Tamil Nadu', 'emoji': '⛰️', 'moods': ['Nature', 'Trek', 'Romantic'], 'genre': 'Adventure', 'budget': 'Budget', 'season': 'Summer', 'distance': '560 km', 'rating': 4.3, 'bestFor': 'Families'},
    {'name': 'Jaipur', 'state': 'Rajasthan', 'emoji': '🏰', 'moods': ['Heritage', 'Food'], 'genre': 'Cultural', 'budget': 'Mid-Range', 'season': 'Winter', 'distance': '2,180 km', 'rating': 4.6, 'bestFor': 'Solo & Cultural'},
    {'name': 'Munnar', 'state': 'Kerala', 'emoji': '🍃', 'moods': ['Nature', 'Trek', 'Romantic'], 'genre': 'Romantic', 'budget': 'Budget', 'season': 'Monsoon', 'distance': '540 km', 'rating': 4.4, 'bestFor': 'Couples'},
    {'name': 'Pondicherry', 'state': 'Tamil Nadu', 'emoji': '🌊', 'moods': ['Beach', 'Food', 'Heritage'], 'genre': 'Cultural', 'budget': 'Budget', 'season': 'Winter', 'distance': '162 km', 'rating': 4.2, 'bestFor': 'Solo & Couples'},
    {'name': 'Rameswaram', 'state': 'Tamil Nadu', 'emoji': '🛕', 'moods': ['Pilgrim', 'Heritage'], 'genre': 'Spiritual', 'budget': 'Budget', 'season': 'Winter', 'distance': '572 km', 'rating': 4.5, 'bestFor': 'Families'},
    {'name': 'Jim Corbett', 'state': 'Uttarakhand', 'emoji': '🦁', 'moods': ['Wildlife', 'Nature'], 'genre': 'Wildlife', 'budget': 'Luxury', 'season': 'Spring', 'distance': '1,800 km', 'rating': 4.7, 'bestFor': 'Adventure Seekers'},
    {'name': 'Manali', 'state': 'Himachal Pradesh', 'emoji': '🏔️', 'moods': ['Trek', 'Nature', 'Romantic'], 'genre': 'Adventure', 'budget': 'Mid-Range', 'season': 'Summer', 'distance': '2,150 km', 'rating': 4.5, 'bestFor': 'Groups & Couples'},
    {'name': 'Varanasi', 'state': 'Uttar Pradesh', 'emoji': '🪔', 'moods': ['Pilgrim', 'Heritage', 'Food'], 'genre': 'Spiritual', 'budget': 'Budget', 'season': 'Winter', 'distance': '1,750 km', 'rating': 4.4, 'bestFor': 'Spiritual Seekers'},
    {'name': 'Udaipur', 'state': 'Rajasthan', 'emoji': '🏯', 'moods': ['Heritage', 'Romantic'], 'genre': 'Luxury', 'budget': 'Luxury', 'season': 'Winter', 'distance': '1,900 km', 'rating': 4.8, 'bestFor': 'Couples'},
    {'name': 'Kodaikanal', 'state': 'Tamil Nadu', 'emoji': '🌲', 'moods': ['Nature', 'Trek'], 'genre': 'Adventure', 'budget': 'Budget', 'season': 'Summer', 'distance': '465 km', 'rating': 4.3, 'bestFor': 'Families & Friends'},
    {'name': 'Alleppey', 'state': 'Kerala', 'emoji': '🛶', 'moods': ['Nature', 'Romantic'], 'genre': 'Romantic', 'budget': 'Mid-Range', 'season': 'Monsoon', 'distance': '640 km', 'rating': 4.6, 'bestFor': 'Couples'},
  ];

  List<Map<String, dynamic>> get _filtered {
    return _destinations.where((d) {
      if (_searchQuery.isNotEmpty && !d['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      if (_selectedMoods.isNotEmpty && !(d['moods'] as List).any((m) => _selectedMoods.contains(m))) return false;
      if (_selectedGenre != 'All' && d['genre'] != _selectedGenre) return false;
      if (_budgetTier != 'All' && d['budget'] != _budgetTier) return false;
      if (_selectedSeason != 'All' && d['season'] != _selectedSeason) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Choose Destination', style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3))),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search destinations...', hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
                  border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Genre filter
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GenreFilter(selectedGenre: _selectedGenre, onChanged: (v) => setState(() => _selectedGenre = v)),
          ),
          const SizedBox(height: 12),

          // Budget + Season row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _DropdownChip(label: 'Budget', value: _budgetTier, options: _budgetTiers,
                onChanged: (v) => setState(() => _budgetTier = v)),
              const SizedBox(width: 10),
              _DropdownChip(label: 'Season', value: _selectedSeason, options: _seasons,
                onChanged: (v) => setState(() => _selectedSeason = v)),
              const Spacer(),
              Text('${results.length} found', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 8),

          // Mood selector (collapsible)
          ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Row(children: [
              const Text('MOOD FILTER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.2)),
              if (_selectedMoods.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text('${_selectedMoods.length}', style: const TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.w700))),
              ],
            ]),
            iconColor: AppColors.textSecondary, collapsedIconColor: AppColors.textSecondary,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: MoodSelector(selectedMoods: _selectedMoods, onChanged: (v) => setState(() => _selectedMoods = v)),
              ),
            ],
          ),

          // Results
          Expanded(
            child: results.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 48),
                    const SizedBox(height: 12),
                    const Text('No destinations match', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text('Try adjusting your filters', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final d = results[i];
                      return _DestinationResultCard(data: d, onTap: () {
                        widget.onSelected(d['name']);
                        Navigator.pop(context);
                      });
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  final String label, value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _DropdownChip({required this.label, required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (ctx) => options.map((o) => PopupMenuItem(value: o,
        child: Text(o, style: TextStyle(color: o == value ? AppColors.primaryGreen : Colors.white, fontSize: 13)))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: value != 'All' ? AppColors.chipActive : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: value != 'All' ? AppColors.primaryGreen.withValues(alpha: 0.4) : AppColors.borderGreen.withValues(alpha: 0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(value == 'All' ? label : value, style: TextStyle(
            color: value != 'All' ? AppColors.primaryGreen : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: value != 'All' ? AppColors.primaryGreen : AppColors.textMuted),
        ]),
      ),
    );
  }
}

class _DestinationResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _DestinationResultCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3))),
        child: Row(children: [
          // Emoji
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(data['emoji'], style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(data['name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
              Row(children: [
                const Icon(Icons.star_rounded, color: AppColors.orange, size: 16),
                const SizedBox(width: 2),
                Text('${data['rating']}', style: const TextStyle(color: AppColors.orange, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ]),
            const SizedBox(height: 3),
            Text('${data['state']} · ${data['distance']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.chipActive, borderRadius: BorderRadius.circular(6)),
                child: Text(data['budget'], style: const TextStyle(color: AppColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.w700))),
              const SizedBox(width: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(6)),
                child: Text(data['bestFor'], style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600))),
            ]),
          ])),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ]),
      ),
    );
  }
}
