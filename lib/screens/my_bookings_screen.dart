import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_color.dart';
import '../core/constants/app_sizes.dart';
import '../core/constants/app_text_styles.dart';
import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/dmt_ui.dart';
import 'applicant_details_screen.dart';

enum _BookingStatus { upcoming, past }

/// Reads "2026 - 09 - 30", "2026/09/30" or "2026-09-30".
DateTime? _parseDate(String raw) {
  final m = RegExp(r'(\d{4})\D+(\d{1,2})\D+(\d{1,2})').firstMatch(raw);
  if (m == null) return null;
  return DateTime(
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    int.parse(m.group(3)!),
  );
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

_BookingStatus _statusOf(AppointmentModel b) {
  final date = _parseDate(b.date);
  if (date == null) return _BookingStatus.upcoming; // unknown: keep it visible
  return date.isBefore(_today())
      ? _BookingStatus.past
      : _BookingStatus.upcoming;
}

/// "09:00 AM" / "01:30 PM" / "13:30" -> minutes since midnight (for sorting).
int _slotMinutes(String slot) {
  final m = RegExp(r'(\d{1,2}):(\d{2})\s*([AaPp][Mm])?').firstMatch(slot);
  if (m == null) return 0;
  final rawHour = int.parse(m.group(1)!);
  final meridiem = m.group(3)?.toUpperCase();
  final hour = meridiem == null
      ? rawHour
      : (rawHour % 12) + (meridiem == 'PM' ? 12 : 0);
  return hour * 60 + int.parse(m.group(2)!);
}

int _compareAsc(AppointmentModel a, AppointmentModel b) {
  final da = _parseDate(a.date) ?? DateTime(9999);
  final db = _parseDate(b.date) ?? DateTime(9999);
  final byDate = da.compareTo(db);
  if (byDate != 0) return byDate;
  return _slotMinutes(a.timeSlot).compareTo(_slotMinutes(b.timeSlot));
}

String? _relativeLabel(DateTime? date) {
  if (date == null) return null;
  final t = _today();
  final days = DateTime.utc(
    date.year,
    date.month,
    date.day,
  ).difference(DateTime.utc(t.year, t.month, t.day)).inDays;
  if (days <= 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  return 'In $days days';
}

String _orDash(String? value) =>
    (value == null || value.trim().isEmpty) ? '--' : value;

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  _BookingStatus _filter = _BookingStatus.upcoming;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppointmentProvider>().loadMyBookings();
    });
  }

  void _bookNow() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ApplicantDetailsScreen()),
    );
  }

  void _showDetails(AppointmentModel booking) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      builder: (_) => _BookingDetailsSheet(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();
    final all = provider.myBookings;

    final upcoming =
        all.where((b) => _statusOf(b) == _BookingStatus.upcoming).toList()
          ..sort(_compareAsc);
    final past = all.where((b) => _statusOf(b) == _BookingStatus.past).toList()
      ..sort((a, b) => _compareAsc(b, a));
    final shown = _filter == _BookingStatus.upcoming ? upcoming : past;

    final isLoading = provider.isLoadingBookings;
    final error = provider.bookingsError;
    final showSkeleton = isLoading && all.isEmpty;
    final showError = !isLoading && error != null && all.isEmpty;
    final showEmpty = !isLoading && error == null && all.isEmpty;

    void retry() => context.read<AppointmentProvider>().loadMyBookings();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.xl,
                AppSizes.lg,
                AppSizes.xl,
                AppSizes.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: const Text(
                      'My Bookings',
                      style: AppTextStyles.heading,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    all.isEmpty
                        ? 'Your appointments will appear here'
                        : 'Track and review your DMT appointments',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ),
            if (all.isNotEmpty)
              _FilterBar(
                selected: _filter,
                upcomingCount: upcoming.length,
                pastCount: past.length,
                onChanged: (value) => setState(() => _filter = value),
              ),
            SizedBox(
              height: 2,
              child: (isLoading && all.isNotEmpty)
                  ? const LinearProgressIndicator(
                      minHeight: 2,
                      color: AppColors.primary,
                      backgroundColor: Colors.transparent,
                    )
                  : null,
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    context.read<AppointmentProvider>().loadMyBookings(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.xl,
                    AppSizes.sm,
                    AppSizes.xl,
                    AppSizes.xxl,
                  ),
                  children: [
                    if (showSkeleton) const _SkeletonList(),
                    if (showError) _ErrorState(message: error, onRetry: retry),
                    if (showEmpty) _EmptyState(onBook: _bookNow),
                    if (all.isNotEmpty) ...[
                      if (error != null) _InlineErrorBanner(onRetry: retry),
                      if (shown.isEmpty)
                        _FilteredEmpty(status: _filter, onBook: _bookNow)
                      else
                        for (final booking in shown)
                          _BookingCard(
                            booking: booking,
                            onTap: () => _showDetails(booking),
                          ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
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
        selectedIndex: 1,
        onDestinationSelected: (index) {
          // Home sits directly underneath this screen in the stack.
          if (index == 0) Navigator.of(context).maybePop();
        },
        destinations: const [
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

// ---------------------------------------------------------------------------
// Filter (Upcoming / Past)
// ---------------------------------------------------------------------------
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selected,
    required this.upcomingCount,
    required this.pastCount,
    required this.onChanged,
  });

  final _BookingStatus selected;
  final int upcomingCount;
  final int pastCount;
  final ValueChanged<_BookingStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.xl,
        0,
        AppSizes.xl,
        AppSizes.sm,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _segment(
              context,
              'Upcoming',
              upcomingCount,
              _BookingStatus.upcoming,
            ),
          ),
          Expanded(
            child: _segment(context, 'Past', pastCount, _BookingStatus.past),
          ),
        ],
      ),
    );
  }

  Widget _segment(
    BuildContext context,
    String label,
    int count,
    _BookingStatus value,
  ) {
    final isSelected = selected == value;
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label, $count bookings',
      onTap: () => onChanged(value),
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onChanged(value),
            child: AnimatedContainer(
              duration: dmtMotion(context),
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$label ($count)',
                style: TextStyle(
                  fontSize: AppSizes.textBody,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.textLight
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Booking card
// ---------------------------------------------------------------------------
class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.onTap});

  final AppointmentModel booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _statusOf(booking);
    final isUpcoming = status == _BookingStatus.upcoming;
    final date = _parseDate(booking.date);
    final dateText = date == null
        ? _orDash(booking.date)
        : DateFormat('d MMM yyyy').format(date);
    final relative = isUpcoming ? _relativeLabel(date) : null;
    final token = _orDash(booking.tokenNumber);

    return Semantics(
      button: true,
      onTap: onTap,
      label:
          '${booking.service}. ${isUpcoming ? 'Upcoming' : 'Past'} booking at '
          '${booking.district}, $dateText, ${booking.timeSlot}. Token $token. '
          'Double tap for details.',
      child: ExcludeSemantics(
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StatusBadge(status),
                        const Spacer(),
                        if (relative != null)
                          Text(
                            relative,
                            style: const TextStyle(
                              fontSize: AppSizes.textCaption,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.directions_car_outlined,
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
                                booking.service,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: AppSizes.textLabel,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.apartment_outlined,
                                    size: AppSizes.iconSmall,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      booking.district,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: AppSizes.textBody,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.xs),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCell(label: 'Date', value: dateText),
                          ),
                          const _StatDivider(),
                          Expanded(
                            child: _StatCell(
                              label: 'Time',
                              value: _orDash(booking.timeSlot),
                            ),
                          ),
                          const _StatDivider(),
                          Expanded(
                            child: _StatCell(label: 'Token', value: token),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);

  final _BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = status == _BookingStatus.upcoming;
    final foreground = isUpcoming ? AppColors.primary : AppColors.textSecondary;
    final background = isUpcoming
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.surfaceAlt;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUpcoming ? Icons.event_available_outlined : Icons.history,
            size: 14,
            color: foreground,
          ),
          const SizedBox(width: 4),
          Text(
            isUpcoming ? 'Upcoming' : 'Past',
            style: TextStyle(
              fontSize: AppSizes.textCaption,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: const TextStyle(
              fontSize: AppSizes.textBody,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
      color: AppColors.border,
    );
  }
}

// ---------------------------------------------------------------------------
// Details bottom sheet
// ---------------------------------------------------------------------------
class _BookingDetailsSheet extends StatelessWidget {
  const _BookingDetailsSheet({required this.booking});

  final AppointmentModel booking;

  @override
  Widget build(BuildContext context) {
    final status = _statusOf(booking);
    final isUpcoming = status == _BookingStatus.upcoming;
    final date = _parseDate(booking.date);
    final dateText = date == null
        ? _orDash(booking.date)
        : DateFormat('EEE, d MMM yyyy').format(date);
    final relative = isUpcoming ? _relativeLabel(date) : null;

    final rows = <Widget>[
      _DetailRow('Applicant', _orDash(booking.fullName)),
      _DetailRow('NIC', _orDash(booking.nic)),
      _DetailRow('Phone', _orDash(booking.phoneNumber)),
      _DetailRow('Date', dateText),
      _DetailRow('Time slot', _orDash(booking.timeSlot)),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.xs,
        AppSizes.lg,
        AppSizes.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusBadge(status),
              const Spacer(),
              if (relative != null)
                Text(
                  relative,
                  style: const TextStyle(
                    fontSize: AppSizes.textCaption,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Semantics(
            header: true,
            child: Text(
              booking.service,
              style: const TextStyle(
                fontSize: AppSizes.textSubtitle,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              const Icon(
                Icons.apartment_outlined,
                size: AppSizes.iconSmall,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  booking.district,
                  style: const TextStyle(
                    fontSize: AppSizes.textBody,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: _BigTile(
                  label: 'Counter',
                  value: _orDash(booking.counterNumber),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: _BigTile(
                  label: 'Token',
                  value: _orDash(booking.tokenNumber),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              const Divider(height: 1, color: AppColors.divider),
          ],
          if (isUpcoming) ...[
            const SizedBox(height: AppSizes.lg),
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
                    Icons.info_outline,
                    size: AppSizes.iconMedium,
                    color: AppColors.primarySoft,
                  ),
                  SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Text(
                      'Arrive at least 15 minutes early and bring your original NIC or a valid passport.',
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
          const SizedBox(height: AppSizes.lg),
          CustomButton(
            text: 'CLOSE',
            isPrimary: false,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _BigTile extends StatelessWidget {
  const _BigTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppSizes.textCaption,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
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

// ---------------------------------------------------------------------------
// Empty / error / loading states
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBook});

  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.xxxl),
      child: Column(
        children: [
          ExcludeSemantics(
            child: SizedBox(
              width: 148,
              height: 148,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.05),
                    ),
                  ),
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.08),
                    ),
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryDark, AppColors.primarySoft],
                      ),
                    ),
                    child: const Icon(
                      Icons.event_note_outlined,
                      color: AppColors.textLight,
                      size: 34,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          Semantics(
            header: true,
            child: const Text(
              'No bookings yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Book your first DMT appointment and it will show up here with your token and counter.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppSizes.xl),
          CustomButton(
            text: 'BOOK AN APPOINTMENT',
            icon: Icons.add_rounded,
            onPressed: onBook,
          ),
          const SizedBox(height: AppSizes.md),
          const Text(
            'It only takes four short steps.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _FilteredEmpty extends StatelessWidget {
  const _FilteredEmpty({required this.status, required this.onBook});

  final _BookingStatus status;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = status == _BookingStatus.upcoming;
    return DmtCard(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        children: [
          Icon(
            isUpcoming ? Icons.event_available_outlined : Icons.history,
            size: 32,
            color: AppColors.primarySoft,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            isUpcoming ? 'No upcoming bookings' : 'No past bookings',
            style: const TextStyle(
              fontSize: AppSizes.textLabel,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            isUpcoming
                ? 'You have no appointments scheduled. Book one whenever you are ready.'
                : 'Appointments with earlier dates will appear here.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppSizes.textBody,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (isUpcoming) ...[
            const SizedBox(height: AppSizes.lg),
            CustomButton(
              text: 'BOOK AN APPOINTMENT',
              icon: Icons.add_rounded,
              onPressed: onBook,
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.xxxl),
      child: Column(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.08),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 38,
                color: AppColors.error,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          Semantics(
            header: true,
            child: const Text(
              'Could not load bookings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppSizes.xl),
          CustomButton(
            text: 'TRY AGAIN',
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.only(left: AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: AppSizes.iconMedium,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSizes.sm),
          const Expanded(
            child: Text(
              'Could not refresh. Showing your saved bookings.',
              style: TextStyle(
                fontSize: AppSizes.textCaption,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(64, 48),
              foregroundColor: AppColors.primary,
            ),
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder cards while bookings load. Pulses gently, and stays still when
/// the phone's "remove animations" setting is on.
class _SkeletonList extends StatefulWidget {
  const _SkeletonList();

  @override
  State<_SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<_SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bar(double? width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _card(Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(88, 22, color),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(double.infinity, 14, color),
                    const SizedBox(height: 8),
                    _bar(120, 12, color),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          _bar(double.infinity, 58, color),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading your bookings',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(_controller.value);
            final color = Color.lerp(
              AppColors.border.withValues(alpha: 0.35),
              AppColors.border.withValues(alpha: 0.75),
              t,
            )!;
            return Column(children: [_card(color), _card(color), _card(color)]);
          },
        ),
      ),
    );
  }
}
