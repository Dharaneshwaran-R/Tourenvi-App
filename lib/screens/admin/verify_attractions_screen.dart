import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class VerifyAttractionsScreen extends StatefulWidget {
  const VerifyAttractionsScreen({super.key});

  @override
  State<VerifyAttractionsScreen> createState() => _VerifyAttractionsScreenState();
}

class _VerifyAttractionsScreenState extends State<VerifyAttractionsScreen> {
  // Simulated pending attractions data
  final List<Map<String, dynamic>> _pendingAttractions = [
    {
      'name': 'Hidden Falls',
      'location': 'Coorg, Karnataka',
      'submittedBy': '@priya_travels',
      'category': 'Nature',
      'emoji': '🌊',
      'description': 'A secluded waterfall accessible through a 2km forest trail. Best visited during monsoon season.',
      'timeAgo': '12 min ago',
      'photos': 3,
    },
    {
      'name': 'Bamboo Forest Trail',
      'location': 'Wayanad, Kerala',
      'submittedBy': '@kerala_explorer',
      'category': 'Adventure',
      'emoji': '🎋',
      'description': 'Dense bamboo grove with a well-maintained trail. Perfect for photography and morning walks.',
      'timeAgo': '2h ago',
      'photos': 5,
    },
    {
      'name': 'Ancient Rock Temple',
      'location': 'Hampi, Karnataka',
      'submittedBy': '@heritage_hunter',
      'category': 'Heritage',
      'emoji': '🏛️',
      'description': 'Lesser-known rock-cut temple dating back to 14th century. Beautiful carvings and peaceful surroundings.',
      'timeAgo': '5h ago',
      'photos': 7,
    },
    {
      'name': 'Sunset Point Cliff',
      'location': 'Lonavala, Maharashtra',
      'submittedBy': '@wanderlust_india',
      'category': 'Nature',
      'emoji': '🌅',
      'description': 'Panoramic view of the valley. Extremely popular during sunset hours. Moderate trek required.',
      'timeAgo': '8h ago',
      'photos': 4,
    },
    {
      'name': 'Street Food Alley',
      'location': 'Chandni Chowk, Delhi',
      'submittedBy': '@foodie_traveler',
      'category': 'Food',
      'emoji': '🍜',
      'description': 'A hidden lane with the best paranthas and jalebis. Open from 6 AM to midnight.',
      'timeAgo': '1d ago',
      'photos': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verify Attractions',
          style: GoogleFonts.syne(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${_pendingAttractions.length} pending',
                style: const TextStyle(
                  color: AppColors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _pendingAttractions.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded,
                      color: AppColors.primaryGreen.withValues(alpha: 0.3), size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'All caught up!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'No pending attractions to review',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingAttractions.length,
              itemBuilder: (context, index) {
                final item = _pendingAttractions[index];
                return _AttractionReviewCard(
                  data: item,
                  onApprove: () {
                    setState(() => _pendingAttractions.removeAt(index));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ ${item['name']} approved'),
                        backgroundColor: AppColors.darkGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  onReject: () {
                    setState(() => _pendingAttractions.removeAt(index));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ ${item['name']} rejected'),
                        backgroundColor: AppColors.card,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _AttractionReviewCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _AttractionReviewCard({
    required this.data,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(data['emoji'], style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data['location'],
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.chipActive,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data['category'],
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Description
          Text(
            data['description'],
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),

          // Meta row
          Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.textMuted, size: 14),
              const SizedBox(width: 4),
              Text(
                data['submittedBy'],
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(width: 16),
              Icon(Icons.photo_library_outlined, color: AppColors.textMuted, size: 14),
              const SizedBox(width: 4),
              Text(
                '${data['photos']} photos',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const Spacer(),
              Text(
                data['timeAgo'],
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: AppColors.danger.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
