import '../models/appointment_model.dart';

abstract class AppointmentRepository {
  Future<List<String>> fetchAvailableSlots(String district, String date);
  Future<bool> confirmBooking(AppointmentModel appointment);
  Future<List<AppointmentModel>> fetchUserBookings(String nic);
}
