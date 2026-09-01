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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.md,
            left: AppSizes.lg,
            right: AppSizes.lg,
            top: AppSizes.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verify Phone Number',
                style: TextStyle(
                  fontSize: AppSizes.textSubtitle,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMaroon,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                'Enter the 4-digit code sent to ${_phoneController.text}',
                style: const TextStyle(
                  fontSize: AppSizes.textBody,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppSizes.textBody,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  labelText: 'OTP Code (Enter 1234)',
                  labelStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: AppColors.inputFill,
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
                        content: Text('Phone number verified successfully!'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
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
            content: Text('Please verify your phone number before proceeding.'),
          ),
        );
        return;
      }

      context.read<AppointmentProvider>().updateApplicantDetails(
        nic: _nicController.text.trim(),
        fullName: _nameController.text.trim(),
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
      padding: const EdgeInsets.only(bottom: AppSizes.xxs),
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

  InputDecoration _buildInputDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColors.textHint,
        fontSize: AppSizes.textBody,
      ),
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(
          color: AppColors.primaryMaroon,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: Colors.red, width: 1.6),
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
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primaryMaroon,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
            ),
            const SizedBox(width: AppSizes.xxs),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSizes.xxs),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSizes.xxs),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
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
              const Text(
                'Enter applicant personal information',
                style: TextStyle(
                  fontSize: AppSizes.textSubtitle,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.lg),

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
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\.]')),
                ],
                decoration: _buildInputDecoration(
                  'Rajapaksha Pathirage Kamal Perera',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter full name' : null,
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
                decoration: _buildInputDecoration('98XXXXXXXXV/ 200XXXXXXXXX'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter NIC number';
                  final nic = v.trim();
                  final nicRegex = RegExp(r'^([0-9]{9}[vVxX]|[0-9]{12})$');
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
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
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
                    flex: 3,
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
                      decoration: _buildInputDecoration('07X XXXXXXX'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter phone number';
                        final phoneRegex = RegExp(r'^07[0-9]{8}$');
                        if (!phoneRegex.hasMatch(v)) return 'Invalid phone';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: _isPhoneVerified
                        ? const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSizes.sm,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'VERIFIED',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppSizes.textCaption,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : TextButton(
                            onPressed: () {
                              final phoneRegex = RegExp(r'^07[0-9]{8}$');
                              if (phoneRegex.hasMatch(_phoneController.text)) {
                                _showOtpModal();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Enter a valid 10-digit number starting with 07.',
                                    ),
                                  ),
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm,
                                vertical: AppSizes.sm,
                              ),
                            ),
                            child: const Text(
                              'SEND OTP',
                              style: TextStyle(
                                color: AppColors.primaryMaroon,
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes.textCaption,
                              ),
                            ),
                          ),
                  ),
                ],
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
            ],
          ),
        ),
      ),
    );
  }
}
