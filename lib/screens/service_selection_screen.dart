import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_color.dart';
import '../core/constants/app_sizes.dart';
import '../providers/appointment_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/dmt_ui.dart';
import 'date_time_selection_screen.dart';

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otherServiceController = TextEditingController();

  String? _selectedOffice;
  String? _selectedCategory;
  String? _selectedSubService;

  final List<String> _offices = [
    'Head Office - Narahenpita',
    'Gampaha District Office',
    'Kandy District Office',
    'Kalutara District Office',
    'Galle District Office',
    'Matara District Office',
  ];

  final Map<String, List<String>> _serviceMap = {
    '1. Driving License Services': [
      'Renewal of Drivers License - Normal Service',
      'Renewal of Drivers License - One day',
      'New License or Add New Category',
      'Information Change of License',
      'Get Certified Copy of Drivers License',
      'Extract of a Drivers License',
      'Conversion of Old to New License',
      'Service for Overseas Travelers',
    ],
    '2. Vehicle Registration': [
      'Registration of Motor Bikes',
      'Registration of Other Vehicle',
    ],
    '3. Ownership Transfer': [
      'Ownership Transfer of Motor Bikes',
      'Ownership Transfer of Motor Cars',
      'Ownership Transfer of Three Wheelers',
      'Ownership Transfer of Single Cabs, Double Cabs and Vans',
      'Ownership Transfer of Lorries, Buses and Land Vehicles',
    ],
    '4. Tax & Vehicle Inspection': [
      'Pay Luxury Tax',
      'Weight Certificates and Vehicle Inspections',
    ],
    '5. Vehicle Modification & Number Plates': [
      'Technical Modifications of Vehicles',
      'Number Plate Related Service',
    ],
    '6. Other Services': [],
  };

  @override
  void dispose() {
    _otherServiceController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_formKey.currentState!.validate()) {
      final finalService = _selectedCategory == '6. Other Services'
          ? _otherServiceController.text.trim()
          : _selectedSubService!;

      context.read<AppointmentProvider>().updateServiceAndDistrict(
        service: finalService,
        district: _selectedOffice!,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DateTimeSelectionScreen(),
        ),
      );
    }
  }

  /// UI helper: one styled dropdown. Same values, same callbacks as before.
  Widget _buildDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required FormFieldValidator<String> validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DmtFieldLabel(label),
        DropdownButtonFormField<String>(
          initialValue: value,
          hint: Text(
            hint,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: AppSizes.textBody,
            ),
          ),
          isExpanded: true,
          itemHeight: null,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd + 2),
          dropdownColor: AppColors.surface,
          style: const TextStyle(
            fontSize: AppSizes.textBody,
            color: AppColors.textPrimary,
          ),
          decoration: dmtInputDecoration(hint, prefixIcon: icon),
          // Closed field: single line. Open menu: up to 2 lines so long
          // service names are readable.
          selectedItemBuilder: (context) => options
              .map(
                (o) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(o, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          items: options
              .map(
                (o) => DropdownMenuItem(
                  value: o,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                    child: Text(
                      o,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: DmtStepHeader(currentStep: 1),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.sm,
                  AppSizes.lg,
                  AppSizes.xl,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const DmtHeroBanner(
                        icon: Icons.assignment_outlined,
                        title: 'Select preferred office and required service',
                      ),
                      const SizedBox(height: AppSizes.lg),

                      DmtCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Office Dropdown
                            _buildDropdown(
                              label: 'Office',
                              hint: 'Select Preferred Office',
                              icon: Icons.apartment_outlined,
                              value: _selectedOffice,
                              options: _offices,
                              onChanged: (val) =>
                                  setState(() => _selectedOffice = val),
                              validator: (v) =>
                                  v == null ? 'Please select an office' : null,
                            ),
                            const SizedBox(height: AppSizes.lg),

                            // Main Service Category Dropdown
                            _buildDropdown(
                              label: 'Main Service Category',
                              hint: 'Select Main Service',
                              icon: Icons.category_outlined,
                              value: _selectedCategory,
                              options: _serviceMap.keys.toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedCategory = val;
                                  _selectedSubService = null;
                                  _otherServiceController.clear();
                                });
                              },
                              validator: (v) => v == null
                                  ? 'Please select a service category'
                                  : null,
                            ),

                            // Specific Sub-Service OR Other Service Custom Input
                            if (_selectedCategory != null &&
                                _selectedCategory != '6. Other Services') ...[
                              const SizedBox(height: AppSizes.lg),
                              _buildDropdown(
                                label: 'Specific Service',
                                hint: 'Select Specific Service',
                                icon: Icons.miscellaneous_services_outlined,
                                value: _selectedSubService,
                                options: _serviceMap[_selectedCategory]!,
                                onChanged: (val) =>
                                    setState(() => _selectedSubService = val),
                                validator: (v) => v == null
                                    ? 'Please select a specific service'
                                    : null,
                              ),
                            ],

                            if (_selectedCategory == '6. Other Services') ...[
                              const SizedBox(height: AppSizes.lg),
                              const DmtFieldLabel('Specify Other Service'),
                              TextFormField(
                                controller: _otherServiceController,
                                style: const TextStyle(
                                  fontSize: AppSizes.textBody,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: dmtInputDecoration(
                                  'Type your service requirement here',
                                  prefixIcon: Icons.edit_outlined,
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Please specify the required service';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
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
