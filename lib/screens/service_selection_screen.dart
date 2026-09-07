import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_color.dart';
import '../core/constants/app_sizes.dart';
import '../providers/appointment_provider.dart';
import '../widgets/custom_button.dart';
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

  InputDecoration _buildInputDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColors.textHint,
        fontSize: AppSizes.textBody,
      ),
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.inputBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(
          color: AppColors.primaryMaroon,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: Colors.red, width: 1.6),
      ),
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

  @override
  Widget build(BuildContext context) {
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
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSizes.xxs),
            Container(
              width: 24,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primaryMaroon,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
            ),
            const SizedBox(width: AppSizes.xxs),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSizes.xxs),
            Container(
              width: 8,
              height: 8,
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select preferred office and required service',
                style: TextStyle(
                  fontSize: AppSizes.textSubtitle,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Office Dropdown
              _buildFieldLabel('Office'),
              DropdownButtonFormField<String>(
                initialValue: _selectedOffice,
                hint: const Text('Select Preferred Office'),
                isExpanded: true,
                style: const TextStyle(
                  fontSize: AppSizes.textBody,
                  color: AppColors.textPrimary,
                ),
                decoration: _buildInputDecoration('Select Preferred Office'),
                items: _offices.map((office) {
                  return DropdownMenuItem(
                    value: office,
                    child: Text(office, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedOffice = val),
                validator: (v) => v == null ? 'Please select an office' : null,
              ),
              const SizedBox(height: AppSizes.md),

              // Main Service Category Dropdown
              _buildFieldLabel('Main Service Category'),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                hint: const Text('Select Main Service'),
                isExpanded: true,
                style: const TextStyle(
                  fontSize: AppSizes.textBody,
                  color: AppColors.textPrimary,
                ),
                decoration: _buildInputDecoration('Select Main Service'),
                items: _serviceMap.keys.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                    _selectedSubService = null;
                    _otherServiceController.clear();
                  });
                },
                validator: (v) =>
                    v == null ? 'Please select a service category' : null,
              ),
              const SizedBox(height: AppSizes.md),

              // Specific Sub-Service OR Other Service Custom Input
              if (_selectedCategory != null &&
                  _selectedCategory != '6. Other Services') ...[
                _buildFieldLabel('Specific Service'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSubService,
                  hint: const Text('Select Specific Service'),
                  isExpanded: true,
                  style: const TextStyle(
                    fontSize: AppSizes.textBody,
                    color: AppColors.textPrimary,
                  ),
                  decoration: _buildInputDecoration('Select Specific Service'),
                  items: _serviceMap[_selectedCategory]!.map((subService) {
                    return DropdownMenuItem(
                      value: subService,
                      child: Text(subService, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedSubService = val),
                  validator: (v) =>
                      v == null ? 'Please select a specific service' : null,
                ),
                const SizedBox(height: AppSizes.md),
              ],

              if (_selectedCategory == '6. Other Services') ...[
                _buildFieldLabel('Specify Other Service'),
                TextFormField(
                  controller: _otherServiceController,
                  style: const TextStyle(
                    fontSize: AppSizes.textBody,
                    color: AppColors.textPrimary,
                  ),
                  decoration: _buildInputDecoration(
                    'Type your service requirement here',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please specify the required service';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.md),
              ],

              const SizedBox(height: AppSizes.xl),

              // Action Buttons Row (BACK & NEXT)
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
      ),
    );
  }
}
