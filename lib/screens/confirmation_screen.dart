import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_color.dart';
import '../core/constants/app_sizes.dart';
import '../providers/appointment_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/dmt_ui.dart';
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
          behavior: SnackBarBehavior.floating,
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
          behavior: SnackBarBehavior.floating,
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
          behavior: SnackBarBehavior.floating,
          content: Text('Failed to confirm appointment. Please try again.'),
        ),
      );
    }
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
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.lg,
                AppSizes.md,
                AppSizes.lg,
                AppSizes.sm,
              ),
              child: DmtStepHeader(currentStep: 3),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.sm,
                  AppSizes.lg,
                  AppSizes.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DmtHeroBanner(
                      icon: Icons.fact_check_outlined,
                      title: 'View information & confirm booking',
                      subtitle:
                          'Check the details below before confirming. Once booked, you\'ll receive a SMS confirmation.',
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // APPLICANT CARD
                    DmtCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Applicant'),
                          const SizedBox(height: AppSizes.md),
                          _buildIconDetailRow(
                            icon: Icons.person_outline,
                            label: 'Full name',
                            value: provider.fullName.isNotEmpty
                                ? provider.fullName
                                : '--',
                          ),
                          _buildRowDivider(),
                          _buildIconDetailRow(
                            icon: Icons.badge_outlined,
                            label: 'NIC',
                            value: provider.nic.isNotEmpty
                                ? provider.nic
                                : '--',
                          ),
                          _buildRowDivider(),
                          _buildIconDetailRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: provider.phoneNumber.isNotEmpty
                                ? provider.phoneNumber
                                : '--',
                          ),
                          _buildRowDivider(),
                          _buildIconDetailRow(
                            icon: Icons.cake_outlined,
                            label: 'Birth date',
                            value: formattedDob,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.md),

                    // APPOINTMENT CARD
                    DmtCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Appointment'),
                          const SizedBox(height: AppSizes.md),
                          _buildIconDetailRow(
                            icon: Icons.directions_car_outlined,
                            label: 'Service',
                            value: provider.selectedService.isNotEmpty
                                ? provider.selectedService
                                : '--',
                          ),
                          _buildRowDivider(),
                          _buildIconDetailRow(
                            icon: Icons.apartment_outlined,
                            label: 'Office',
                            value: provider.selectedDistrict.isNotEmpty
                                ? provider.selectedDistrict
                                : '--',
                          ),
                          _buildRowDivider(),
                          _buildIconDetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Date',
                            value: formattedAppointmentDate,
                          ),
                          _buildRowDivider(),
                          _buildIconDetailRow(
                            icon: Icons.wb_sunny_outlined,
                            label: 'Time slot',
                            value: provider.selectedTimeSlot.isNotEmpty
                                ? provider.selectedTimeSlot
                                : '--',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.lg),

                    // TERMS CHECKBOX ROW (whole row is tappable)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        onTap: () =>
                            setState(() => _agreedToTerms = !_agreedToTerms),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.xs,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _agreedToTerms,
                                activeColor: AppColors.primaryMaroon,
                                side: const BorderSide(
                                  color: kDmtFieldBorder,
                                  width: 1.6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusSm / 2,
                                  ),
                                ),
                                onChanged: (v) =>
                                    setState(() => _agreedToTerms = v ?? false),
                              ),
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: AppSizes.md,
                                    right: AppSizes.sm,
                                  ),
                                  child: Text(
                                    'I confirm the above details are correct and I agree to the DMT booking terms. I understand that no-shows may result in a temporary ban from online booking.',
                                    style: TextStyle(
                                      fontSize: AppSizes.textCaption,
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DmtActionBar(
        onBack: () => Navigator.pop(context),
        primary: CustomButton(
          text: 'CONFIRM BOOKING',
          width: double.infinity,
          height: AppSizes.buttonHeight,
          isLoading: provider.isLoading,
          onPressed: _onConfirmPressed,
        ),
      ),
    );
  }

  Widget _buildRowDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Divider(height: 1, color: AppColors.divider),
    );
  }

  Widget _buildIconDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(
              icon,
              size: AppSizes.iconMedium,
              color: AppColors.primarySoft,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: AppSizes.textCaption,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: AppSizes.textBody,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppSizes.textLabel,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryMaroon,
        ),
      ),
    );
  }
}
