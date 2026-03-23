import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class AddAttractionScreen extends StatefulWidget {
  const AddAttractionScreen({super.key});

  @override
  State<AddAttractionScreen> createState() => _AddAttractionScreenState();
}

class _AddAttractionScreenState extends State<AddAttractionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _category = 'Nature';
  
  final List<String> _categories = [
    'Nature', 'Heritage', 'Adventure', 'Pilgrim', 'Food', 'Culture', 'Wildlife'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Submit Hidden Gem',
          style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your submission will be reviewed by admins before appearing on the map to ensure quality and safety.',
                        style: TextStyle(color: AppColors.orange.withValues(alpha: 0.9), fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              _buildLabel('ATTRACTION NAME'),
              _buildTextField(hint: 'e.g. Secret Waterfall Trail'),

              const SizedBox(height: 20),
              _buildLabel('LOCATION / GPS'),
              _buildTextField(
                hint: 'Drop pin or enter address',
                icon: Icons.my_location_rounded,
              ),

              const SizedBox(height: 20),
              _buildLabel('CATEGORY'),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: _categories.map((cat) {
                  final isSelected = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryGreen : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryGreen : AppColors.borderGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              _buildLabel('DESCRIPTION'),
              _buildTextField(
                hint: 'What makes this place special? Any accessibility info or best time to visit?',
                maxLines: 4,
              ),

              const SizedBox(height: 24),
              _buildLabel('PHOTOS (UP TO 5)'),
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.5), style: BorderStyle.dash),
                    ),
                    child: const Center(
                      child: Icon(Icons.add_a_photo_rounded, color: AppColors.textSecondary, size: 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Add clear, original photos.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
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
                    // Submit logic
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Attraction submitted for review!'),
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Submit for Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, int maxLines = 1, IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3)),
      ),
      child: TextFormField(
        style: const TextStyle(color: Colors.white, fontSize: 14),
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          suffixIcon: icon != null ? Icon(icon, color: AppColors.primaryGreen, size: 20) : null,
        ),
      ),
    );
  }
}
