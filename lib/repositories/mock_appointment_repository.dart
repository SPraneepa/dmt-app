import 'appointment_repository.dart';
import '../models/appointment_model.dart';

class MockAppointmentRepository implements AppointmentRepository {
  final List<AppointmentModel> _mockBookings = [];

  @override
  Future<List<String>> fetchAvailableSlots(String district, String date) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      '09:30 AM',
      '10:00 AM',
      '11:00 AM',
      '11:30 AM',
      '01:00 PM',
      '01:30 PM',
      '02:00 PM',
      '02:30 PM',
    ];
  }

  @override
  Future<bool> confirmBooking(AppointmentModel appointment) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockBookings.add(appointment);
    return true;
  }

  @override
  Future<List<AppointmentModel>> fetchUserBookings(String nic) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockBookings.where((b) => b.nic == nic).toList();
  }
}
