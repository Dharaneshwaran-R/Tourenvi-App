import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/toll_api_service.dart';

class TollBreakdownScreen extends StatefulWidget {
  final String origin;
  final String destination;
  final String vehicleDisplay;

  const TollBreakdownScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.vehicleDisplay,
  });

  @override
  State<TollBreakdownScreen> createState() => _TollBreakdownScreenState();
}

class _TollBreakdownScreenState extends State<TollBreakdownScreen> {
  bool _isLoading = true;
  TollResult? _result;
  bool _isRoundTrip = false;

  @override
  void initState() {
    super.initState();
    _fetchTolls();
  }

  Future<void> _fetchTolls() async {
    setState(() => _isLoading = true);
    try {
      final res = await TollApiService().getTollBreakdown(
        origin: widget.origin,
        destination: widget.destination,
        vehicleType: widget.vehicleDisplay,
      );
      if (mounted) {
        setState(() {
          _result = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
          'Toll Breakdown',
          style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : _result == null
              ? const Center(child: Text('Could not fetch toll data.', style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total Toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isRoundTrip = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isRoundTrip ? AppColors.chipActive : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'One Way',
                                      style: TextStyle(
                                        color: !_isRoundTrip ? AppColors.primaryGreen : AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isRoundTrip = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isRoundTrip ? AppColors.chipActive : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Round Trip',
                                      style: TextStyle(
                                        color: _isRoundTrip ? AppColors.primaryGreen : AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Grand Total Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'TOTAL TOLL COST',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${(_isRoundTrip ? _result!.roundTripTotal : _result!.singleTripTotal).toStringAsFixed(0)}',
                              style: GoogleFonts.syne(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            if (_isRoundTrip && _result!.etcDiscount > 0) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Includes ₹${_result!.etcDiscount.round()} FASTag return discount',
                                  style: const TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_result!.plazas.isEmpty)
                         Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Icon(Icons.check_circle_outline, size: 48, color: AppColors.primaryGreen),
                                const SizedBox(height: 12),
                                Text(
                                  'No Tolls on this route!',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Enjoy a toll-free journey.',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        Text(
                          'TOLL PLAZAS (${_result!.plazas.length})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._result!.plazas.map((p) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.receipt_long_rounded, color: AppColors.textSecondary, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '~${p.kmFromOrigin} km from origin',
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${_isRoundTrip ? (p.singleCost + p.returnCost) : p.singleCost}',
                                    style: const TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],

                      if (_result!.tollFreeAlternativeAvailable) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.alt_route_rounded, color: AppColors.orange),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Toll-Free Route Available', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('There is an alternate route which requires +45 mins of travel.', style: TextStyle(color: AppColors.orange.withValues(alpha: 0.8), fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }
}
