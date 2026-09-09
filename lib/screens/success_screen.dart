import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_color.dart';
import '../core/constants/app_sizes.dart';
//import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';
import '../widgets/custom_button.dart';
import 'applicant_details_screen.dart';
import 'home_screen.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final booking = appointmentProvider.activeBooking;

    // Formatting date to YYYY/MM/DD format
    final formattedDate = (booking?.date ?? appointmentProvider.selectedDate)
        .replaceAll(' - ', '/')
        .replaceAll('-', '/');

    final name = booking?.userName.isNotEmpty == true
        ? booking!.userName
        : appointmentProvider.fullName;

    final nic = booking?.nicNumber.isNotEmpty == true
        ? booking!.nicNumber
        : appointmentProvider.nic;

    final service = booking?.serviceName.isNotEmpty == true
        ? booking!.serviceName
        : appointmentProvider.selectedService;

    final district = booking?.location.isNotEmpty == true
        ? booking!.location
        : appointmentProvider.selectedDistrict;

    final timeSlot = booking?.timeSlot.isNotEmpty == true
        ? booking!.timeSlot
        : appointmentProvider.selectedTimeSlot;

    final tokenNo = booking?.tokenNumber ?? '15';
    final counterNo = '06';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.md,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSizes.sm),

              // Success Green Checkmark Icon
              Container(
                width: AppSizes.buttonHeight,
                height: AppSizes.buttonHeight,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: AppSizes.iconLarge,
                ),
              ),
              const SizedBox(height: AppSizes.sm),

              // Title (Grammatically Corrected)
              const Text(
                'Booking Successful!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizes.textSubtitle,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: AppSizes.xxs),
              const Text(
                'Your booking is complete. We look forward to serving you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizes.textCaption,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Assignment & Details Receipt Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryMaroon,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR ASSIGNMENT',
                      style: TextStyle(
                        fontSize: AppSizes.textCaption,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),

                    // Counter & Token Box Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildAssignmentBox(
                            label: 'COUNTER',
                            value: counterNo,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: _buildAssignmentBox(
                            label: '#TOKEN',
                            value: tokenNo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),

                    Center(
                      child: Text(
                        'Go to Counter $counterNo and wait for token #$tokenNo to be called',
                        style: const TextStyle(
                          fontSize: AppSizes.textCaption,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: AppSizes.md),

                    // Real-World Appointment Details List
                    _buildReceiptDetailRow('Name', name),
                    _buildReceiptDetailRow('NIC', nic),
                    _buildReceiptDetailRow('Service', service),
                    _buildReceiptDetailRow('District Office', district),
                    _buildReceiptDetailRow(
                      'Date',
                      formattedDate.isNotEmpty ? formattedDate : '2026/08/28',
                    ),
                    _buildReceiptDetailRow(
                      'Time Slot',
                      timeSlot.isNotEmpty ? timeSlot : 'Morning Session',
                    ),

                    const SizedBox(height: AppSizes.md),

                    // SMS Notice Box
                    Container(
                      padding: const EdgeInsets.all(AppSizes.xs),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white70,
                            size: AppSizes.iconSmall,
                          ),
                          SizedBox(width: AppSizes.xs),
                          Expanded(
                            child: Text(
                              'You will receive a SMS when your token is called. No need to watch the counter continuously.',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              // Export PDF Option Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  border: Border.all(color: AppColors.inputBorder, width: 1.2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Appointment Confirmation Document',
                      style: TextStyle(
                        fontSize: AppSizes.textBody,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xxs),
                    const Text(
                      'Download your appointment receipt for offline submission at the reception desk.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppSizes.textCaption,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    CustomButton(
                      text: 'DOWNLOAD PDF',
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      icon: Icons.download_outlined,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Downloading appointment receipt PDF...',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // Reminder Banner Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remember for your appointment day',
                      style: TextStyle(
                        fontSize: AppSizes.textCaption,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                    SizedBox(height: AppSizes.xs),
                    _ReminderItem(text: 'Arrive at least 15 minutes early.'),
                    _ReminderItem(
                      text: 'Bring all original required documents and copies.',
                    ),
                    _ReminderItem(
                      text: 'Bring your original NIC or valid Passport.',
                    ),
                    _ReminderItem(
                      text:
                          'Present your downloaded PDF receipt at the entrance.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              // Book Another Appointment Outlined Button
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: OutlinedButton(
                  onPressed: () {
                    appointmentProvider.resetSelection();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ApplicantDetailsScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primaryMaroon,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                  child: const Text(
                    'Book Another Appointment',
                    style: TextStyle(
                      color: AppColors.primaryMaroon,
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.textBody,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.xs),

              // Return to Home Text Button
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Return to Home',
                  style: TextStyle(
                    color: AppColors.primaryMaroon,
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.textBody,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentBox({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppSizes.textTitle,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppSizes.textCaption,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppSizes.textCaption,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderItem extends StatelessWidget {
  final String text;
  const _ReminderItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(color: Color(0xFF8D6E63), fontSize: 11),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: Color(0xFF5D4037)),
            ),
          ),
        ],
      ),
    );
  }
}
