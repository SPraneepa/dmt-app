import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_color.dart';
import '../core/constants/app_sizes.dart';
import '../providers/appointment_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/dmt_ui.dart';
import 'confirmation_screen.dart';

class DateTimeSelectionScreen extends StatefulWidget {
  const DateTimeSelectionScreen({super.key});

  @override
  State<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen> {
  // Default selected date is the next day
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  // Track selected session: 'morning' or 'afternoon'
  String? _selectedSession;
  String? _selectedSlot;

  // Total session capacity defined for calculation
  static const int _totalMorningSlots = 30;
  static const int _totalAfternoonSlots = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSlots();
    });
  }

  void _loadSlots() {
    final formattedDate = DateFormat('yyyy - MM - dd').format(_selectedDate);
    context.read<AppointmentProvider>().fetchSlotsForDate(formattedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(tomorrow) ? tomorrow : _selectedDate,
      firstDate: tomorrow, // Prevents selection of previous days / today
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryMaroon,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedSession = null;
        _selectedSlot = null;
      });
      _loadSlots();
    }
  }

  void _onNextPressed() {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Please select an available time slot.'),
        ),
      );
      return;
    }

    context.read<AppointmentProvider>().selectSlot(_selectedSlot!);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConfirmationScreen()),
    );
  }

  Widget _buildSessionCard({
    required String title,
    required IconData icon,
    required int totalSlots,
    required int tokenIssued,
    required int slotsOpen,
    required double capacityPercent,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final textColor = isSelected ? AppColors.textLight : AppColors.textPrimary;
    final subTextColor = isSelected ? Colors.white70 : AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: AnimatedContainer(
            duration: dmtMotion(context),
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryMaroon : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: isSelected ? AppColors.primaryMaroon : kDmtFieldBorder,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.16)
                            : AppColors.warning.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.amber : AppColors.warning,
                        size: AppSizes.iconMedium,
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: AppSizes.textLabel,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                    // Selection is shown by icon as well as colour
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.textLight,
                        size: AppSizes.iconLarge,
                      ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatBox(
                        label: 'Total slots',
                        value: '$totalSlots',
                        isSelected: isSelected,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: _buildStatBox(
                        label: 'Token issued',
                        value: '$tokenIssued',
                        isSelected: isSelected,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: _buildStatBox(
                        label: 'Slots open',
                        value: '$slotsOpen',
                        isSelected: isSelected,
                        highlightColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Capacity used',
                      style: TextStyle(
                        fontSize: AppSizes.textCaption,
                        color: subTextColor,
                      ),
                    ),
                    Text(
                      '${(capacityPercent * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: AppSizes.textCaption,
                        fontWeight: FontWeight.bold,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xxs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  child: LinearProgressIndicator(
                    value: capacityPercent.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: isSelected
                        ? Colors.white24
                        : AppColors.divider,
                    color: isSelected ? Colors.amber : AppColors.primaryMaroon,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required String label,
    required String value,
    required bool isSelected,
    Color? highlightColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.sm,
        horizontal: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.14)
            : AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: highlightColor != null && !isSelected
            ? Border.all(color: AppColors.success.withValues(alpha: 0.35))
            : null,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: AppSizes.textSubtitle,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? AppColors.textLight
                  : (highlightColor ?? AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white70 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();
    final formattedDateStr = DateFormat('yyyy - MM - dd').format(_selectedDate);

    // Dynamic slot filtering from Provider
    final morningSlots = provider.availableSlots
        .where((slot) => slot.contains('AM'))
        .toList();
    final afternoonSlots = provider.availableSlots
        .where((slot) => slot.contains('PM'))
        .toList();

    // Dynamic stat calculations
    final morningOpen = morningSlots.length;
    final morningIssued = _totalMorningSlots - morningOpen;
    final morningCapacity = morningIssued / _totalMorningSlots;

    final afternoonOpen = afternoonSlots.length;
    final afternoonIssued = _totalAfternoonSlots - afternoonOpen;
    final afternoonCapacity = afternoonIssued / _totalAfternoonSlots;

    // Slots to render below depending on session selection
    final activeSlots = _selectedSession == 'morning'
        ? morningSlots
        : _selectedSession == 'afternoon'
        ? afternoonSlots
        : <String>[];

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
              child: DmtStepHeader(currentStep: 2),
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
                      icon: Icons.event_available_outlined,
                      title: 'Choose appointment date and time slot',
                    ),
                    const SizedBox(height: AppSizes.lg),

                    // Date Selection Box
                    const DmtFieldLabel('Date'),
                    Semantics(
                      button: true,
                      label:
                          'Appointment date $formattedDateStr. Double tap to change.',
                      child: ExcludeSemantics(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd + 2,
                            ),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 52),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md,
                                vertical: AppSizes.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusMd + 2,
                                ),
                                border: Border.all(color: kDmtFieldBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.event_outlined,
                                    color: AppColors.primarySoft,
                                    size: AppSizes.iconMedium,
                                  ),
                                  const SizedBox(width: AppSizes.md),
                                  Expanded(
                                    child: Text(
                                      formattedDateStr,
                                      style: const TextStyle(
                                        fontSize: AppSizes.textLabel,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryMaroon,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppColors.textSecondary,
                                    size: AppSizes.iconSmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),

                    const DmtFieldLabel('Time'),

                    // Dynamic Morning Session Card
                    _buildSessionCard(
                      title: 'Morning Session',
                      icon: Icons.wb_sunny_outlined,
                      totalSlots: _totalMorningSlots,
                      tokenIssued: morningIssued,
                      slotsOpen: morningOpen,
                      capacityPercent: morningCapacity,
                      isSelected: _selectedSession == 'morning',
                      onTap: () {
                        setState(() {
                          _selectedSession = 'morning';
                          _selectedSlot = null;
                        });
                      },
                    ),

                    const SizedBox(height: AppSizes.md),

                    // Dynamic Afternoon Session Card
                    _buildSessionCard(
                      title: 'Afternoon Session',
                      icon: Icons.nightlight_round_outlined,
                      totalSlots: _totalAfternoonSlots,
                      tokenIssued: afternoonIssued,
                      slotsOpen: afternoonOpen,
                      capacityPercent: afternoonCapacity,
                      isSelected: _selectedSession == 'afternoon',
                      onTap: () {
                        setState(() {
                          _selectedSession = 'afternoon';
                          _selectedSlot = null;
                        });
                      },
                    ),

                    // Dynamic Sub Time Slots Section
                    if (_selectedSession != null) ...[
                      const SizedBox(height: AppSizes.xl),
                      const DmtFieldLabel('Available Time Slots'),
                      provider.isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppSizes.md),
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryMaroon,
                                ),
                              ),
                            )
                          : activeSlots.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSizes.sm,
                              ),
                              child: Text(
                                'No slots available for this session.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: AppSizes.textBody,
                                ),
                              ),
                            )
                          : Wrap(
                              spacing: AppSizes.sm,
                              runSpacing: AppSizes.sm,
                              children: activeSlots.map((slot) {
                                final isSlotSelected = _selectedSlot == slot;
                                return Semantics(
                                  button: true,
                                  selected: isSlotSelected,
                                  child: Material(
                                    color: isSlotSelected
                                        ? AppColors.primaryMaroon
                                        : AppColors.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMd,
                                      ),
                                      side: BorderSide(
                                        color: isSlotSelected
                                            ? AppColors.primaryMaroon
                                            : kDmtFieldBorder,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedSlot = slot;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMd,
                                      ),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minHeight: 44,
                                          minWidth: 96,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSizes.md,
                                            vertical: AppSizes.sm,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if (isSlotSelected) ...[
                                                const Icon(
                                                  Icons.check,
                                                  size: AppSizes.iconSmall,
                                                  color: AppColors.textLight,
                                                ),
                                                const SizedBox(
                                                  width: AppSizes.xs,
                                                ),
                                              ],
                                              Text(
                                                slot,
                                                style: TextStyle(
                                                  fontSize: AppSizes.textBody,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSlotSelected
                                                      ? AppColors.textLight
                                                      : AppColors.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ],
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
          text: 'NEXT',
          width: double.infinity,
          height: AppSizes.buttonHeight,
          onPressed: _onNextPressed,
        ),
      ),
    );
  }
}
