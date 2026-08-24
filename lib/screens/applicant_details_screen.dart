import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../providers/appointment_provider.dart';
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
  final _phoneController = TextEditingController();

  bool _isPhoneVerified = false;

  @override
  void dispose() {
    _nicController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showOtpModal() {
    final otpController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verify Phone Number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryMaroon,
              ),
            ),
            const SizedBox(height: 8),
            Text('Enter the 4-digit code sent to ${_phoneController.text}'),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'OTP Code (Enter 1234)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMaroon,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
                child: const Text(
                  'Verify',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryMaroon,
        title: const Text(
          'Department of Motor Traffic',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Applicant Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMaroon,
                ),
              ),
              const SizedBox(height: 20),

              // Personal Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nicController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9vVxX]')),
                        LengthLimitingTextInputFormatter(12),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'NIC Number',
                        hintText: '123456789V or 199012345678',
                        border: OutlineInputBorder(),
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
                          return 'Enter valid NIC (e.g. 123456789V or 199012345678)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s\.]'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Full Name (as on NIC)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter full name'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Contact & Verification Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact & Verification',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '07X XXXXXXX',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Enter phone number';
                        }
                        final phoneRegex = RegExp(r'^07[0-9]{8}$');
                        if (!phoneRegex.hasMatch(v)) {
                          return 'Phone number must start with 07 and have 10 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _isPhoneVerified
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'Phone Verified',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              side: const BorderSide(
                                color: AppColors.primaryMaroon,
                              ),
                            ),
                            onPressed: () {
                              final phoneRegex = RegExp(r'^07[0-9]{8}$');
                              if (phoneRegex.hasMatch(_phoneController.text)) {
                                _showOtpModal();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Enter a valid 10-digit phone number starting with 07.',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Send OTP Code',
                              style: TextStyle(color: AppColors.primaryMaroon),
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMaroon,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _onNextPressed,
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
