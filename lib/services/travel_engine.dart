import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class TravelEngine {
  // Average fuel prices in India
  static const double petrolPrice = 101.0;
  static const double dieselPrice = 88.0;
  static const double evPricePerUnit = 10.0;

  // Fetch real distance and time using Nominatim (Geocoding) and OSRM (Routing)
  static Future<Map<String, double>> fetchTravelData(String origin, String destination) async {
    try {
      // 1. Geocode Origin
      final originRes = await http.get(Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(origin)}&format=json&limit=1'));
      // 2. Geocode Destination
      final destRes = await http.get(Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(destination)}&format=json&limit=1'));

      if (originRes.statusCode == 200 && destRes.statusCode == 200) {
        final originData = jsonDecode(originRes.body);
        final destData = jsonDecode(destRes.body);

        if (originData.isNotEmpty && destData.isNotEmpty) {
          final lat1 = originData[0]['lat'];
          final lon1 = originData[0]['lon'];
          final lat2 = destData[0]['lat'];
          final lon2 = destData[0]['lon'];

          // 3. Get Route from OSRM
          final routeUrl = 'https://router.project-osrm.org/route/v1/driving/$lon1,$lat1;$lon2,$lat2?overview=false';
          final routeRes = await http.get(Uri.parse(routeUrl));

          if (routeRes.statusCode == 200) {
            final routeData = jsonDecode(routeRes.body);
            if (routeData['routes'] != null && routeData['routes'].isNotEmpty) {
              final distanceMeters = routeData['routes'][0]['distance'] as num;
              final durationSeconds = routeData['routes'][0]['duration'] as num;

              return {
                'distance': distanceMeters / 1000.0, // Convert to km
                'time': durationSeconds / 3600.0,     // Convert to hours
                'dest_lat': double.parse(lat2.toString()),
                'dest_lon': double.parse(lon2.toString()),
                'orig_lat': double.parse(lat1.toString()),
                'orig_lon': double.parse(lon1.toString()),
              };
            }
          }
        }
      }
    } catch (e) {
      print("Routing error: $e");
    }
    
    // Fallback if APIs fail
    return {'distance': 350.0, 'time': 6.5};
  }

  static double calculateFuelCost(double distance, double mileage, String fuelType) {
    double price = petrolPrice;
    if (fuelType == 'Diesel') price = dieselPrice;
    if (fuelType == 'EV') return (distance / 5.0) * evPricePerUnit;
    
    return (distance / (mileage > 0 ? mileage : 15.0)) * price;
  }

  static double estimateCarbonFootprint(double distance, String fuelType) {
    double co2PerKm = 0.17; 
    if (fuelType == 'Diesel') co2PerKm = 0.19;
    if (fuelType == 'EV') co2PerKm = 0.05; 
    
    return distance * co2PerKm;
  }

  static double estimateTolls(double distance) {
    return distance * 1.5;
  }

  static double estimateLodgingCost(int days, int members, String lodgingType) {
    double baseRate = 2000.0;
    if (lodgingType == 'Homestay') baseRate = 1200.0;
    if (lodgingType == 'Resort') baseRate = 5000.0;
    
    int rooms = (members / 2).ceil();
    return baseRate * rooms * days;
  }

  // Deprecated - use fetchTravelData
  static Future<double> fetchDistance(String origin, String destination) async {
    final data = await fetchTravelData(origin, destination);
    return data['distance'] ?? 250.0;
  }
}
