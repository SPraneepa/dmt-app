import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/app_color.dart';
import '../core/constants/app_sizes.dart';
//import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/dmt_ui.dart';
import 'applicant_details_screen.dart';
import 'home_screen.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  // Wraps the QR image so we can capture it as a picture to save/share.
  final GlobalKey _qrBoundaryKey = GlobalKey();
  bool _isSavingQr = false;

  Future<void> _downloadQrCode() async {
    if (_isSavingQr) return;
    setState(() => _isSavingQr = true);

    try {
      final boundary =
          _qrBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Render at 3x for a crisp, scannable image.
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/dmt_appointment_qr.png',
      ).writeAsBytes(pngBytes);

      if (!mounted) return;
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'My DMT appointment QR code');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Could not save the QR code. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSavingQr = false);
    }
  }

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

    // What the reception desk scans: everything needed to verify the booking.
    final qrData =
        'DMT-APPOINTMENT|'
        'NAME:$name|'
        'NIC:$nic|'
        'SERVICE:$service|'
        'OFFICE:$district|'
        'DATE:${formattedDate.isNotEmpty ? formattedDate : '2026/08/28'}|'
        'SLOT:${timeSlot.isNotEmpty ? timeSlot : 'Morning Session'}|'
        'TOKEN:$tokenNo|'
        'COUNTER:$counterNo';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.md),

              // Success mark
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.textLight,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              Semantics(
                header: true,
                child: const Text(
                  'Booking Successful!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppSizes.textHeadline,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              const Text(
                'Your booking is complete. We look forward to serving you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizes.textBody,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Assignment: the one thing the user needs on the day
              Container(
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primarySoft],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your assignment',
                      style: TextStyle(
                        fontSize: AppSizes.textBody,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAssignmentBox(
                            label: 'Counter',
                            value: counterNo,
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: _buildAssignmentBox(
                            label: 'Token',
                            value: '#$tokenNo',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      'Go to Counter $counterNo and wait for token #$tokenNo to be called',
                      style: const TextStyle(
                        fontSize: AppSizes.textBody,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // QR Code Card
              DmtCard(
                child: Column(
                  children: [
                    const Text(
                      'Your QR Code',
                      style: TextStyle(
                        fontSize: AppSizes.textLabel,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryMaroon,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    RepaintBoundary(
                      key: _qrBoundaryKey,
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Semantics(
                          label: 'Appointment QR code for token $tokenNo',
                          image: true,
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 180,
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.textPrimary,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    const Text(
                      'Show this at the office reception desk on the day of your appointment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppSizes.textCaption,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    CustomButton(
                      text: 'DOWNLOAD QR CODE',
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      icon: Icons.qr_code_2_outlined,
                      isLoading: _isSavingQr,
                      onPressed: _downloadQrCode,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // Appointment details
              DmtCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appointment details',
                      style: TextStyle(
                        fontSize: AppSizes.textLabel,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryMaroon,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
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

                    // SMS Notice
                    Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.sms_outlined,
                            color: AppColors.primarySoft,
                            size: AppSizes.iconMedium,
                          ),
                          SizedBox(width: AppSizes.md),
                          Expanded(
                            child: Text(
                              'You will receive a SMS when your token is called. No need to watch the counter continuously.',
                              style: TextStyle(
                                fontSize: AppSizes.textCaption,
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // Reminder Banner Box
              Container(
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: AppSizes.iconMedium,
                          color: Color(0xFF5D4037),
                        ),
                        SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(
                            'Remember for your appointment day',
                            style: TextStyle(
                              fontSize: AppSizes.textBody,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.sm),
                    _ReminderItem(text: 'Arrive at least 15 minutes early.'),
                    _ReminderItem(
                      text: 'Bring all original required documents and copies.',
                    ),
                    _ReminderItem(
                      text: 'Bring your original NIC or valid Passport.',
                    ),
                    _ReminderItem(
                      text: 'Present your downloaded QR code at the entrance.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.xl),

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
                    backgroundColor: AppColors.surface,
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
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
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
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentBox({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.md,
        horizontal: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppSizes.textCaption,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.textLight,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppSizes.textBody,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: AppSizes.textBody,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.35,
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
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•  ',
            style: TextStyle(color: Color(0xFF5D4037), fontSize: 13),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF5D4037),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
