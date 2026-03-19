import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CostBreakdownScreen extends StatefulWidget {
  const CostBreakdownScreen({super.key});

  @override
  State<CostBreakdownScreen> createState() => _CostBreakdownScreenState();
}

class _CostBreakdownScreenState extends State<CostBreakdownScreen> {
  double _fuelPrice = 102;

  double get _fuelCost {
    // 362 km / 18 km/l * price per litre
    return (362 / 18) * _fuelPrice;
  }

  double get _tollCost => 360;

  double get _totalCost => _fuelCost + _tollCost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button + title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.borderGreen.withOpacity(0.3),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Cost Breakdown',
                style: GoogleFonts.syne(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Total Cost Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.15),
                      AppColors.primaryGreen.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.25),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total estimated cost',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '₹ ${_totalCost.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      style: GoogleFonts.syne(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Chennai → Yercaud · 362 km round trip',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Fuel cost card
              _buildCostCard(
                icon: Icons.local_gas_station_rounded,
                iconColor: AppColors.orange,
                title: 'Fuel cost',
                subtitle: '362 km ÷ 18 km/l × ₹${_fuelPrice.round()}',
                amount: '₹ ${_fuelCost.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                amountColor: Colors.white,
              ),
              const SizedBox(height: 12),

              // Tolls card
              _buildCostCard(
                icon: Icons.toll_rounded,
                iconColor: Colors.blueAccent,
                title: 'Toll charges',
                subtitle: '3 toll plazas detected',
                amount: '₹ ${_tollCost.round()}',
                amountColor: Colors.white,
              ),
              const SizedBox(height: 12),

              // CO2 saved card
              _buildCostCard(
                icon: Icons.eco_rounded,
                iconColor: AppColors.primaryGreen,
                title: 'CO₂ saved vs fastest',
                subtitle: 'Eco route selected',
                amount: '2.4 kg',
                amountColor: AppColors.primaryGreen,
              ),
              const SizedBox(height: 24),

              // Fuel Price Slider
              Container(
                width: double.infinity,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Fuel price per litre',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '₹${_fuelPrice.round()}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 6,
                        activeTrackColor: AppColors.primaryGreen,
                        inactiveTrackColor: AppColors.borderGreen.withOpacity(0.3),
                        thumbColor: AppColors.orange,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                        overlayColor: AppColors.primaryGreen.withOpacity(0.1),
                      ),
                      child: Slider(
                        value: _fuelPrice,
                        min: 80,
                        max: 130,
                        onChanged: (v) => setState(() => _fuelPrice = v),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // "Plan this trip" button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primaryGreen,
                        content: const Text(
                          'Trip planned! 🎉',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w700),
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Plan this trip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
