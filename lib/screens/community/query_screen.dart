import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class QueryScreen extends StatefulWidget {
  const QueryScreen({super.key});

  @override
  State<QueryScreen> createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Ask Community / Support', style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
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
                  color: const Color(0xFF60A5FA).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.forum_rounded, color: Color(0xFF60A5FA)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Have a specific question about road conditions, local weather, or trip planning? Ask here and get help from our support team or verified locals.',
                        style: TextStyle(color: const Color(0xFF60A5FA).withValues(alpha: 0.9), fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              
              const Text('SUBJECT', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              const SizedBox(height: 10),
              _buildTextField(hint: 'e.g. Is the Mahabalipuram route safe at night?'),

              const SizedBox(height: 24),
              const Text('DETAILS', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              const SizedBox(height: 10),
              _buildTextField(hint: 'Explain your concern or question clearly...', maxLines: 6),
              
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF60A5FA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Query submitted to support queue!'),
                        backgroundColor: const Color(0xFF60A5FA),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Post Query', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, int maxLines = 1}) {
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
        ),
      ),
    );
  }
}
