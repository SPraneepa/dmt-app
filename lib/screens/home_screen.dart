import 'package:dmt_app/screens/applicant_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_color.dart';
import '../core/constants/app_sizes.dart';
import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';
import '../widgets/dmt_ui.dart';

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
            AppSizes.lg,
            AppSizes.xl,
            AppSizes.xxl + AppSizes.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(activeBooking),
              const SizedBox(height: AppSizes.xl),
              if (activeBooking == null)
                _buildAvailableServicesCard()
              else
                _buildActiveAppointmentCard(activeBooking),
              const SizedBox(height: AppSizes.md),
              _buildCountdownTimer(activeBooking),
              const SizedBox(height: AppSizes.lg),
              if (activeBooking == null)
                _buildBookingNowButton(context)
              else
                _buildBookingStatusBanner(activeBooking),
              const SizedBox(height: AppSizes.xxl),
              Semantics(
                header: true,
                child: const Text(
                  'Previous Bookings',
                  style: TextStyle(
                    fontSize: AppSizes.textLabel,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
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
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primarySoft],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: AppColors.textLight),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: AppSizes.textCaption,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppSizes.textLabel,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          ),
          child: IconButton(
            tooltip: 'Notifications',
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableServicesCard() {
    return DmtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: const Text(
              'Available services',
              style: TextStyle(
                fontSize: AppSizes.textLabel,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryMaroon,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = AppSizes.sm;
              final tileWidth = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: _availableServices
                    .map(
                      (service) => SizedBox(
                        width: tileWidth,
                        child: _buildServiceItem(service.icon, service.title),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAppointmentCard(AppointmentModel booking) {
    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Expanded(
                child: _buildLightInfo(Icons.person_outline, booking.userName),
              ),
              const SizedBox(width: AppSizes.md),
              Flexible(
                child: _buildLightInfo(Icons.badge_outlined, booking.nicNumber),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: _buildTokenBox(
                  'Counter',
                  '${booking.counterNumber ?? '-'}',
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _buildTokenBox('Token', '${booking.tokenNumber ?? '-'}'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.directions_car_outlined,
                color: AppColors.textLight,
                size: AppSizes.iconMedium,
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  booking.serviceName,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.textLabel,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          _buildLightDetail(Icons.calendar_today_outlined, booking.date),
          const SizedBox(height: AppSizes.sm),
          _buildLightDetail(
            Icons.schedule_outlined,
            'Est. called - ${booking.estimatedTime}',
          ),
          const SizedBox(height: AppSizes.sm),
          _buildLightDetail(Icons.apartment_outlined, booking.location),
        ],
      ),
    );
  }

  Widget _buildLightInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: AppSizes.iconMedium),
        const SizedBox(width: AppSizes.xs + 2),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: AppSizes.textBody,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLightDetail(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: AppSizes.iconSmall + 2),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: AppSizes.textBody,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTokenBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: AppSizes.textCaption,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
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

    return DmtCard(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        children: [
          Semantics(
            container: true,
            label:
                '${timeData['days']} days, ${timeData['hours']} hours, ${timeData['mins']} minutes, ${timeData['secs']} seconds remaining',
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Expanded(child: _buildTimeUnit(timeData['days']!, 'Days')),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(child: _buildTimeUnit(timeData['hours']!, 'Hours')),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(child: _buildTimeUnit(timeData['mins']!, 'Mins')),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(child: _buildTimeUnit(timeData['secs']!, 'Secs')),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            booking == null
                ? 'No upcoming appointment — the timer starts once you book.'
                : 'Get ready! Your appointment is coming up.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.textCaption,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: const TextStyle(
              fontSize: AppSizes.textCaption,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingNowButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
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
        icon: const Icon(Icons.event_available_outlined),
        label: const Text(
          'Book Now',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: AppSizes.textLabel,
            fontWeight: FontWeight.bold,
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.lg,
        horizontal: AppSizes.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer_outlined,
            color: AppColors.textLight,
            size: AppSizes.iconMedium,
          ),
          const SizedBox(width: AppSizes.sm),
          Flexible(
            child: Text(
              'NEXT BOOKING STARTS : $daysText',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
                fontSize: AppSizes.textBody,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousBookingsEmptyState() {
    return DmtCard(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: const Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: AppColors.primarySoft,
            size: 32,
          ),
          SizedBox(height: AppSizes.md),
          Text(
            'No bookings yet',
            style: TextStyle(
              fontSize: AppSizes.textLabel,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.xs),
          Text(
            'Your completed and upcoming appointments will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.textBody,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.10),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: AppSizes.textCaption,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primary : AppColors.textSecondary,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: 0,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'My Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
