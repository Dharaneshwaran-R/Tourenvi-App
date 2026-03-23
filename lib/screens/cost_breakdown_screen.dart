import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'trip/toll_breakdown_screen.dart';
import '../services/toll_api_service.dart';

class CostBreakdownScreen extends StatefulWidget {
  final String origin;
  final String destination;
  final String vehicleDisplay;
  final double vehicleMileage;
  final int memberCount;
  final int distance; // in km

  const CostBreakdownScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.vehicleDisplay,
    required this.vehicleMileage,
    required this.memberCount,
    required this.distance,
  });

  @override
  State<CostBreakdownScreen> createState() => _CostBreakdownScreenState();
}

class _CostBreakdownScreenState extends State<CostBreakdownScreen> {
  double _fuelPrice = 104.0; // Current average in India
  double _estimatedToll = 0.0;
  bool _isFetchingToll = true;
  int _hotelPerNightEst = 2500;
  int _foodPerPersonEst = 800; // per day
  int _days = 3; // default

  @override
  void initState() {
    super.initState();
    _fetchTollEstimate();
  }

  Future<void> _fetchTollEstimate() async {
    try {
      final res = await TollApiService().getTollBreakdown(
        origin: widget.origin,
        destination: widget.destination,
        vehicleType: widget.vehicleDisplay,
      );
      if (mounted) {
        setState(() {
          _estimatedToll = res.singleTripTotal;
          _isFetchingToll = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isFetchingToll = false);
    }
  }

  double get _fuelCost {
    // Distance / Mileage * Fuel Price
    if (widget.vehicleMileage <= 0) return 0;
    return (widget.distance / widget.vehicleMileage) * _fuelPrice;
  }

  double get _hotelCost => _hotelPerNightEst * (_days - 1).toDouble() * (widget.memberCount / 2).ceil();
  double get _foodCost => _foodPerPersonEst * _days * widget.memberCount.toDouble();

  double get _totalCost => _fuelCost + _estimatedToll + _hotelCost + _foodCost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3)),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Cost Breakdown',
                style: GoogleFonts.syne(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
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
                      AppColors.primaryGreen.withValues(alpha: 0.15),
                      AppColors.primaryGreen.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.25)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total estimated cost',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '₹${_totalCost.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      style: GoogleFonts.syne(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Total per person: ₹${(_totalCost / widget.memberCount).round()}',
                        style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _SectionTitle('Trip Variables'),
              Row(
                children: [
                   Expanded(
                    child: _VariableCard(
                      label: 'Trip Duration',
                      value: '$_days Days',
                      icon: Icons.calendar_today,
                      onTap: () {
                         if(_days < 10) setState(() => _days++);
                         else setState(() => _days = 1);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _VariableCard(
                      label: 'Members',
                      value: '${widget.memberCount}',
                      icon: Icons.group_rounded,
                      onTap: () {}, // Passed from previous screen
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Categories Breakdown
              _SectionTitle('Categories'),
              
              // Fuel Category
              _CostItem(
                icon: Icons.local_gas_station,
                title: 'Fuel',
                subtitle: '${widget.distance} km @ ${widget.vehicleMileage} km/l',
                amount: _fuelCost.round(),
                color: AppColors.primaryGreen,
              ),
              // Fuel Slider
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Adjust Fuel Price', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        Text('₹${_fuelPrice.toStringAsFixed(1)} / L', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.primaryGreen,
                        inactiveTrackColor: AppColors.surface,
                        thumbColor: Colors.white,
                        trackHeight: 4,
                        overlayColor: AppColors.primaryGreen.withValues(alpha: 0.2),
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

              // Tolls Category
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TollBreakdownScreen(
                        origin: widget.origin,
                        destination: widget.destination,
                        vehicleDisplay: widget.vehicleDisplay,
                      ),
                    ),
                  );
                },
                child: Container(
                  color: Colors.transparent,
                  child: IgnorePointer(
                    child: _CostItem(
                      icon: Icons.alt_route,
                      title: 'Tolls (FASTag)',
                      subtitle: _isFetchingToll ? 'Fetching estimates...' : 'National & State Highways',
                      amount: _estimatedToll.round(),
                      color: AppColors.orange,
                      hasArrow: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Accommodation Category
              _CostItem(
                icon: Icons.hotel,
                title: 'Accommodation',
                subtitle: '${(_days - 1)} Nights · ₹$_hotelPerNightEst avg/night',
                amount: _hotelCost.round(),
                color: const Color(0xFF60A5FA), // light blue
              ),
              Padding(
                padding: const EdgeInsets.only(left: 64, bottom: 20),
                child: Row(
                  children: [
                    _BadgeButton(label: 'Budget', isActive: _hotelPerNightEst < 2000, onTap: () => setState(() => _hotelPerNightEst = 1200)),
                    const SizedBox(width: 8),
                    _BadgeButton(label: 'Mid', isActive: _hotelPerNightEst >= 2000 && _hotelPerNightEst <= 4000, onTap: () => setState(() => _hotelPerNightEst = 2500)),
                    const SizedBox(width: 8),
                    _BadgeButton(label: 'Luxury', isActive: _hotelPerNightEst > 4000, onTap: () => setState(() => _hotelPerNightEst = 6000)),
                  ],
                ),
              ),

              // Food Category
              _CostItem(
                icon: Icons.restaurant,
                title: 'Food & Dining',
                subtitle: '$_days Days · ₹$_foodPerPersonEst avg/day/person',
                amount: _foodCost.round(),
                color: const Color(0xFFF472B6), // pink
              ),
              Padding(
                padding: const EdgeInsets.only(left: 64, bottom: 20),
                child: Row(
                  children: [
                     _BadgeButton(label: 'Street/Budget', isActive: _foodPerPersonEst < 500, onTap: () => setState(() => _foodPerPersonEst = 400)),
                    const SizedBox(width: 8),
                    _BadgeButton(label: 'Casual', isActive: _foodPerPersonEst >= 500 && _foodPerPersonEst <= 1200, onTap: () => setState(() => _foodPerPersonEst = 800)),
                    const SizedBox(width: 8),
                    _BadgeButton(label: 'Fine Dining', isActive: _foodPerPersonEst > 1200, onTap: () => setState(() => _foodPerPersonEst = 2000)),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    // Save trip logic would go here
                    Navigator.popUntil(context, (route) => route.isFirst);
                   // Show success dialog or snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(
                        content: Text('Trip itinerary and budget saved!'),
                        backgroundColor: AppColors.primaryGreen,
                       )
                    );
                  },
                  child: const Text('Save Trip & Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _VariableCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _VariableCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _CostItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int amount;
  final Color color;
  final bool hasArrow;

  const _CostItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.color,
    this.hasArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '₹${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (hasArrow) ...[
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
          ],
        ],
      ),
    );
  }
}

class _BadgeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BadgeButton({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? AppColors.primaryGreen.withValues(alpha: 0.4) : AppColors.borderGreen.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textMuted,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
