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

    availableSlots = await _repository.fetchAvailableSlots(
      selectedDistrict,
      date,
    );
    isLoading = false;
    notifyListeners();
  }

  void selectSlot(String slot) {
    selectedTimeSlot = slot;
    notifyListeners();
  }

  Future<bool> confirmCurrentBooking() async {
    isLoading = true;
    notifyListeners();

    final appointment = AppointmentModel(
      nic: nic,
      fullName: fullName,
      phoneNumber: phoneNumber,
      service: selectedService,
      district: selectedDistrict,
      date: selectedDate,
      timeSlot: selectedTimeSlot,
    );

    final success = await _repository.confirmBooking(appointment);
    if (success) {
      myBookings.add(appointment);
    }

    isLoading = false;
    notifyListeners();
    return success;
  }
}
