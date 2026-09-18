class Driver {
  final int? id;
  final String fullName;
  final String driverNumber;
  final String passport;
  final String truckPlate;
  final String truckModel;
  final String status; // 'idle' | 'enroute'
  final String routeFrom;
  final String routeTo;
  final String updatedAt;

  const Driver({
    this.id,
    required this.fullName,
    required this.driverNumber,
    required this.passport,
    required this.truckPlate,
    required this.truckModel,
    this.status = 'idle',
    this.routeFrom = '',
    this.routeTo = '',
    required this.updatedAt,
  });

  Driver copyWith({
    int? id,
    String? fullName,
    String? driverNumber,
    String? passport,
    String? truckPlate,
    String? truckModel,
    String? status,
    String? routeFrom,
    String? routeTo,
    String? updatedAt,
  }) {
    return Driver(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      driverNumber: driverNumber ?? this.driverNumber,
      passport: passport ?? this.passport,
      truckPlate: truckPlate ?? this.truckPlate,
      truckModel: truckModel ?? this.truckModel,
      status: status ?? this.status,
      routeFrom: routeFrom ?? this.routeFrom,
      routeTo: routeTo ?? this.routeTo,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'driver_number': driverNumber,
      'passport': passport,
      'truck_plate': truckPlate,
      'truck_model': truckModel,
      'status': status,
      'route_from': routeFrom,
      'route_to': routeTo,
      'updated_at': updatedAt,
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      driverNumber: map['driver_number'] as String,
      passport: map['passport'] as String,
      truckPlate: map['truck_plate'] as String,
      truckModel: map['truck_model'] as String,
      status: map['status'] as String,
      routeFrom: map['route_from'] as String? ?? '',
      routeTo: map['route_to'] as String? ?? '',
      updatedAt: map['updated_at'] as String,
    );
  }
}
