class AppointmentModel {
  final String? id;
  final String nic;
  final String fullName;
  final String phoneNumber;
  final String service;
  final String district;
  final String date;
  final String timeSlot;

  AppointmentModel({
    this.id,
    required this.nic,
    required this.fullName,
    required this.phoneNumber,
    required this.service,
    required this.district,
    required this.date,
    required this.timeSlot,
  });

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
    );
  }
}
