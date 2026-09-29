import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../repositories/appointment_repository.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentRepository _repository;

  AppointmentProvider(this._repository);

  // Flow Data
  String nic = '';
  String fullName = '';
  String dob = '';
  String phoneNumber = '';
  String selectedService = '';
  String selectedDistrict = '';
  String selectedDate = '';
  String selectedTimeSlot = '';
  int totalMorningCapacity = 30;
  int totalAfternoonCapacity = 20;

  List<String> availableSlots = [];
  List<AppointmentModel> myBookings = [];
  bool isLoading = false;

  // My Bookings screen state. Kept separate from `isLoading`, which the slot
  // picker and the CONFIRM BOOKING button already use.
  bool isLoadingBookings = false;
  String? bookingsError;

  AppointmentModel? get activeBooking =>
      myBookings.isNotEmpty ? myBookings.last : null;

  void updateApplicantDetails({
    required String nic,
    required String fullName,
    required String dob,
    required String phone,
  }) {
    this.nic = nic;
    this.fullName = fullName;
    this.dob = dob;
    this.phoneNumber = phone;
    notifyListeners();
  }

  void updateServiceAndDistrict({
    required String service,
    required String district,
  }) {
    selectedService = service;
    selectedDistrict = district;
    notifyListeners();
  }

  Future<void> fetchSlotsForDate(String date) async {
    selectedDate = date;
    isLoading = true;
    notifyListeners();

    try {
      availableSlots = await _repository.fetchAvailableSlots(
        selectedDistrict,
        date,
      );
    } catch (e) {
      availableSlots = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectSlot(String slot) {
    selectedTimeSlot = slot;
    notifyListeners();
  }

  Future<bool> confirmCurrentBooking() async {
    isLoading = true;
    notifyListeners();

    final int nextSequence = myBookings.length + 1;
    final String generatedCounterNumber = nextSequence.toString().padLeft(
      2,
      '0',
    );
    final String generatedTokenNumber =
        'T-${nextSequence.toString().padLeft(3, '0')}';

    final appointment = AppointmentModel(
      nic: nic,
      fullName: fullName,
      dob: dob,
      phoneNumber: phoneNumber,
      service: selectedService,
      district: selectedDistrict,
      date: selectedDate,
      timeSlot: selectedTimeSlot,
      counterNumber: generatedCounterNumber,
      tokenNumber: generatedTokenNumber,
    );

    bool success = false;
    try {
      success = await _repository.confirmBooking(appointment);
      if (success) {
        myBookings.add(appointment);
        resetSelection(); // Call class-level reset method on success
      }
    } catch (e) {
      success = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }

    return success;
  }

  /// Loads bookings through the repository (mock today, backend later) and
  /// merges them into [myBookings]. Additive only: nothing is removed or
  /// reordered, so [activeBooking] keeps behaving as before.
  Future<void> loadMyBookings() async {
    // The repository looks bookings up by NIC, which is only known once the
    // applicant form has been filled. Until then show what we already have.
    if (nic.isEmpty) return;

    isLoadingBookings = true;
    bookingsError = null;
    notifyListeners();

    try {
      final fetched = await _repository.fetchUserBookings(nic);

      String keyOf(AppointmentModel b) => '${b.nic}|${b.date}|${b.timeSlot}';
      final existingKeys = myBookings.map(keyOf).toSet();
      for (final booking in fetched) {
        if (existingKeys.add(keyOf(booking))) {
          myBookings.add(booking);
        }
      }
    } catch (e) {
      bookingsError =
          'Could not load your bookings. Please check your connection and try again.';
    } finally {
      isLoadingBookings = false;
      notifyListeners();
    }
  }

  /// Class-level method to reset active booking selections
  void resetSelection() {
    selectedService = '';
    selectedDistrict = '';
    selectedDate = '';
    selectedTimeSlot = '';
    availableSlots = [];
    notifyListeners();
  }

  /// Class-level method to completely reset user details and flow
  void clearAll() {
    nic = '';
    fullName = '';
    dob = '';
    phoneNumber = '';
    resetSelection();
  }
}
