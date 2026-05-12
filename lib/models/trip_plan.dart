class TripPlan {
  String tripType; // Solo, Family, Group
  String origin;
  String destination;
  double vehicleMileage;
  String fuelType; // Petrol, Diesel, EV
  String vehicleType; // Car, Bike
  List<String> moods;
  double budget;
  String routePreference; // Fuel Efficient, Fastest
  String lodgingPreference; // Hotel, Homestay, Resort
  String? selectedHotel;
  List<String> selectedAttractions;
  int memberCount;

  TripPlan({
    this.tripType = 'Solo',
    this.origin = '',
    this.destination = '',
    this.vehicleMileage = 15.0,
    this.fuelType = 'Petrol',
    this.vehicleType = 'Car',
    this.moods = const [],
    this.selectedAttractions = const [],
    this.budget = 10000.0,
    this.routePreference = 'Fastest',
    this.lodgingPreference = 'All',
    this.selectedHotel,
    this.memberCount = 1,
  });
}
