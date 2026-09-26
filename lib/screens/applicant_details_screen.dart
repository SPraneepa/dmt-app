import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_color.dart';
import '../core/constants/app_sizes.dart';
import '../providers/appointment_provider.dart';
import '../widgets/custom_button.dart';
import 'service_selection_screen.dart';

class ApplicantDetailsScreen extends StatefulWidget {
  const ApplicantDetailsScreen({super.key});

  @override
  State<ApplicantDetailsScreen> createState() => _ApplicantDetailsScreenState();
}

class _ApplicantDetailsScreenState extends State<ApplicantDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isPhoneVerified = false;

  // UI constant: height shared by inputs and the phone-row action
  static const double _fieldHeight = 52;

  @override
  void dispose() {
    _nicController.dispose();
    _nameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showOtpModal() {
    final otpController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg + 8),
        ),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.md,
            left: AppSizes.lg,
            right: AppSizes.lg,
            top: AppSizes.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              const Text(
                'Verify Phone Number',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizes.textSubtitle,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryMaroon,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                'Enter the 4-digit code sent to ${_phoneController.text}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppSizes.textBody,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  letterSpacing: 10,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: 'OTP Code (Enter 1234)',
                  labelStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                    fontSize: AppSizes.textBody,
                  ),
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSizes.md,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    borderSide: const BorderSide(
                      color: AppColors.primaryMaroon,
                      width: 1.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              CustomButton(
                text: 'Verify',
                width: double.infinity,
                height: AppSizes.buttonHeight,
                onPressed: () {
                  if (otpController.text == '1234') {
                    setState(() {
                      _isPhoneVerified = true;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('Phone number verified successfully!'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text('Invalid OTP. Use 1234 for demo.'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNextPressed() {
    if (_formKey.currentState!.validate()) {
      if (!_isPhoneVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Please verify your phone number before proceeding.'),
          ),
        );
        return;
      }

      context.read<AppointmentProvider>().updateApplicantDetails(
        nic: _nicController.text.trim(),
        fullName: _nameController.text.trim(),
        dob: _birthDateController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ServiceSelectionScreen()),
      );
    }
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs, left: 2),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: AppSizes.textBody,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hintText, {
    Widget? suffixIcon,
    IconData? prefixIcon,
  }) {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      borderSide: BorderSide(color: color, width: width),
    );

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColors.textHint,
        fontSize: AppSizes.textBody,
      ),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon, size: 20, color: AppColors.primarySoft),
      suffixIcon: suffixIcon,
      enabledBorder: border(AppColors.border.withValues(alpha: 0.6), 1),
      focusedBorder: border(AppColors.primaryMaroon, 1.8),
      errorBorder: border(AppColors.error, 1.2),
      focusedErrorBorder: border(AppColors.error, 1.8),
      errorStyle: const TextStyle(
        color: AppColors.error,
        fontSize: AppSizes.textCaption,
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = [
      {'title': 'Personal Info', 'icon': Icons.person_outline},
      {'title': 'Service Selection', 'icon': null},
      {'title': 'Date/Time', 'icon': null},
      {'title': 'Confirmation', 'icon': null},
    ];

    const int currentStep = 0; // 0-indexed: Step 1 (Personal Info) is active

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                steps[currentStep]['title'] as String,
                style: const TextStyle(
                  fontSize: AppSizes.textBody,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryMaroon,
                ),
              ),
              Text(
                'Step ${currentStep + 1} of ${steps.length}',
                style: const TextStyle(
                  fontSize: AppSizes.textCaption,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs + 2),
          Row(
            children: List.generate(steps.length, (index) {
              final isReached = index <= currentStep;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 5,
                  margin: EdgeInsets.only(
                    right: index == steps.length - 1 ? 0 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: isReached
                        ? AppColors.primaryMaroon
                        : AppColors.border.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primarySoft],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.badge_outlined,
              color: AppColors.textLight,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          const Expanded(
            child: Text(
              'Enter applicant personal information',
              style: TextStyle(
                fontSize: AppSizes.textSubtitle,
                fontWeight: FontWeight.w700,
                color: AppColors.textLight,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      height: _fieldHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 18),
          SizedBox(width: 4),
          Text(
            'VERIFIED',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
              fontSize: AppSizes.textCaption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendOtpButton() {
    return SizedBox(
      height: _fieldHeight,
      child: FilledButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _showOtpModal();
          }
        },
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryMaroon,
          foregroundColor: AppColors.textLight,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
        child: const Text(
          'SEND OTP',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.textCaption,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 72,
        title: _buildStepIndicator(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.sm,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderBanner(),
              const SizedBox(height: AppSizes.lg),

              // Form card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    _buildFieldLabel('Full Name'),
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      style: const TextStyle(
                        fontSize: AppSizes.textBody,
                        color: AppColors.textPrimary,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s\.]'),
                        ),
                      ],
                      decoration: _buildInputDecoration(
                        'Rajapaksha Pathirage Kamal Perera',
                        prefixIcon: Icons.person_outline,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter full name'
                          : null,
                    ),
                    const SizedBox(height: AppSizes.md),

                    // National Identification Card (NIC)
                    _buildFieldLabel('National Identification Card (NIC)'),
                    TextFormField(
                      controller: _nicController,
                      style: const TextStyle(
                        fontSize: AppSizes.textBody,
                        color: AppColors.textPrimary,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9vVxX]')),
                        LengthLimitingTextInputFormatter(12),
                      ],
                      decoration: _buildInputDecoration(
                        '98XXXXXXXXV/ 200XXXXXXXXX',
                        prefixIcon: Icons.credit_card_outlined,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter NIC number';
                        }
                        final nic = v.trim();
                        final nicRegex = RegExp(
                          r'^([0-9]{9}[vVxX]|[0-9]{12})$',
                        );
                        if (!nicRegex.hasMatch(nic)) {
                          return 'Enter valid NIC';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Birth Date
                    _buildFieldLabel('Birth Date'),
                    TextFormField(
                      controller: _birthDateController,
                      readOnly: true,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Select birth date'
                          : null,
                      onTap: () async {
                        final nic = _nicController.text.trim();
                        final nicRegex = RegExp(
                          r'^([0-9]{9}[vVxX]|[0-9]{12})$',
                        );

                        if (nic.isEmpty || !nicRegex.hasMatch(nic)) {
                          return;
                        }

                        int initialYear = 2000;
                        if (nic.length == 10) {
                          final yearDigits = int.tryParse(nic.substring(0, 2));
                          if (yearDigits != null) {
                            initialYear = 1900 + yearDigits;
                          }
                        } else if (nic.length == 12) {
                          final yearDigits = int.tryParse(nic.substring(0, 4));
                          if (yearDigits != null) {
                            initialYear = yearDigits;
                          }
                        }

                        DateTime defaultDate = DateTime(initialYear, 1, 1);
                        if (defaultDate.isAfter(DateTime.now())) {
                          defaultDate = DateTime.now();
                        }

                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: defaultDate,
                          firstDate: DateTime(1930),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _birthDateController.text =
                                "${pickedDate.year}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                      style: const TextStyle(
                        fontSize: AppSizes.textBody,
                        color: AppColors.textPrimary,
                      ),
                      decoration: _buildInputDecoration(
                        'YYYY/MM/DD',
                        prefixIcon: Icons.cake_outlined,
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Phone Number & OTP Section
                    _buildFieldLabel('Phone Number'),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              fontSize: AppSizes.textBody,
                              color: AppColors.textPrimary,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: _buildInputDecoration(
                              '07X XXXXXXX',
                              prefixIcon: Icons.phone_outlined,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter phone number';
                              }
                              final phoneRegex = RegExp(r'^07[0-9]{8}$');
                              if (!phoneRegex.hasMatch(v)) {
                                return 'Invalid phone';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        _isPhoneVerified
                            ? _buildVerifiedBadge()
                            : _buildSendOtpButton(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Action Buttons Row (BACK & NEXT)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: AppSizes.buttonHeight,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.surface,
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
                      text: 'NEXT',
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      onPressed: _onNextPressed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}
