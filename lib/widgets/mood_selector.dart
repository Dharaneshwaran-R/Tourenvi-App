import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MoodSelector extends StatelessWidget {
  final List<String> selectedMoods;
  final ValueChanged<List<String>> onChanged;

  const MoodSelector({
    super.key,
    required this.selectedMoods,
    required this.onChanged,
  });

  static const List<Map<String, String>> moods = [
    {'label': 'Beach', 'emoji': '🏖️'},
    {'label': 'Trek', 'emoji': '🥾'},
    {'label': 'Nature', 'emoji': '🌿'},
    {'label': 'Heritage', 'emoji': '🏛️'},
    {'label': 'Food', 'emoji': '🍜'},
    {'label': 'Pilgrim', 'emoji': '🛕'},
    {'label': 'Wildlife', 'emoji': '🦁'},
    {'label': 'Romantic', 'emoji': '💕'},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: moods.map((mood) {
        final isSelected = selectedMoods.contains(mood['label']);
        return GestureDetector(
          onTap: () {
            final updated = List<String>.from(selectedMoods);
            if (isSelected) {
              updated.remove(mood['label']);
            } else {
              updated.add(mood['label']!);
            }
            onChanged(updated);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.chipActive : AppColors.cardLight,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryGreen.withValues(alpha: 0.6)
                    : AppColors.borderGreen.withValues(alpha: 0.3),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.1), blurRadius: 8, spreadRadius: 1)]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mood['emoji']!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  mood['label']!,
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryGreen : Colors.white,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 14),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
