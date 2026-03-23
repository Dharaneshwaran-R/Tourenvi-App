import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../community/report_screen.dart';

class AttractionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const AttractionDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Elegant Header with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border_rounded, size: 20, color: Colors.white),
                  onPressed: () {},
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 8, 12, 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 20, color: Colors.white),
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'share', child: Text('Share Attraction', style: TextStyle(color: Colors.white))),
                    const PopupMenuItem(value: 'report', child: Text('Report Issue', style: TextStyle(color: AppColors.danger))),
                  ],
                  onSelected: (val) {
                    if (val == 'report') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen()));
                    }
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1596422846543-75c6ff416d23?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.8),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          data['category'] ?? 'Nature',
                          style: const TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (data['verified'] == true) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF60A5FA).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, color: Color(0xFF60A5FA), size: 12),
                              SizedBox(width: 4),
                              Text('Community Verified', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 11, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title & Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          data['name'] ?? 'Scenic Mountain View',
                          style: GoogleFonts.syne(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.orange, size: 20),
                            const SizedBox(height: 2),
                            Text(
                              '${data['rating'] ?? 4.8}',
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.textMuted, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          data['location'] ?? 'Western Ghats, Kerala',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Map Preview Placeholder
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3)),
                      image: const DecorationImage(
                        image: NetworkImage('https://static.vecteezy.com/system/resources/previews/001/222/688/non_2x/map-with-gps-pin-vector.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_rounded, color: AppColors.primaryGreen, size: 18),
                            SizedBox(width: 8),
                            Text('Tap to navigate (12 km away)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text('ABOUT', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  const SizedBox(height: 10),
                  Text(
                    data['description'] ?? 'A breathtaking viewpoint hidden away from the main tourist trail. Accessible via a short 2km hike through dense pine forests. Best visited during sunrise for an unforgettable cloud inversion effect. Note: No food stalls available on the top.',
                    style: const TextStyle(color: Colors.white, height: 1.6, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // Community Review Highlight
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                              child: const Text('R', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            const Text('Top Review by Rahul', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            const Spacer(),
                            const Text('2 weeks ago', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '"Incredible spot! Bring your own water and start early. The trail gets slippery in the rain but the view is worth it."',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Added to trip itinerary!'), backgroundColor: AppColors.primaryGreen)
                         );
                      },
                      child: const Text('Add to Itinerary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
