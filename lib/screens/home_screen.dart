import 'package:dmt_app/screens/applicant_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_color.dart';
import '../core/constants/app_sizes.dart';
import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';

class ServiceItem {
  final IconData icon;
  final String title;

  const ServiceItem({required this.icon, required this.title});
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<ServiceItem> _availableServices = [
    ServiceItem(
      icon: Icons.assignment_outlined,
      title: 'Driving License Renewal',
    ),
    ServiceItem(icon: Icons.badge_outlined, title: 'New Driving License'),
    ServiceItem(
      icon: Icons.directions_car_outlined,
      title: 'Vehicle Registration',
    ),
    ServiceItem(icon: Icons.info_outline, title: 'Driving License Information'),
  ];

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final activeBooking = appointmentProvider.activeBooking;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.xl,
            AppSizes.xl,
            AppSizes.xl,
            AppSizes.xxl + AppSizes.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(activeBooking),
              const SizedBox(height: AppSizes.md),
              if (activeBooking == null)
                _buildAvailableServicesCard()
              else
                _buildActiveAppointmentCard(activeBooking),
              const SizedBox(height: AppSizes.md),
              _buildCountdownTimer(activeBooking),
              const SizedBox(height: AppSizes.md),
              if (activeBooking == null)
                _buildBookingNowButton(context)
              else
                _buildBookingStatusBanner(activeBooking),
              const SizedBox(height: AppSizes.xl),
              Text(
                'Previous Bookings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              _buildPreviousBookingsEmptyState(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader(AppointmentModel? booking) {
    final String displayName = booking?.userName ?? 'Guest User';

    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: AppSizes.sm),
        Text(
          displayName,
          style: const TextStyle(
            fontSize: AppSizes.textLabel,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.primary,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableServicesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'AVAILABLE SERVICES',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _availableServices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSizes.sm,
              mainAxisSpacing: AppSizes.sm,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final service = _availableServices[index];
              return _buildServiceItem(service.icon, service.title);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(AppSizes.xs),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAppointmentCard(AppointmentModel booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '👤 ${booking.userName}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              Text(
                '🆔 ${booking.nicNumber}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: _buildTokenBox(
                  'COUNTER',
                  '${booking.counterNumber ?? '-'}',
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _buildTokenBox(
                  '#TOKEN',
                  '${booking.tokenNumber ?? '-'}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            '🚗 ${booking.serviceName}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '📅 ${booking.date}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🔆 Est. called - ${booking.estimatedTime}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '🏢 ${booking.location}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _calculateTimeRemaining(AppointmentModel? booking) {
    if (booking == null || booking.date.isEmpty) {
      return {'days': '-', 'hours': '-', 'mins': '-', 'secs': '-'};
    }

    DateTime? targetDate;

    if (booking.date.contains(',')) {
      targetDate = DateTime.tryParse(booking.date.replaceFirst(',', ''));
    }

    if (targetDate == null) {
      targetDate = DateTime.tryParse(booking.date);
    }

    if (targetDate == null) {
      final parsedParts = booking.date.split('-');
      if (parsedParts.length == 3) {
        final year = int.tryParse(parsedParts[0]);
        final month = int.tryParse(parsedParts[1]);
        final day = int.tryParse(parsedParts[2]);
        if (year != null && month != null && day != null) {
          targetDate = DateTime(year, month, day);
        }
      }
    }

    if (targetDate == null) {
      return {'days': '0', 'hours': '0', 'mins': '0', 'secs': '0'};
    }

    final Duration difference = targetDate.difference(DateTime.now());

    if (difference.isNegative) {
      return {'days': '0', 'hours': '0', 'mins': '0', 'secs': '0'};
    }

    return {
      'days': difference.inDays.toString(),
      'hours': (difference.inHours % 24).toString().padLeft(2, '0'),
      'mins': (difference.inMinutes % 60).toString().padLeft(2, '0'),
      'secs': (difference.inSeconds % 60).toString().padLeft(2, '0'),
    };
  }

  Widget _buildCountdownTimer(AppointmentModel? booking) {
    final timeData = _calculateTimeRemaining(booking);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.sm,
        horizontal: AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD6DC)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeUnit(timeData['days']!, 'DAYS'),
              const Text('|', style: TextStyle(color: AppColors.divider)),
              _buildTimeUnit(timeData['hours']!, 'HOURS'),
              const Text('|', style: TextStyle(color: AppColors.divider)),
              _buildTimeUnit(timeData['mins']!, 'MINS'),
              const Text('|', style: TextStyle(color: AppColors.divider)),
              _buildTimeUnit(timeData['secs']!, 'SECS'),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            booking == null
                ? 'No upcoming appointment — the timer starts once you book.'
                : 'Get ready! Your appointment is coming up.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBookingNowButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(220, 48),
            padding: EdgeInsets.zero,
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ApplicantDetailsScreen(),
              ),
            );
          },
          child: const Center(
            child: Text(
              'Book Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingStatusBanner(AppointmentModel booking) {
    final timeData = _calculateTimeRemaining(booking);
    final daysText = timeData['days'] != '-'
        ? '${timeData['days']} DAYS'
        : 'SOON';

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          'NEXT BOOKING STARTS : $daysText',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPreviousBookingsEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: const [
          Icon(
            Icons.calendar_today_outlined,
            color: AppColors.textSecondary,
            size: 32,
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'No bookings yet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Your completed and upcoming appointments will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          label: 'My Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
