import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_color.dart';
import '../core/constants/app_sizes.dart';
import '../providers/appointment_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final activeBooking = appointmentProvider.activeBooking;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSizes.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.sm),
              _buildHeader(),
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
                _buildBookingStatusBanner(),
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

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primaryMaroon,
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: AppSizes.sm),
        const Text(
          'R.P Kamal Perera',
          style: TextStyle(
            fontSize: 16,
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
              color: AppColors.primaryMaroon,
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
        color: AppColors.primaryMaroon,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'AVAILABLE SERVICES',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSizes.sm,
            mainAxisSpacing: AppSizes.sm,
            childAspectRatio: 2.2,
            children: [
              _buildServiceItem(
                Icons.assignment_outlined,
                'Driving License Renewal',
              ),
              _buildServiceItem(Icons.badge_outlined, 'New Driving License'),
              _buildServiceItem(
                Icons.directions_car_outlined,
                'Vehicle Registration',
              ),
              _buildServiceItem(
                Icons.info_outline,
                'Driving License Information',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
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

  Widget _buildActiveAppointmentCard(dynamic booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primaryMaroon,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '👤 ${booking.userName ?? 'R.P Kamal Perera'}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              Text(
                '🆔 ${booking.nicNumber ?? ''}',
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
                  '${booking.counterNumber ?? 6}',
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _buildTokenBox('#TOKEN', '${booking.tokenNumber ?? 15}'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            '🚗 ${booking.serviceName ?? ''}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '📅 ${booking.date ?? ''}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🔆 Est. called - ${booking.estimatedTime ?? ''}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '🏢 ${booking.location ?? 'Werahara'}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
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
        color: Colors.black.withOpacity(0.2),
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

  Widget _buildCountdownTimer(dynamic booking) {
    final days = booking != null ? '5' : '-';
    final hours = booking != null ? '3' : '-';
    final mins = booking != null ? '12' : '-';
    final secs = booking != null ? '25' : '-';

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
              _buildTimeUnit(days, 'DAYS'),
              const Text('|', style: TextStyle(color: AppColors.divider)),
              _buildTimeUnit(hours, 'HOURS'),
              const Text('|', style: TextStyle(color: AppColors.divider)),
              _buildTimeUnit(mins, 'MINS'),
              const Text('|', style: TextStyle(color: AppColors.divider)),
              _buildTimeUnit(secs, 'SECS'),
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
            color: AppColors.primaryMaroon,
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
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryMaroon,
            shape: const StadiumBorder(),
          ),
          onPressed: () {},
          child: const Text(
            'Booking Now',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingStatusBanner() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryMaroon.withOpacity(0.85),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Text(
          'NEXT BOOKING STARTS : 5 DAYS',
          textAlign: TextAlign.center,
          style: TextStyle(
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
      selectedItemColor: AppColors.primaryMaroon,
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
