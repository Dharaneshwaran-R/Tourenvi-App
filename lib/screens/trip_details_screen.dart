import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:convert';
import '../theme/app_theme.dart';
import 'cost_breakdown_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  final String tripType;
  final String origin;
  final String destination;
  final String vehicleDisplay;
  final double vehicleMileage;
  final int memberCount;
  final List<String> moods;
  final List<dynamic> tourismData;

  const TripDetailsScreen({
    super.key,
    required this.tripType,
    required this.origin,
    required this.destination,
    required this.vehicleDisplay,
    required this.vehicleMileage,
    required this.memberCount,
    required this.moods,
    required this.tourismData,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  int _currentStep = 0;
  double _fuelPrice = 104.0;
  int _distance = 350;
  
  Map<String, dynamic>? _destinationObj;
  List<Map<String, dynamic>> _realHotels = [];
  bool _isFetchingHotels = false;

  @override
  void initState() {
    super.initState();
    _matchDestination();
  }
  
  void _matchDestination() async {
     final destLow = widget.destination.toLowerCase();
     for (var item in widget.tourismData) {
        if ((item['destination_name']?.toString().toLowerCase() == destLow) || 
            (item['state']?.toString().toLowerCase() == destLow)) {
            _destinationObj = item;
            break;
        }
     }
     
     // Fetch Real Hotels!
     _fetchRealHotelsFromOSM();
  }

  Future<void> _fetchRealHotelsFromOSM() async {
    double lat = 20.5937; // default India
    double lon = 78.9629;
    
    if (_destinationObj != null && _destinationObj!['coordinates'] != null) {
       lat = (_destinationObj!['coordinates']['latitude'] as num).toDouble();
       lon = (_destinationObj!['coordinates']['longitude'] as num).toDouble();
    }
    
    setState(() => _isFetchingHotels = true);
    
    try {
      final query = '[out:json];node["tourism"="hotel"](around:20000,$lat,$lon);out 5;';
      final url = Uri.parse('https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}');
      
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(url);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body);
      
      if (data['elements'] != null) {
         for (var el in data['elements']) {
            if (el['tags'] != null && el['tags']['name'] != null) {
               _realHotels.add({
                 'name': el['tags']['name'],
               });
            }
         }
      }
    } catch (e) {
      debugPrint("Overpass API failed: $e");
    }
    
    if (mounted) {
      setState(() => _isFetchingHotels = false);
    }
  }

  double get _fuelCost => (_distance / widget.vehicleMileage) * _fuelPrice;
  int get _roomsNeeded => (widget.memberCount / 2).ceil();
  
  int get _hotelCostPerNight {
    if (_destinationObj != null) {
        final cat = widget.tripType == 'Solo' ? 'budget_category' : 
                    widget.tripType == 'Family' ? 'mid_range_category' : 'luxury_category';
        final range = _destinationObj![cat]?['accommodation_range'];
        if (range != null && range.length >= 2) {
             return (range[0] as num).toInt();
        }
    }
    return widget.tripType == 'Family' ? 4000 : (widget.tripType == 'Group' ? 6000 : 1500);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Trip to ${widget.destination}',
          style: GoogleFonts.syne(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryGreen,
            surface: AppColors.background,
          ),
        ),
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 3) {
              setState(() => _currentStep += 1);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CostBreakdownScreen(
                    origin: widget.origin,
                    destination: widget.destination,
                    vehicleDisplay: widget.vehicleDisplay,
                    vehicleMileage: widget.vehicleMileage,
                    memberCount: widget.memberCount,
                    distance: _distance,
                  ),
                ),
              );
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          controlsBuilder: (context, details) {
            final isLast = _currentStep == 3;
            return Container(
              margin: const EdgeInsets.only(top: 24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: details.onStepContinue,
                      child: Text(isLast ? 'Finish Plan' : 'Continue', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.borderGreen),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    ),
                ],
              ),
            );
          },
          steps: [
            _buildMapStep(),
            _buildVehicleStep(),
            _buildHotelStep(),
            _buildTotalBudgetStep(),
          ],
        ),
      ),
    );
  }

  Step _buildMapStep() {
    return Step(
      title: const Text('Route Map', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      content: Container(
        height: 200,
        width: double.infinity,
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGreen),
          image: const DecorationImage(
            image: NetworkImage('https://static.vecteezy.com/system/resources/previews/001/222/688/non_2x/map-with-gps-pin-vector.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map, color: AppColors.primaryGreen, size: 40),
              const SizedBox(height: 12),
              Text(
                '${widget.origin} → ${widget.destination}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Distance: ~350 km',
                style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildVehicleStep() {
    return Step(
      title: const Text('Estimate Fuel Cost', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: const Text('Based on vehicle dataset', style: TextStyle(color: AppColors.textSecondary)),
      content: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGreen),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car, color: AppColors.primaryGreen, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text('Vehicle: ${widget.vehicleDisplay}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Text('Distance:', style: TextStyle(color: AppColors.textSecondary))),
                Text('$_distance km', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Text('Mileage (from CSV):', style: TextStyle(color: AppColors.textSecondary))),
                Text('${widget.vehicleMileage} km/l', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Text('Fuel Rate / Litre:', style: TextStyle(color: AppColors.textSecondary))),
                Text('₹$_fuelPrice', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: AppColors.borderGreen, height: 1),
            ),
            Row(
              children: [
                const Expanded(
                  child: Text('TOTAL ESTIMATED COST', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                Text('₹${_fuelCost.round()}', style: const TextStyle(color: AppColors.primaryGreen, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildHotelStep() {
    return Step(
      title: const Text('Find Stays', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text('Matching your ${widget.tripType} trip profile (${widget.memberCount} members)', style: const TextStyle(color: AppColors.textSecondary)),
      content: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: _isFetchingHotels 
         ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
         : Column(
          children: [
            if (_realHotels.isNotEmpty) 
              ..._realHotels.map((hotel) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildHotelCard(
                     name: hotel['name'], 
                     price: _hotelCostPerNight * _roomsNeeded, 
                     rating: 4.5, 
                     highlightIcon: Icons.star,
                     rooms: _roomsNeeded
                  ),
              )).toList()
            else ...[
                _buildHotelCard(
                   name: 'Grand Resort ${widget.destination}', 
                   price: _hotelCostPerNight * _roomsNeeded + 1500, 
                   rating: 4.8, 
                   highlightIcon: Icons.star,
                   rooms: _roomsNeeded
                ),
                const SizedBox(height: 12),
                _buildHotelCard(
                   name: 'Premium Stay at ${widget.destination}', 
                   price: _hotelCostPerNight * _roomsNeeded, 
                   rating: 4.3, 
                   highlightIcon: Icons.thumb_up,
                   rooms: _roomsNeeded
                ),
            ]
          ],
        ),
      ),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    );
  }

  Widget _buildHotelCard({required String name, required int price, required double rating, required IconData highlightIcon, required int rooms}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGreen.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: AppColors.cardLight,
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'),
                fit: BoxFit.cover,
              )
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(highlightIcon, color: AppColors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text('$rating Rating • $rooms Room(s)', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Text('₹$price', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Step _buildTotalBudgetStep() {
    final int hotelTotal = _hotelCostPerNight * _roomsNeeded;
    int foodBudget = _destinationObj != null 
        ? ((_destinationObj!['budget_category']['food_range'][0] as num).toInt() * widget.memberCount)
        : 2000 * widget.memberCount;

    return Step(
      title: const Text('Total Required Budget', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      content: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryGreen, width: 2),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fuel / Travel', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                Text('₹${_fuelCost.round()}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Hotel / Stays', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                Text('₹$hotelTotal', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Food & Activities', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                Text('₹$foodBudget', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: AppColors.borderGreen, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Budget', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  '₹${_fuelCost.round() + hotelTotal + foodBudget}',
                  style: const TextStyle(color: AppColors.primaryGreen, fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 3,
      state: StepState.indexed,
    );
  }
}
