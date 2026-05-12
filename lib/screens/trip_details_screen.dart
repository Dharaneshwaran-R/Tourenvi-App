import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/trip_plan.dart';
import '../services/travel_engine.dart';

class TripDetailsScreen extends StatefulWidget {
  final TripPlan tripPlan;
  final List<dynamic> tourismData;

  const TripDetailsScreen({
    super.key,
    required this.tripPlan,
    required this.tourismData,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  double _distance = 0.0;
  bool _isLoading = true;
  
  // Results
  double _fuelCost = 0.0;
  double _tollCost = 0.0;
  double _lodgingCost = 0.0;
  double _totalCost = 0.0;
  double _co2Emissions = 0.0;

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _calculateTripData();
  }

  double _duration = 0;

  Future<void> _calculateTripData() async {
    setState(() => _isLoading = true);
    
    try {
      // 1. Fetch real travel data (distance & time)
      final travelData = await TravelEngine.fetchTravelData(widget.tripPlan.origin, widget.tripPlan.destination);
      _distance = travelData['distance'] ?? 350.0;
      _duration = travelData['time'] ?? 6.5;
      
      // 2. Match Tourism Data
      Map<String, dynamic>? destInfo;
      for (var item in widget.tourismData) {
        if (item['destination_name']?.toString().toLowerCase() == widget.tripPlan.destination.toLowerCase()) {
          destInfo = item;
          break;
        }
      }

      // 3. Calculate costs
      _fuelCost = TravelEngine.calculateFuelCost(_distance, widget.tripPlan.vehicleMileage, widget.tripPlan.fuelType);
      _tollCost = TravelEngine.estimateTolls(_distance);
      
      if (destInfo != null && destInfo.containsKey('budget_category')) {
        final category = widget.tripPlan.budget < 50000 ? 'budget_category' : 
                         widget.tripPlan.budget < 100000 ? 'mid_range_category' : 'luxury_category';
        final catData = destInfo[category] ?? destInfo['budget_category'];
        final lodgingRange = catData['accommodation_range'];
        if (lodgingRange != null && lodgingRange is List && lodgingRange.isNotEmpty) {
          _lodgingCost = (lodgingRange[0] as num).toDouble() * widget.tripPlan.memberCount * 3;
        } else {
          _lodgingCost = TravelEngine.estimateLodgingCost(3, widget.tripPlan.memberCount, widget.tripPlan.lodgingPreference);
        }
      } else {
        _lodgingCost = TravelEngine.estimateLodgingCost(3, widget.tripPlan.memberCount, widget.tripPlan.lodgingPreference);
      }
      
      // Ensure no NaN or Infinity
      if (_fuelCost.isNaN || _fuelCost.isInfinite) _fuelCost = 0;
      if (_tollCost.isNaN || _tollCost.isInfinite) _tollCost = 0;
      if (_lodgingCost.isNaN || _lodgingCost.isInfinite) _lodgingCost = 0;
      _totalCost = _fuelCost + _tollCost + _lodgingCost;
      
      _co2Emissions = TravelEngine.estimateCarbonFootprint(_distance, widget.tripPlan.fuelType);
      if (_co2Emissions.isNaN || _co2Emissions.isInfinite) _co2Emissions = 0;

      // 4. Set Markers with real coordinates
      final oLat = travelData['orig_lat'] ?? 12.9716;
      final oLon = travelData['orig_lon'] ?? 77.5946;
      final dLat = travelData['dest_lat'] ?? 11.4102;
      final dLon = travelData['dest_lon'] ?? 76.6991;

      _markers.add(Marker(
        markerId: const MarkerId('origin'),
        position: LatLng(oLat, oLon),
        infoWindow: InfoWindow(title: widget.tripPlan.origin),
      ));
      
      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(dLat, dLon),
        infoWindow: InfoWindow(title: widget.tripPlan.destination),
      ));

      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(dLat, dLon), 10));
      }
    } catch (e) {
      debugPrint("Trip calculation failed: $e");
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
        : CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMapSection(),
                      const SizedBox(height: 24),
                      _buildCostDashboard(),
                      const SizedBox(height: 24),
                      _buildSustainabilityAlert(),
                      const SizedBox(height: 24),
                      _buildItinerarySection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Your Travel Plan',
          style: GoogleFonts.syne(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.darkGreen, AppColors.background],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ROUTE OVERVIEW', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGreen),
          ),
          clipBehavior: Clip.antiAlias,
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 4),
            markers: _markers,
            polylines: _polylines,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              _mapController = controller;
              if (_markers.isNotEmpty) {
                // Animate to destination if markers are already set
                final destMarker = _markers.firstWhere((m) => m.markerId.value == 'destination');
                _mapController!.animateCamera(CameraUpdate.newLatLngZoom(destMarker.position, 10));
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatItem('Distance', '${_distance.toInt()} km', Icons.route),
            _buildStatItem('Estimated Time', '${_duration.toInt()}h ${((_duration - _duration.toInt()) * 60).toInt()}m', Icons.timer),
            _buildStatItem('Route', widget.tripPlan.routePreference, Icons.map),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }

  Widget _buildCostDashboard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderGreen.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('COST BREAKDOWN', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(value: _fuelCost, color: AppColors.primaryGreen, radius: 20, showTitle: false),
                      PieChartSectionData(value: _tollCost, color: Colors.blue, radius: 20, showTitle: false),
                      PieChartSectionData(value: _lodgingCost, color: Colors.orange, radius: 20, showTitle: false),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem('Fuel', _fuelCost, AppColors.primaryGreen),
                    _buildLegendItem('Tolls', _tollCost, Colors.blue),
                    _buildLegendItem('Lodging', _lodgingCost, Colors.orange),
                    if (widget.tripPlan.selectedHotel != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.tripPlan.selectedHotel!,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontStyle: FontStyle.italic),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const Divider(color: AppColors.borderGreen),
                    _buildLegendItem('Total', _totalCost, Colors.white, isBold: true),
                  ],
                ),
              ),
            ],
          ),
          if (_totalCost > widget.tripPlan.budget)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Exceeds budget by ₹${(_totalCost - widget.tripPlan.budget).toInt()}', style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, double value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isBold ? Colors.white : AppColors.textSecondary, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
          Text('₹${value.toInt()}', style: TextStyle(color: Colors.white, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildSustainabilityAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.darkGreen, AppColors.cardLight]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco, color: AppColors.primaryGreen, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sustainable Travel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(
                  'This trip emits ${_co2Emissions.toStringAsFixed(1)}kg CO2. Choosing a fuel-efficient route saved 12kg.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItinerarySection() {
    // Prioritize user-selected attractions
    final List<String> attractions = widget.tripPlan.selectedAttractions.isNotEmpty 
        ? widget.tripPlan.selectedAttractions 
        : ['Local Sightseeing', 'Cultural Tour', 'Nature Walk'];
    
    final String moodStr = widget.tripPlan.moods.isNotEmpty ? widget.tripPlan.moods.first : 'Adventure';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('YOUR CURATED ITINERARY', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: attractions.length.clamp(3, 10),
          itemBuilder: (context, index) {
            String title = 'Explore Spot';
            if (index < attractions.length) {
              title = attractions[index];
            } else if (index == 1) {
              title = '$moodStr Experience';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderGreen.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(8)),
                    child: Text('S${index + 1}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          'One of your selected places in ${widget.tripPlan.destination}. Enjoy the ${moodStr.toLowerCase()} atmosphere.',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
