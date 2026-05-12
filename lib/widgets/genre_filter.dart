import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GenreFilter extends StatelessWidget {
  final String selectedGenre;
  final ValueChanged<String> onChanged;

  const GenreFilter({
    super.key,
    required this.selectedGenre,
    required this.onChanged,
  });

  static const List<Map<String, dynamic>> genres = [
    {'label': 'All', 'icon': Icons.grid_view_rounded},
    {'label': 'Adventure', 'icon': Icons.terrain_rounded},
    {'label': 'Romantic', 'icon': Icons.favorite_rounded},
    {'label': 'Cultural', 'icon': Icons.museum_rounded},
    {'label': 'Spiritual', 'icon': Icons.self_improvement_rounded},
    {'label': 'Wildlife', 'icon': Icons.pets_rounded},
    {'label': 'Budget', 'icon': Icons.savings_rounded},
    {'label': 'Luxury', 'icon': Icons.diamond_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = selectedGenre == genre['label'];
          return GestureDetector(
            onTap: () => onChanged(genre['label']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.borderGreen.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    genre['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.black : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    genre['label'],
                    style: TextStyle(
                      color: isSelected ? Colors.black : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
