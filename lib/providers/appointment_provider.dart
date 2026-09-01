import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../repositories/appointment_repository.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentRepository _repository;

  AppointmentProvider(this._repository);

  // Flow Data
  String nic = '';
  String fullName = '';
  String phoneNumber = '';
  String selectedService = '';
  String selectedDistrict = '';
  String selectedDate = '';
  String selectedTimeSlot = '';

  List<String> availableSlots = [];
  List<AppointmentModel> myBookings = [];
  bool isLoading = false;

  AppointmentModel? get activeBooking =>
      myBookings.isNotEmpty ? myBookings.last : null;

  void updateApplicantDetails({
    required String nic,
    required String fullName,
    required String phone,
  }) {
    this.nic = nic;
    this.fullName = fullName;
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
    phoneNumber = '';
    resetSelection();
  }
}
