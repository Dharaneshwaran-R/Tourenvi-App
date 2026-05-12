import 'dart:math';

/// Simulated toll cost service.
/// In production, this would integrate with FASTag/NHAI APIs.
class TollApiService {
  TollApiService._();
  static final TollApiService _instance = TollApiService._();
  factory TollApiService() => _instance;

  /// Known toll plazas on major Indian routes (simulated)
  static final Map<String, List<Map<String, dynamic>>> _routeTolls = {
    'chennai_bangalore': [
      {'name': 'Sriperumbudur Toll', 'km': 42, 'cost': 65, 'type': 'single'},
      {'name': 'Kanchipuram Toll', 'km': 75, 'cost': 55, 'type': 'single'},
      {'name': 'Vellore Toll', 'km': 140, 'cost': 80, 'type': 'single'},
      {'name': 'Krishnagiri Toll', 'km': 210, 'cost': 70, 'type': 'single'},
      {'name': 'Hosur Toll', 'km': 270, 'cost': 60, 'type': 'single'},
    ],
    'chennai_pondicherry': [
      {'name': 'Mahabalipuram Toll', 'km': 50, 'cost': 45, 'type': 'single'},
      {'name': 'Tindivanam Toll', 'km': 110, 'cost': 55, 'type': 'single'},
    ],
    'chennai_madurai': [
      {'name': 'Sriperumbudur Toll', 'km': 42, 'cost': 65, 'type': 'single'},
      {'name': 'Villupuram Toll', 'km': 165, 'cost': 75, 'type': 'single'},
      {'name': 'Trichy Toll', 'km': 330, 'cost': 80, 'type': 'single'},
      {'name': 'Dindigul Toll', 'km': 400, 'cost': 55, 'type': 'single'},
    ],
    'chennai_ooty': [
      {'name': 'Sriperumbudur Toll', 'km': 42, 'cost': 65, 'type': 'single'},
      {'name': 'Kanchipuram Toll', 'km': 75, 'cost': 55, 'type': 'single'},
      {'name': 'Krishnagiri Toll', 'km': 210, 'cost': 70, 'type': 'single'},
      {'name': 'Mysore Toll', 'km': 430, 'cost': 85, 'type': 'single'},
    ],
    'bangalore_goa': [
      {'name': 'Tumkur Toll', 'km': 70, 'cost': 60, 'type': 'single'},
      {'name': 'Davangere Toll', 'km': 245, 'cost': 75, 'type': 'single'},
      {'name': 'Hubli Toll', 'km': 350, 'cost': 65, 'type': 'single'},
      {'name': 'Belgaum Toll', 'km': 420, 'cost': 80, 'type': 'single'},
    ],
  };

  /// Get toll breakdown for a route
  Future<TollResult> getTollBreakdown({
    required String origin,
    required String destination,
    bool isRoundTrip = false,
    String vehicleType = 'car',
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    final key = _routeKey(origin, destination);
    List<Map<String, dynamic>> tolls = _routeTolls[key] ?? [];

    // If no exact route, generate plausible toll data
    if (tolls.isEmpty) {
      tolls = _generateTolls(origin, destination);
    }

    // Apply vehicle multiplier
    final multiplier = _vehicleMultiplier(vehicleType);
    final processedTolls = tolls.map((t) {
      final cost = (t['cost'] as int) * multiplier;
      return TollPlaza(
        name: t['name'] as String,
        kmFromOrigin: t['km'] as int,
        singleCost: cost.round().toDouble(),
        returnCost: (cost * 0.85).round().toDouble(), // ETC discount on return
        hasFASTag: true,
      );
    }).toList();

    final singleTotal = processedTolls.fold(0.0, (sum, t) => sum + t.singleCost);
    final roundTotal = singleTotal + processedTolls.fold(0.0, (sum, t) => sum + t.returnCost);
    final etcSaving = processedTolls.fold(0.0, (sum, t) => sum + (t.singleCost - t.returnCost));

    return TollResult(
      plazas: processedTolls,
      singleTripTotal: singleTotal,
      roundTripTotal: roundTotal,
      etcDiscount: etcSaving,
      tollFreeAlternativeAvailable: tolls.length > 2,
    );
  }

  String _routeKey(String origin, String dest) {
    final o = origin.toLowerCase().replaceAll(' ', '');
    final d = dest.toLowerCase().replaceAll(' ', '');
    // Check both directions
    final k1 = '${o}_$d';
    final k2 = '${d}_$o';
    if (_routeTolls.containsKey(k1)) return k1;
    if (_routeTolls.containsKey(k2)) return k2;
    return '';
  }

  double _vehicleMultiplier(String vehicle) {
    if (vehicle.toLowerCase().contains('two') || vehicle.toLowerCase().contains('bike')) return 0.5;
    if (vehicle.toLowerCase().contains('bus') || vehicle.toLowerCase().contains('truck')) return 2.0;
    return 1.0; // car default
  }

  List<Map<String, dynamic>> _generateTolls(String origin, String dest) {
    final rng = Random(origin.hashCode + dest.hashCode);
    final count = 2 + rng.nextInt(4);
    final tolls = <Map<String, dynamic>>[];
    for (var i = 0; i < count; i++) {
      tolls.add({
        'name': '${_tollNames[rng.nextInt(_tollNames.length)]} Toll Plaza',
        'km': 40 + (i * (80 + rng.nextInt(60))),
        'cost': 45 + rng.nextInt(50),
        'type': 'single',
      });
    }
    return tolls;
  }

  static const _tollNames = [
    'National Highway', 'State Highway', 'Bypass',
    'Ring Road', 'Express Highway', 'Corridor',
  ];
}

class TollPlaza {
  final String name;
  final int kmFromOrigin;
  final double singleCost;
  final double returnCost;
  final bool hasFASTag;

  const TollPlaza({
    required this.name,
    required this.kmFromOrigin,
    required this.singleCost,
    required this.returnCost,
    required this.hasFASTag,
  });
}

class TollResult {
  final List<TollPlaza> plazas;
  final double singleTripTotal;
  final double roundTripTotal;
  final double etcDiscount;
  final bool tollFreeAlternativeAvailable;

  const TollResult({
    required this.plazas,
    required this.singleTripTotal,
    required this.roundTripTotal,
    required this.etcDiscount,
    required this.tollFreeAlternativeAvailable,
  });
}
