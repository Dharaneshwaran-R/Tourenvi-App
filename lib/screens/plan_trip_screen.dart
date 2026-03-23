import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:convert';
import '../theme/app_theme.dart';
import 'trip_details_screen.dart';

class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  String _tripType = 'Family';
  String _origin = '';
  String _destination = '';
  String _startDate = 'dd-mm-yyyy';
  String _endDate = 'dd-mm-yyyy';
  int _memberCount = 2;
  
  String _vehicleDisplay = 'Two-Wheeler';
  double _vehicleMileage = 40.0;
  
  final List<String> _selectedMoods = [];
  
  final List<String> _moodOptions = ['Trek', 'Beach', 'Nature', 'Heritage', 'Food', 'Pilgrim'];
  final List<String> _quickDests = ['Goa', 'Ooty', 'Manali', 'Jaipur'];

  List<Map<String, dynamic>> _carData = [];
  List<dynamic> _tourismData = [];

  final TextEditingController _destController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load directly from build folder via dart:io to bypass flutter assets cache issues on hot-reload
      final csvFile = File('build/brand_model_fuel_mileage.csv');
      if (await csvFile.exists()) {
        final csvString = await csvFile.readAsString();
        final lines = csvString.split('\n');
        for (var i = 1; i < lines.length; i++) {
          final parts = lines[i].split(',');
          if (parts.length >= 4) {
            _carData.add({
              'brand': parts[0].trim(),
              'model': parts[1].trim(),
              'fuel': parts[2].trim(),
              'mileage': double.tryParse(parts[3].trim()) ?? 15.0,
            });
          }
        }
      }

      final jsonFile = File('build/india_tourism_dataset.json');
      if (await jsonFile.exists()) {
        final jsonString = await jsonFile.readAsString();
        _tourismData = jsonDecode(jsonString);
      }
      
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error loading datasets directly from build folder: $e");
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.black,
              surface: AppColors.card,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        String formattedDate = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
        if (isStart) {
          _startDate = formattedDate;
        } else {
          _endDate = formattedDate;
        }
      });
    }
  }

  void _showVehiclePicker() {
    List<Map<String, dynamic>> filteredCars = List.from(_carData);
    String searchBrand = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Vehicle', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  if (_memberCount <= 2)
                    ListTile(
                      title: const Text('Two-Wheeler', style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Default 40 km/l', style: TextStyle(color: AppColors.textSecondary)),
                      leading: const Icon(Icons.two_wheeler, color: AppColors.primaryGreen),
                      onTap: () {
                        setState(() {
                          _vehicleDisplay = 'Two-Wheeler';
                          _vehicleMileage = 40.0;
                        });
                        Navigator.pop(ctx);
                      },
                    ),

                  const Divider(color: AppColors.borderGreen),
                  const Text('Or search your exact car for correct fuel price:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 12),
                  
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search Brand or Model...',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        searchBrand = val.toLowerCase();
                        filteredCars = _carData.where((c) {
                          final label = '${c['brand']} ${c['model']} (${c['fuel']})'.toLowerCase();
                          return label.contains(searchBrand);
                        }).toList();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: filteredCars.isEmpty
                        ? const Center(child: Text('Loading cars dataset or no match...', style: TextStyle(color: AppColors.textSecondary)))
                        : ListView.builder(
                            itemCount: filteredCars.take(100).length,
                            itemBuilder: (ctx, i) {
                              final car = filteredCars[i];
                              final displayName = '${car['brand']} ${car['model']}';
                              return ListTile(
                                leading: const Icon(Icons.directions_car, color: AppColors.primaryGreen),
                                title: Text(displayName, style: const TextStyle(color: Colors.white)),
                                subtitle: Text('${car['fuel']} • ${car['mileage']} km/l', style: const TextStyle(color: AppColors.textSecondary)),
                                onTap: () {
                                  setState(() {
                                    _vehicleDisplay = '$displayName (${car['fuel']})';
                                    _vehicleMileage = car['mileage'];
                                  });
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Headings
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🚀 ', style: TextStyle(fontSize: 14)),
                    Text(
                      'Start Your Trip',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Plan in 2 minutes',
                style: GoogleFonts.syne(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'No account needed to get your estimate',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Trip Type
              _buildSectionLabel('TRIP TYPE'),
              Row(
                children: ['Solo', 'Family', 'Group'].map((type) {
                  final isSelected = _tripType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _tripType = type;
                          if (type == 'Solo') _memberCount = 1;
                          if (type == 'Family') _memberCount = 4;
                          if (type == 'Group') _memberCount = 6;
                          
                          if (_memberCount > 2 && _vehicleDisplay == 'Two-Wheeler') {
                            _vehicleDisplay = 'Select Vehicle...';
                          }
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: type == 'Group' ? 0 : 8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // From
              _buildSectionLabel('FROM'),
              _buildInputField(
                hint: 'Your starting location',
                icon: Icons.location_on,
                iconColor: AppColors.danger,
                onChanged: (val) => _origin = val,
              ),

              // Destination
              _buildSectionLabel('DESTINATION'),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue t) {
                  if (t.text.isEmpty) return const Iterable<String>.empty();
                  final lowerQuery = t.text.toLowerCase();
                  return _tourismData
                      .map((e) => e['destination_name']?.toString() ?? e['state']?.toString() ?? '')
                      .where((d) => d.toLowerCase().contains(lowerQuery))
                      .toSet()
                      .toList();
                },
                onSelected: (val) {
                   setState(() {
                     _destination = val;
                     _destController.text = val;
                   });
                },
                fieldViewBuilder: (ctx, ctrl, focusNode, onFieldSub) {
                  if (ctrl.text != _destController.text && _destController.text.isNotEmpty) {
                      ctrl.text = _destController.text;
                  }
                  return Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderGreen.withOpacity(0.5)),
                    ),
                    child: TextField(
                      controller: ctrl,
                      focusNode: focusNode,
                      onChanged: (val) => _destination = val,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Where are you headed?',
                        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        prefixIcon: Icon(Icons.grid_view_rounded, color: AppColors.textSecondary, size: 20),
                        suffixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                      ),
                    ),
                  );
                },
                optionsViewBuilder: (ctx, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      color: AppColors.cardLight,
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 250, maxWidth: 360),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (ctx, i) {
                            final String option = options.elementAt(i);
                            return ListTile(
                              title: Text(option, style: const TextStyle(color: Colors.white)),
                              leading: const Icon(Icons.place, color: AppColors.primaryGreen, size: 18),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _quickDests.map((dest) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                         _destination = dest;
                         _destController.text = dest;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _destination == dest ? AppColors.chipActive : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _destination == dest ? AppColors.primaryGreen : AppColors.borderGreen),
                      ),
                      child: Text(dest, style: TextStyle(color: _destination == dest ? AppColors.primaryGreen : Colors.white, fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),

              // Travel Dates
              _buildSectionLabel('TRAVEL DATES'),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      hint: _startDate, 
                      suffixIcon: Icons.calendar_today, 
                      isSmall: true, 
                      readOnly: true,
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      hint: _endDate, 
                      suffixIcon: Icons.calendar_today, 
                      isSmall: true, 
                      readOnly: true,
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),

              // Number of Members
              _buildSectionLabel('NO. OF MEMBERS'),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderGreen.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.people, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text('$_memberCount', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove, color: AppColors.primaryGreen),
                      onPressed: () {
                        if (_memberCount > 1) {
                          setState(() => _memberCount--);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: AppColors.primaryGreen),
                      onPressed: () {
                        setState(() {
                          _memberCount++;
                          if (_memberCount > 2 && _vehicleDisplay == 'Two-Wheeler') {
                            _vehicleDisplay = 'Select Vehicle...';
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Vehicle Type
              _buildSectionLabel('VEHICLE TYPE'),
              GestureDetector(
                onTap: _showVehiclePicker,
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderGreen.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _vehicleDisplay == 'Two-Wheeler' ? Icons.two_wheeler : Icons.directions_car, 
                        color: AppColors.primaryGreen, 
                        size: 20
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _vehicleDisplay,
                          style: TextStyle(
                            color: _vehicleDisplay == 'Select Vehicle...' ? AppColors.textSecondary : Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),

              // Travel Mood
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  _buildSectionLabel('TRAVEL MOOD'),
                  const SizedBox(width: 8),
                  const Text('(PICK YOUR VIBE)', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _moodOptions.map((mood) {
                  final isSelected = _selectedMoods.contains(mood);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) _selectedMoods.remove(mood);
                        else _selectedMoods.add(mood);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.chipActive : AppColors.cardLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppColors.primaryGreen : Colors.transparent),
                      ),
                      child: Text(
                        mood,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryGreen : Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 48),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (_vehicleDisplay == 'Select Vehicle...') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a vehicle first!')));
                      return;
                    }
                    if (_destination.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please set a destination!')));
                      return;
                    }
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TripDetailsScreen(
                          tripType: _tripType,
                          origin: _origin.isEmpty ? 'Your Location' : _origin,
                          destination: _destination,
                          vehicleDisplay: _vehicleDisplay,
                          vehicleMileage: _vehicleMileage,
                          memberCount: _memberCount,
                          moods: _selectedMoods,
                          tourismData: _tourismData,
                        ),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Plan My Trip ',
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.black, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, color: AppColors.orange, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Free to use • No credit card',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hint,
    IconData? icon,
    Color? iconColor,
    IconData? suffixIcon,
    bool isSmall = false,
    bool readOnly = false,
    Function()? onTap,
    Function(String)? onChanged,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGreen.withOpacity(0.5)),
      ),
      child: TextField(
        onTap: onTap,
        onChanged: onChanged,
        readOnly: readOnly,
        style: TextStyle(color: readOnly ? Colors.white : Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: readOnly ? Colors.white : AppColors.textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          prefixIcon: icon != null 
            ? Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 20) 
            : null,
          suffixIcon: suffixIcon != null 
            ? Icon(suffixIcon, color: AppColors.textSecondary, size: 20) 
            : null,
        ),
        textAlignVertical: TextAlignVertical.center,
      ),
    );
  }
}
