import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'cost_breakdown_screen.dart';

class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  int _selectedRoute = 0; // 0: Eco, 1: Fastest, 2: Cheapest
  int _selectedVehicle = 0;
  int _selectedFuel = 0;

  final List<String> _vehicleTypes = ['Car', 'Bike', 'SUV'];
  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'EV'];

  String _destination = '';

  @override
  Widget build(BuildContext context) {
    final bool hasDestination = _destination.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Plan a Trip',
                style: GoogleFonts.syne(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Configure your journey',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),

              // Origin field
              _buildLocationField(
                icon: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGreen,
                  ),
                ),
                text: 'Chennai, Tamil Nadu',
                filled: true,
              ),
              const SizedBox(height: 12),

              // Destination field
              _buildLocationField(
                icon: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.danger,
                  ),
                ),
                text: _destination.isEmpty
                    ? 'Enter destination...'
                    : _destination,
                filled: _destination.isNotEmpty,
                onTap: () => _showDestinationPicker(),
              ),
              const SizedBox(height: 32),

              // Route Preference
              const Text(
                'ROUTE PREFERENCE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildRouteOption(0, Icons.eco_rounded, 'Eco', 'Greener'),
                  const SizedBox(width: 12),
                  _buildRouteOption(
                      1, Icons.bolt_rounded, 'Fastest', 'Save time'),
                  const SizedBox(width: 12),
                  _buildRouteOption(
                      2, Icons.savings_rounded, 'Cheapest', 'Save cost'),
                ],
              ),
              const SizedBox(height: 32),

              // Vehicle Details
              const Text(
                'VEHICLE DETAILS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildSelectableChip(
                    _vehicleTypes[_selectedVehicle],
                    true,
                    onTap: () {
                      setState(() {
                        _selectedVehicle =
                            (_selectedVehicle + 1) % _vehicleTypes.length;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildSelectableChip(
                    _fuelTypes[_selectedFuel],
                    true,
                    onTap: () {
                      setState(() {
                        _selectedFuel =
                            (_selectedFuel + 1) % _fuelTypes.length;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildSelectableChip('18 km/l', true, onTap: () {}),
                ],
              ),
              const SizedBox(height: 32),

              // Estimated Cost
              const Text(
                'ESTIMATED COST',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              _buildCostRow('Fuel', hasDestination ? '₹ 1,120' : '₹ —'),
              const Divider(
                  color: AppColors.borderGreen, height: 1, thickness: 0.5),
              _buildCostRow('Tolls', hasDestination ? '₹ 360' : '₹ —'),
              const Divider(
                  color: AppColors.borderGreen, height: 1, thickness: 0.5),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: hasDestination
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CostBreakdownScreen(),
                                ),
                              );
                            }
                          : () => _showDestinationPicker(),
                      child: Text(
                        hasDestination ? '₹ 1,480' : 'Enter destination',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDestinationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pick a destination',
                style: GoogleFonts.syne(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...[
                'Yercaud',
                'Pondicherry',
                'Mahabalipuram',
                'Ooty',
                'Kodaikanal'
              ].map((dest) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primaryGreen,
                  ),
                  title: Text(
                    dest,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    setState(() => _destination = dest);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationField({
    required Widget icon,
    required String text,
    required bool filled,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderGreen.withOpacity(0.4),
          ),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 14),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: filled ? FontWeight.w600 : FontWeight.w400,
                color: filled ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteOption(
      int index, IconData icon, String label, String subtitle) {
    final active = _selectedRoute == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRoute = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: active ? AppColors.chipActive : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active
                  ? AppColors.primaryGreen.withOpacity(0.5)
                  : AppColors.borderGreen.withOpacity(0.3),
              width: active ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: active ? AppColors.primaryGreen : AppColors.textSecondary,
                size: 26,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color:
                      active ? AppColors.primaryGreen : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color:
                      active ? AppColors.primaryGreen.withOpacity(0.7) : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableChip(String label, bool active,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderGreen.withOpacity(0.4),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
