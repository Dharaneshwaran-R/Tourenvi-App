import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import '../theme/app_theme.dart';
import '../models/trip_plan.dart';
import '../services/travel_engine.dart';
import 'trip_details_screen.dart';

class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  int _currentStep = 0;
  final TripPlan _tripPlan = TripPlan();
  
  List<List<dynamic>> _allCars = [];
  List<dynamic> _tourismData = [];
  List<Map<String, dynamic>> _hotels = [];
  bool _isFetchingHotels = false;
  bool _showVehicleSearch = false;
  String? _selectedHotel;

  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _vehicleSearchController = TextEditingController();

  final List<String> _moodOptions = ['Adventure', 'Nature', 'Heritage', 'Beach', 'Spiritual', 'Relaxation', 'Foodie'];
  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'EV', 'CNG'];
  final List<String> _routePrefs = ['Fastest', 'Fuel Efficient'];
  final List<String> _lodgingPrefs = ['Hotel', 'Homestay', 'Resort'];

  @override
  void initState() {
    super.initState();
    _loadData();
    _mileageController.text = _tripPlan.vehicleMileage.toString();
    _budgetController.text = _tripPlan.budget.toString();
  }

  Future<void> _loadData() async {
    try {
      final String carCsv = await rootBundle.loadString('assets/data/brand_model_fuel_mileage.csv');
      _allCars = const CsvToListConverter().convert(carCsv);

      final String tourismString = await rootBundle.loadString('assets/data/india_tourism_dataset.json');
      _tourismData = jsonDecode(tourismString);
      
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error loading assets: $e");
    }
  }

  Future<void> _fetchHotels() async {
    if (_tripPlan.destination.isEmpty) return;
    
    setState(() {
      _isFetchingHotels = true;
      _hotels = [];
    });

    try {
      Map<String, dynamic>? destInfo;
      for (var item in _tourismData) {
        if (item['destination_name']?.toString().toLowerCase() == _tripPlan.destination.toLowerCase()) {
          destInfo = item;
          break;
        }
      }

      double lat = 20.5937; 
      double lon = 78.9629;
      if (destInfo != null && destInfo['coordinates'] != null) {
        lat = (destInfo['coordinates']['latitude'] as num).toDouble();
        lon = (destInfo['coordinates']['longitude'] as num).toDouble();
      }

      final query = '[out:json];nwr["tourism"~"hotel|resort"](around:20000,$lat,$lon);out center 15;';
      final url = Uri.parse('https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}');
      
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['elements'] != null && data['elements'].isNotEmpty) {
          for (var el in data['elements']) {
            final tags = el['tags'];
            if (tags != null && tags['name'] != null) {
              _hotels.add({
                'name': tags['name'],
                'type': tags['tourism'] ?? 'hotel',
                'rating': 4.0 + ((el['id'] % 10) as num).toDouble() / 10.0,
                'price': 2500 + ((el['id'] % 5000) as num).toInt(),
                'location': tags['addr:street'] ?? 'Near Central ${_tripPlan.destination}',
                'amenities': ['WiFi', 'Pool', 'Parking', 'AC', 'Restaurant'].take((2 + ((el['id'] % 4) as num).toInt())).toList(),
                'image': _getHotelPlaceholder((el['id'] % 5).toInt()),
              });
            }
          }
        }
      }

      // Fallback: If still empty, generate local recommendations
      if (_hotels.isEmpty) {
        _generateFallbackHotels();
      }
    } catch (e) {
      debugPrint("Hotel fetch failed: $e");
      _generateFallbackHotels();
    }

    if (mounted) {
      setState(() => _isFetchingHotels = false);
    }
  }

  void _generateFallbackHotels() {
    final List<String> types = ['Grand Hotel', 'Resort & Spa', 'Classic Residency', 'Vista Retreat', 'Heritage Inn'];
    for (int i = 0; i < 5; i++) {
      _hotels.add({
        'name': '${_tripPlan.destination} ${types[i]}',
        'type': i % 2 == 0 ? 'hotel' : 'resort',
        'rating': 4.2 + (i * 0.1),
        'price': 3000 + (i * 1200),
        'location': 'Central Area, ${_tripPlan.destination}',
        'amenities': ['WiFi', 'AC', 'Breakfast', 'Pool'].take(3).toList(),
        'image': _getHotelPlaceholder(i),
      });
    }
  }

  String _getHotelPlaceholder(int index) {
    List<String> images = [
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=600&q=80',
    ];
    return images[index % images.length];
  }

  void _nextStep() {
    if (_currentStep == 0 && _tripPlan.destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a destination first!')));
      return;
    }
    
    if (_currentStep == 5) {
      _fetchHotels();
    }
    
    if (_currentStep < 7) {
      setState(() => _currentStep++);
    } else {
      _finishPlanning();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _finishPlanning() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripDetailsScreen(
          tripPlan: _tripPlan,
          tourismData: _tourismData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Step ${_currentStep + 1} of 8',
          style: GoogleFonts.syne(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 14),
        ),
        centerTitle: true,
        leading: _currentStep > 0 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: _prevStep,
            )
          : null,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryGreen,
          ),
        ),
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: _nextStep,
          onStepCancel: _prevStep,
          elevation: 0,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _currentStep == 7 ? 'Generate Final Plan' : 'Next Step',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          steps: [
            _buildStep('Destination', _buildDestinationStep(), 0),
            _buildStep('Route', _buildRouteStep(), 1),
            _buildStep('Profile', _buildProfileStep(), 2),
            _buildStep('Vehicle', _buildVehicleStep(), 3),
            _buildStep('Vibe', _buildMoodStep(), 4),
            _buildStep('Budget', _buildBudgetStep(), 5),
            _buildStep('Lodging', _buildLodgingStep(), 6),
            _buildStep('Review', _buildReviewStep(), 7),
          ],
        ),
      ),
    );
  }

  Step _buildStep(String title, Widget content, int index) {
    return Step(
      title: const Text(''),
      content: content,
      isActive: _currentStep >= index,
      state: _currentStep > index ? StepState.complete : StepState.indexed,
    );
  }

  // --- Step 1: Destination & Attractions ---
  Widget _buildDestinationStep() {
    Map<String, dynamic>? destInfo;
    if (_tripPlan.destination.isNotEmpty) {
      destInfo = _tourismData.firstWhere(
        (e) => e['destination_name']?.toString().toLowerCase() == _tripPlan.destination.toLowerCase(),
        orElse: () => null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeading('Where to?', 'Choose your destination to see top attractions.'),
        const SizedBox(height: 20),
        Autocomplete<String>(
          optionsBuilder: (t) {
            if (t.text.isEmpty) return const Iterable<String>.empty();
            return _tourismData
                .map((e) => e['destination_name']?.toString() ?? '')
                .where((d) => d.toLowerCase().contains(t.text.toLowerCase()));
          },
          onSelected: (val) {
            setState(() {
              _tripPlan.destination = val;
              _destController.text = val;
              _tripPlan.selectedAttractions = []; // Reset attractions on change
            });
          },
          fieldViewBuilder: (ctx, ctrl, node, onFieldSub) {
            if (_destController.text.isNotEmpty && ctrl.text != _destController.text) {
              ctrl.text = _destController.text;
            }
            return _buildInputField(
              controller: ctrl,
              label: 'Destination Name',
              hint: 'Search India...',
              icon: Icons.search,
              focusNode: node,
            );
          },
        ),
        if (destInfo != null) ...[
          const SizedBox(height: 24),
          const Text('POPULAR ATTRACTIONS', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (destInfo['primary_attractions'] as List).map((attr) {
              final isSelected = _tripPlan.selectedAttractions.contains(attr);
              return FilterChip(
                label: Text(attr, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 12)),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    if (val) _tripPlan.selectedAttractions.add(attr);
                    else _tripPlan.selectedAttractions.remove(attr);
                  });
                },
                selectedColor: AppColors.primaryGreen,
                backgroundColor: AppColors.card,
                checkmarkColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.borderGreen)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // --- Step 2: From & To Handling ---
  Widget _buildRouteStep() {
    return Column(
      children: [
        _buildStepHeading('Travel Route', 'Your destination is locked in. Just tell us where you start.'),
        const SizedBox(height: 24),
        Autocomplete<String>(
          optionsBuilder: (t) {
            if (t.text.isEmpty) return const Iterable<String>.empty();
            return _tourismData
                .map((e) => e['destination_name']?.toString() ?? '')
                .where((d) => d.toLowerCase().contains(t.text.toLowerCase()));
          },
          onSelected: (val) {
            setState(() {
              _tripPlan.origin = val;
              _originController.text = val;
            });
          },
          fieldViewBuilder: (ctx, ctrl, node, onFieldSub) {
            if (_originController.text.isNotEmpty && ctrl.text != _originController.text) {
              ctrl.text = _originController.text;
            }
            return _buildInputField(
              controller: ctrl,
              label: 'Starting From',
              hint: 'Search city...',
              icon: Icons.my_location,
              focusNode: node,
              onChanged: (val) => _tripPlan.origin = val,
            );
          },
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: TextEditingController(text: _tripPlan.destination),
          label: 'Destination (Locked)',
          hint: '',
          icon: Icons.location_on,
          readOnly: true,
          iconColor: AppColors.primaryGreen,
        ),
      ],
    );
  }

  // --- Step 7: Dynamic Hotel Selection ---
  Widget _buildLodgingStep() {
    final filteredHotels = _hotels.where((h) => 
      _tripPlan.lodgingPreference == 'All' || 
      h['type'].toString().toLowerCase().contains(_tripPlan.lodgingPreference.toLowerCase())
    ).toList();

    return Column(
      children: [
        _buildStepHeading('Select Your Stay', 'Showing top-rated stays in ${_tripPlan.destination}.'),
        const SizedBox(height: 24),
        // Filter Toggle
        Row(
          children: ['All', 'Hotel', 'Resort'].map((type) {
            final isSelected = _tripPlan.lodgingPreference == type;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tripPlan.lodgingPreference = type),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGreen : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.borderGreen),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    type,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        if (_isFetchingHotels)
          const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
        else if (filteredHotels.isEmpty)
          const Center(child: Text('No matches found for this type. Try another.', style: TextStyle(color: AppColors.textSecondary)))
        else
          ...filteredHotels.map((hotel) {
            final isSelected = _selectedHotel == hotel['name'];
            return GestureDetector(
              onTap: () => setState(() {
                _selectedHotel = hotel['name'];
                _tripPlan.selectedHotel = hotel['name'];
                _tripPlan.lodgingPreference = hotel['type'];
              }),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.borderGreen),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Image.network(hotel['image'], height: 140, width: double.infinity, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  hotel['name'], 
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('₹${hotel['price']}', style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w900, fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.orange, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${hotel['rating']} • ${hotel['location']}', 
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: (hotel['amenities'] as List).map((a) => 
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(6)),
                                child: Text(a, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                              )
                            ).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  // --- Step 3: Profile ---
  Widget _buildProfileStep() {
    return Column(
      children: [
        _buildStepHeading('Who is traveling?', 'Help us tailor the experience.'),
        const SizedBox(height: 24),
        Row(
          children: ['Solo', 'Family', 'Group'].map((type) {
            final isSelected = _tripPlan.tripType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _tripPlan.tripType = type;
                  if (type == 'Solo') _tripPlan.memberCount = 1;
                  else if (type == 'Family') _tripPlan.memberCount = 4;
                  else _tripPlan.memberCount = 6;
                }),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGreen.withOpacity(0.1) : AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.borderGreen),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        type == 'Solo' ? Icons.person : (type == 'Family' ? Icons.family_restroom : Icons.groups),
                        color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(type, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_tripPlan.tripType != 'Solo') ...[
          const SizedBox(height: 24),
          _buildNumberPicker(
            value: _tripPlan.memberCount,
            onChanged: (val) => setState(() => _tripPlan.memberCount = val),
          ),
        ],
      ],
    );
  }

  // --- Step 4: Vehicle ---
  Widget _buildVehicleStep() {
    return Column(
      children: [
        _buildStepHeading('Your Ride', 'Select vehicle type and specify details.'),
        const SizedBox(height: 24),
        Row(
          children: ['Car', 'Bike'].map((type) {
            final isSelected = _tripPlan.vehicleType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _tripPlan.vehicleType = type;
                  // Set default mileage for bike vs car if not set
                  if (type == 'Bike' && _tripPlan.vehicleMileage == 15.0) {
                    _tripPlan.vehicleMileage = 45.0;
                    _mileageController.text = '45.0';
                  } else if (type == 'Car' && _tripPlan.vehicleMileage == 45.0) {
                    _tripPlan.vehicleMileage = 15.0;
                    _mileageController.text = '15.0';
                  }
                }),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGreen.withOpacity(0.1) : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.primaryGreen : AppColors.borderGreen),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        type == 'Car' ? Icons.directions_car : Icons.directions_bike,
                        color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(type, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildInputField(
          controller: _vehicleSearchController,
          label: _tripPlan.vehicleType == 'Car' ? 'Search Car Model' : 'Search Bike Model',
          hint: _tripPlan.vehicleType == 'Car' ? 'e.g. Swift, Innova...' : 'e.g. Pulsar, Activa...',
          icon: Icons.search,
          onChanged: (val) => setState(() => _showVehicleSearch = val.isNotEmpty),
        ),
        if (_showVehicleSearch && _vehicleSearchController.text.isNotEmpty)
          Container(
            height: 180,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderGreen)),
            child: ListView.builder(
              itemCount: _allCars.where((c) => c.join(' ').toLowerCase().contains(_vehicleSearchController.text.toLowerCase())).take(20).length,
              itemBuilder: (ctx, i) {
                final car = _allCars.where((c) => c.join(' ').toLowerCase().contains(_vehicleSearchController.text.toLowerCase())).toList()[i];
                return ListTile(
                  title: Text('${car[0]} ${car[1]}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text('${car[2]} • ${car[3]} km/l', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  onTap: () {
                    setState(() {
                      _tripPlan.fuelType = car[2].toString();
                      _tripPlan.vehicleMileage = double.tryParse(car[3].toString()) ?? 15.0;
                      _mileageController.text = _tripPlan.vehicleMileage.toString();
                      _vehicleSearchController.text = '${car[0]} ${car[1]}';
                      _showVehicleSearch = false; // Close the list
                    });
                  },
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _mileageController,
          label: 'Vehicle Mileage',
          hint: '15.0',
          icon: Icons.speed,
          keyboardType: TextInputType.number,
          onChanged: (val) => _tripPlan.vehicleMileage = double.tryParse(val) ?? 15.0,
        ),
      ],
    );
  }

  // --- Step 5: Mood ---
  Widget _buildMoodStep() {
    return Column(
      children: [
        _buildStepHeading('The Vibe', 'What kind of trip is this?'),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _moodOptions.map((m) {
            final isSelected = _tripPlan.moods.contains(m);
            return FilterChip(
              label: Text(m),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    if (!_tripPlan.moods.contains(m)) _tripPlan.moods.add(m);
                  } else {
                    _tripPlan.moods.remove(m);
                  }
                });
              },
              selectedColor: AppColors.primaryGreen,
              checkmarkColor: Colors.black,
              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.borderGreen)),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Step 6: Budget ---
  Widget _buildBudgetStep() {
    return Column(
      children: [
        _buildStepHeading('Budget', 'Set your maximum spending limit.'),
        const SizedBox(height: 24),
        _buildInputField(
          controller: _budgetController,
          label: 'Total Budget (INR)',
          hint: '10000',
          icon: Icons.wallet,
          keyboardType: TextInputType.number,
          onChanged: (val) => setState(() => _tripPlan.budget = double.tryParse(val) ?? 10000),
        ),
        Slider(
          value: _tripPlan.budget.clamp(1000, 100000).toDouble(),
          min: 1000, max: 100000,
          onChanged: (v) => setState(() {
            _tripPlan.budget = v;
            _budgetController.text = v.toInt().toString();
          }),
        ),
      ],
    );
  }

  // --- Step 8: Review ---
  Widget _buildReviewStep() {
    return Column(
      children: [
        _buildStepHeading('Review & Confirm', 'Almost there! Check your trip summary.'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderGreen)),
          child: Column(
            children: [
              _buildReviewRow('Destination', _tripPlan.destination),
              _buildReviewRow('Starting From', _tripPlan.origin.isEmpty ? 'Not set' : _tripPlan.origin),
              _buildReviewRow('Visiting', '${_tripPlan.selectedAttractions.length} Places'),
              _buildReviewRow('Vehicle', '${_tripPlan.fuelType} (${_tripPlan.vehicleMileage} km/l)'),
              _buildReviewRow('Stay', _tripPlan.selectedHotel ?? 'TBD'),
              _buildReviewRow('Budget', '₹${_tripPlan.budget.toInt()}', isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets ---
  Widget _buildStepHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    Color? iconColor,
    FocusNode? focusNode,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          focusNode: focusNode,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            prefixIcon: Icon(icon, color: iconColor ?? AppColors.primaryGreen, size: 20),
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberPicker({required int value, required Function(int) onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: const Icon(Icons.remove, color: AppColors.primaryGreen), onPressed: value > 1 ? () => onChanged(value - 1) : null),
        Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        IconButton(icon: const Icon(Icons.add, color: AppColors.primaryGreen), onPressed: () => onChanged(value + 1)),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
