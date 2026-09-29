import 'appointment_repository.dart';
import '../models/appointment_model.dart';

class MockAppointmentRepository implements AppointmentRepository {
  final List<AppointmentModel> _mockBookings = [];

  // In-memory slot storage per date string (e.g. "2026-09-28")
  final Map<String, List<String>> _bookedSlotsByDate = {};

  static const List<String> _initialMorningSlots = [
    '08:30 AM',
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
  ];

  static const List<String> _initialAfternoonSlots = [
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
  ];

  @override
  Future<List<String>> fetchAvailableSlots(String district, String date) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final booked = _bookedSlotsByDate[date] ?? [];

    final allSlots = [..._initialMorningSlots, ..._initialAfternoonSlots];
    return allSlots.where((slot) => !booked.contains(slot)).toList();
  }

  @override
  Future<bool> confirmBooking(AppointmentModel appointment) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _mockBookings.add(appointment);

    // Track the booked slot dynamically for this date
    final dateKey = appointment.date;
    _bookedSlotsByDate.putIfAbsent(dateKey, () => []);
    if (!_bookedSlotsByDate[dateKey]!.contains(appointment.timeSlot)) {
      _bookedSlotsByDate[dateKey]!.add(appointment.timeSlot);
    }
    return true;
  }

  @override
  Future<List<AppointmentModel>> fetchUserBookings(String nic) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockBookings.where((b) => b.nic == nic).toList();
  }
}
