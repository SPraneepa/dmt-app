class AppointmentModel {
  final String? id;
  final String nic;
  final String fullName;
  final String phoneNumber;
  final String service;
  final String district;
  final String date;
  final String timeSlot;
  final String? counterNumber;
  final String? tokenNumber;

  AppointmentModel({
    this.id,
    required this.nic,
    required this.fullName,
    required this.phoneNumber,
    required this.service,
    required this.district,
    required this.date,
    required this.timeSlot,
    this.counterNumber,
    this.tokenNumber,
  });

  // Getters for HomeScreen compatibility
  String get userName => fullName;
  String get nicNumber => nic;
  String get serviceName => service;
  String get location => district;
  String get estimatedTime => timeSlot;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nic': nic,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'service': service,
      'district': district,
      'date': date,
      'timeSlot': timeSlot,
      'counterNumber': counterNumber,
      'tokenNumber': tokenNumber,
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      nic: json['nic'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      service: json['service'] ?? '',
      district: json['district'] ?? '',
      date: json['date'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
      counterNumber: json['counterNumber']?.toString(),
      tokenNumber: json['tokenNumber']?.toString(),
    );
  }
}
