import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../providers/appointment_provider.dart';
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
      // Simulate sending SMS notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'SMS Sent: Appointment confirmed for ${provider.selectedDate} at ${provider.selectedTimeSlot}',
          ),
          backgroundColor: Colors.green.shade800,
          duration: const Duration(seconds: 4),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SuccessScreen()),
        (route) =>
            false, // Clear stack so user can't navigate back into the booking flow
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to confirm appointment. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryMaroon,
        title: const Text(
          'Department of Motor Traffic - Sri Lanka',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'View Information and Confirm Appointment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryMaroon,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check the details below before confirming. Once booked, you\'ll receive an SMS confirmation.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Details Container
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
                    'APPLICANT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('NIC', provider.nic),
                  _buildDetailRow('Name', provider.fullName),
                  _buildDetailRow('Phone Number', provider.phoneNumber),
                  const Divider(height: 24),

                  const Text(
                    'APPOINTMENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Service', provider.selectedService),
                  _buildDetailRow('Office', provider.selectedDistrict),
                  const SizedBox(height: 16),

                  // Slot Highlight Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'YOUR SLOT',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Date',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              provider.selectedDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Time',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              provider.selectedTimeSlot,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'DMT-SL-REF-2026',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Checkbox consent
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _agreedToTerms,
                    activeColor: AppColors.primaryMaroon,
                    onChanged: (v) =>
                        setState(() => _agreedToTerms = v ?? false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'I confirm the above details are correct and I agree to the DMT booking terms. I understand that no-shows may result in a temporary ban.',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Navigation Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      side: const BorderSide(color: AppColors.primaryMaroon),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Back',
                      style: TextStyle(color: AppColors.primaryMaroon),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: AppColors.primaryMaroon,
                    ),
                    onPressed: provider.isLoading ? null : _onConfirmPressed,
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Confirm Booking',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
