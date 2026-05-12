import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/attraction_card.dart';
import '../attractions/attraction_detail_screen.dart';
import '../community/query_screen.dart';

class DestinationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const DestinationDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Mock local attractions for this destination
    final List<Map<String, dynamic>> localAttractions = [
      {
        'name': 'Pine Forest Reserve',
        'location': 'Near main city, ${data['name']}',
        'category': 'Nature',
        'rating': 4.7,
        'distance': 4.2,
      },
      {
        'name': 'Historical Fort View',
        'location': 'Old Town, ${data['name']}',
        'category': 'Heritage',
        'rating': 4.4,
        'distance': 1.5,
      },
      {
        'name': 'Lake Boating Point',
        'location': 'Lake Road, ${data['name']}',
        'category': 'Adventure',
        'rating': 4.6,
        'distance': 6.8,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.background,
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.share_rounded)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      data['name'] == 'Goa' ? 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80' : 
                      'https://images.unsplash.com/photo-1628120611417-6f600f919bf6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.background.withValues(alpha: 0.9)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Block
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data['name'],
                        style: GoogleFonts.syne(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          data['budget'] ?? 'Unknown',
                          style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${data['state']} · Best time to visit: ${data['season'] ?? 'Anytime'}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Weather & Safety Row
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          icon: Icons.cloud_outlined,
                          label: 'Weather',
                          value: '22°C',
                          color: Colors.lightBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          icon: Icons.shield_outlined,
                          label: 'Safety Score',
                          value: '92/100',
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  
                  // Top Attractions Carousel
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       const Text('TOP ATTRACTIONS', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                       TextButton(
                         onPressed: () {},
                         child: const Text('View map', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12)),
                       )
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: localAttractions.length,
                      itemBuilder: (ctx, i) {
                        return AttractionCard(
                          data: localAttractions[i],
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => AttractionDetailScreen(data: localAttractions[i])
                            ));
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),
                  
                  // Need Help Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.help_center_rounded, color: AppColors.primaryGreen, size: 36),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Planning struggles?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              const Text('Ask the community about road conditions or itineraries.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primaryGreen),
                          onPressed: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => const QueryScreen()));
                          },
                        ),
                      ],
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

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBox({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
