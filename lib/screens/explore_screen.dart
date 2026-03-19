import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = [
    'All',
    'Beaches',
    'Hills',
    'Heritage',
    'Under ₹500',
  ];

  final List<_ExplorePlace> _places = [
    _ExplorePlace(
      name: 'Mahabalipuram Beach',
      description:
          'UNESCO heritage site with rock temples and pristine beach. Best for history + nature lovers.',
      emoji: '🏖️',
      tag: 'Eco pick',
      category: 'Beaches',
    ),
    _ExplorePlace(
      name: 'Pondicherry Promenade',
      description:
          'French colonial streets, cafes, and beach promenade. Perfect weekend escape.',
      emoji: '🌊',
      tag: null,
      category: 'Beaches',
    ),
    _ExplorePlace(
      name: 'Yercaud Hills',
      description:
          'Coffee plantations and cool climate. Ideal eco-drive with scenic ghat roads.',
      emoji: '⛰️',
      tag: null,
      category: 'Hills',
    ),
    _ExplorePlace(
      name: 'Thanjavur Big Temple',
      description:
          'Chola-era architectural marvel. UNESCO World Heritage Site with thousand-year history.',
      emoji: '🏛️',
      tag: 'Heritage',
      category: 'Heritage',
    ),
    _ExplorePlace(
      name: 'Kodaikanal',
      description:
          'Princess of hill stations. Lakes, forests, and misty viewpoints at 7,000 ft.',
      emoji: '🌿',
      tag: null,
      category: 'Hills',
    ),
  ];

  List<_ExplorePlace> get _filteredPlaces {
    if (_selectedFilter == 0) return _places;
    final filterLabel = _filters[_selectedFilter];
    if (filterLabel == 'Under ₹500') return _places.take(2).toList();
    return _places.where((p) => p.category == filterLabel).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Explore',
                style: GoogleFonts.syne(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // AI Badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.chipActive,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'AI-powered suggestions',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filter Chips
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                itemBuilder: (context, i) {
                  final active = i == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.chipActive
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active
                                ? AppColors.primaryGreen.withOpacity(0.5)
                                : AppColors.borderGreen.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          _filters[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? AppColors.primaryGreen
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Place cards list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredPlaces.length,
                itemBuilder: (context, i) {
                  final place = _filteredPlaces[i];
                  return _ExplorePlaceCard(place: place);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplorePlaceCard extends StatelessWidget {
  final _ExplorePlace place;

  const _ExplorePlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag + Emoji row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (place.tag != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    place.tag!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
          Center(
            child: Text(place.emoji, style: const TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 14),
          Text(
            place.name,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            place.description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplorePlace {
  final String name;
  final String description;
  final String emoji;
  final String? tag;
  final String category;

  _ExplorePlace({
    required this.name,
    required this.description,
    required this.emoji,
    required this.tag,
    required this.category,
  });
}
