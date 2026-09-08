import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_color.dart';
import '../core/constants/app_sizes.dart';
import '../providers/appointment_provider.dart';
import '../widgets/custom_button.dart';
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
        const SnackBar(content: Text('Please select an available time slot.')),
      );
      return;
    }

    context.read<AppointmentProvider>().selectSlot(_selectedSlot!);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConfirmationScreen()),
    );
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
    final cardBgColor = isSelected
        ? AppColors.primaryMaroon
        : AppColors.surface;
    final textColor = isSelected ? Colors.white : AppColors.textPrimary;
    final subTextColor = isSelected ? Colors.white70 : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primaryMaroon : AppColors.inputBorder,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.orangeAccent : Colors.orange,
                  size: AppSizes.iconSmall,
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppSizes.textBody,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    label: 'TOTAL SLOTS',
                    value: '$totalSlots',
                    isSelected: isSelected,
                  ),
                ),
                const SizedBox(width: AppSizes.xs),
                Expanded(
                  child: _buildStatBox(
                    label: 'TOKEN ISSUED',
                    value: '$tokenIssued',
                    isSelected: isSelected,
                  ),
                ),
                const SizedBox(width: AppSizes.xs),
                Expanded(
                  child: _buildStatBox(
                    label: 'SLOTS OPEN',
                    value: '$slotsOpen',
                    isSelected: isSelected,
                    highlightColor: Colors.green,
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
        vertical: AppSizes.xs,
        horizontal: AppSizes.xxs,
      ),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withAlpha(30) : AppColors.inputFill,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: highlightColor != null && !isSelected
            ? Border.all(color: Colors.green.shade200)
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
                  ? Colors.white
                  : (highlightColor ?? AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSizes.xxs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white70 : AppColors.textHint,
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSizes.indicatorDotSize,
              height: AppSizes.indicatorDotSize,
              decoration: const BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSizes.xxs),
            Container(
              width: AppSizes.indicatorDotSize,
              height: AppSizes.indicatorDotSize,
              decoration: const BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSizes.xxs),
            Container(
              width: AppSizes.indicatorActiveWidth,
              height: AppSizes.indicatorDotSize,
              decoration: BoxDecoration(
                color: AppColors.primaryMaroon,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
            ),
            const SizedBox(width: AppSizes.xxs),
            Container(
              width: AppSizes.indicatorDotSize,
              height: AppSizes.indicatorDotSize,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose appointment date and time slot',
              style: TextStyle(
                fontSize: AppSizes.textSubtitle,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Date Selection Box
            _buildFieldLabel('Date'),
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.inputBorder, width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDateStr,
                      style: const TextStyle(
                        fontSize: AppSizes.textBody,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMaroon,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.textHint,
                      size: AppSizes.iconSmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            _buildFieldLabel('Time'),
            const SizedBox(height: AppSizes.xs),

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
              const SizedBox(height: AppSizes.lg),
              _buildFieldLabel('Available Time Slots'),
              const SizedBox(height: AppSizes.xs),
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
                      padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                      child: Text(
                        'No slots available for this session.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.textCaption,
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: AppSizes.xs,
                      runSpacing: AppSizes.xs,
                      children: activeSlots.map((slot) {
                        final isSlotSelected = _selectedSlot == slot;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedSlot = slot;
                            });
                          },
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSm,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.md,
                              vertical: AppSizes.xs,
                            ),
                            decoration: BoxDecoration(
                              color: isSlotSelected
                                  ? AppColors.primaryMaroon
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                              border: Border.all(
                                color: isSlotSelected
                                    ? AppColors.primaryMaroon
                                    : AppColors.inputBorder,
                              ),
                            ),
                            child: Text(
                              slot,
                              style: TextStyle(
                                fontSize: AppSizes.textCaption,
                                fontWeight: FontWeight.bold,
                                color: isSlotSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ],

            const SizedBox(height: AppSizes.xl),

            // Action Buttons (BACK & NEXT)
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
    );
  }
}
