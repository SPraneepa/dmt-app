import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_color.dart';
import '../core/constants/app_sizes.dart';
import '../providers/appointment_provider.dart';
import '../widgets/custom_button.dart';
import 'success_screen.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  bool _agreedToTerms = false;

  void _onConfirmPressed() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the booking terms to confirm.'),
        ),
      );
      return;
    }

    final provider = context.read<AppointmentProvider>();
    final success = await provider.confirmCurrentBooking();

    if (!mounted) return;

    if (success) {
      final formattedDate = provider.selectedDate
          .replaceAll(' ', '')
          .replaceAll('-', '/');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'SMS Sent: Appointment confirmed for $formattedDate at ${provider.selectedTimeSlot}',
          ),
          backgroundColor: Colors.green.shade800,
          duration: const Duration(seconds: 4),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SuccessScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to confirm appointment. Please try again.'),
        ),
      );
    }
  }

  PreferredSizeWidget _buildHeaderAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 80,
      title: _buildStepIndicator(),
    );
  }

  Widget _buildStepIndicator() {
    final steps = [
      {'title': 'Personal Info', 'icon': Icons.check},
      {'title': 'Service Selecti...', 'icon': Icons.assignment_outlined},
      {'title': 'Date/Time', 'icon': Icons.calendar_today_outlined},
      {'title': 'Confirmation', 'icon': Icons.check_circle_outline},
    ];

    const int currentStep = 3; // Step 4 (0-indexed) highlighted

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;

          Color activeColor = AppColors.primaryMaroon;
          Color inactiveColor = Colors.grey.shade400;

          IconData? iconData = steps[index]['icon'] as IconData?;
          if (isCompleted && index == 0) {
            iconData = Icons.check;
          }

          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == 0
                            ? Colors.transparent
                            : (index <= currentStep
                                  ? activeColor
                                  : inactiveColor),
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive || isCompleted
                            ? activeColor
                            : inactiveColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: iconData != null
                            ? Icon(iconData, size: 14, color: Colors.white)
                            : Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == steps.length - 1
                            ? Colors.transparent
                            : (index < currentStep
                                  ? activeColor
                                  : inactiveColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  steps[index]['title'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppSizes.textCaption,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? activeColor : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();

    // Format dates to YYYY/MM/DD and remove all whitespace
    final formattedAppointmentDate = provider.selectedDate.isNotEmpty
        ? provider.selectedDate.replaceAll(' ', '').replaceAll('-', '/')
        : '--';

    final formattedDob = provider.dob.isNotEmpty
        ? provider.dob.replaceAll(' ', '').replaceAll('-', '/')
        : '--';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildHeaderAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'View information & confirm booking',
              style: TextStyle(
                fontSize: AppSizes.textSubtitle,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            const Text(
              'Check the details below before confirming. Once booked, you\'ll receive a SMS confirmation.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.textCaption,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // APPLICANT CARD
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.inputBorder, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'APPLICANT',
                    style: TextStyle(
                      fontSize: AppSizes.textCaption,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHint,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildIconDetailRow(
                    icon: Icons.person_outline,
                    value: provider.fullName.isNotEmpty
                        ? provider.fullName
                        : '--',
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildIconDetailRow(
                    icon: Icons.badge_outlined,
                    value: provider.nic.isNotEmpty ? provider.nic : '--',
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildIconDetailRow(
                    icon: Icons.phone_outlined,
                    value: provider.phoneNumber.isNotEmpty
                        ? provider.phoneNumber
                        : '--',
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildIconDetailRow(
                    icon: Icons.cake_outlined,
                    value: formattedDob,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.md),

            // APPOINTMENT CARD
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.inputBorder, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'APPOINTMENT',
                    style: TextStyle(
                      fontSize: AppSizes.textCaption,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHint,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildIconDetailRow(
                    icon: Icons.directions_car_outlined,
                    value: provider.selectedService.isNotEmpty
                        ? provider.selectedService
                        : '--',
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildIconDetailRow(
                    icon: Icons.apartment_outlined,
                    value: provider.selectedDistrict.isNotEmpty
                        ? provider.selectedDistrict
                        : '--',
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildIconDetailRow(
                    icon: Icons.calendar_today_outlined,
                    value: formattedAppointmentDate,
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildIconDetailRow(
                    icon: Icons.wb_sunny_outlined,
                    value: provider.selectedTimeSlot.isNotEmpty
                        ? provider.selectedTimeSlot
                        : '--',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // TERMS CHECKBOX ROW
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: AppSizes.iconLarge,
                  width: AppSizes.iconLarge,
                  child: Checkbox(
                    value: _agreedToTerms,
                    activeColor: AppColors.primaryMaroon,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusSm / 2,
                      ),
                    ),
                    onChanged: (v) =>
                        setState(() => _agreedToTerms = v ?? false),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                const Expanded(
                  child: Text(
                    'I confirm the above details are correct and I agree to the DMT booking terms. I understand that no-shows may result in a temporary ban from online booking.',
                    style: TextStyle(
                      fontSize: AppSizes.textCaption,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.xl),

            // ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppSizes.buttonHeight,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.primaryMaroon,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                      ),
                      child: const Text(
                        'BACK',
                        style: TextStyle(
                          color: AppColors.primaryMaroon,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.textBody,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: CustomButton(
                    text: 'CONFIRM BOOKING',
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    isLoading: provider.isLoading,
                    onPressed: _onConfirmPressed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconDetailRow({required IconData icon, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: AppSizes.iconMedium, color: AppColors.textHint),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: AppSizes.textBody,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
