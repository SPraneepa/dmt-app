import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_color.dart';
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

  String? _selectedCategory;
  String? _selectedSubService;
  String? _selectedDistrict;

  // Hierarchical Service Mapping
  final Map<String, List<String>> _serviceMap = {
    'Driving License Services': [
      'New License / Add Category',
      'License Renewal - Normal Service',
      'License Renewal - Priority / Same Day Service',
      'Detail Alteration (Name / Address)',
      'Duplicate / Replacement License',
    ],
    'Vehicle Registration & Ownership': [
      'Vehicle First Registration',
      'Ownership Transfer - Light Vehicles (Cars, Bikes, Cabs)',
      'Ownership Transfer - Heavy Vehicles (Lorries, Buses)',
      'Luxury Tax Payment & Search Reports',
    ],
    'Vehicle Technical & Plate Services': [
      'Weight Certificates & Vehicle Inspection',
      'Technical Modifications Approval',
      'Number Plate Related Services',
      'Clearance & Cancellation Certificates',
    ],
  };

  final List<String> _districts = [
    'Ampara',
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Jaffna',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kilinochchi',
    'Kurunegala',
    'Mannar',
    'Matale',
    'Matara',
    'Monaragala',
    'Mullaitivu',
    'Nuwara Eliya',
    'Polonnaruwa',
    'Puttalam',
    'Ratnapura',
    'Trincomalee',
    'Vavuniya',
  ];

  void _onNextPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AppointmentProvider>().updateServiceAndDistrict(
        service: _selectedSubService!,
        district: _selectedDistrict!,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DateTimeSelectionScreen(),
        ),
      );
    }
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Department of Motor Traffic'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Preferred Office and Required Service',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select the service category, specific service, and your preferred district office. Availability varies by location.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 24),

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
                                'Service Category',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                hint: const Text('Select Category'),
                                isExpanded: true,
                                decoration: _dropdownDecoration(),
                                items: _serviceMap.keys.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(
                                      category,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedCategory = val;
                                    _selectedSubService =
                                        null; // Reset dependent sub-service selection
                                  });
                                },
                                validator: (v) => v == null
                                    ? 'Please select a service category'
                                    : null,
                              ),
                              const SizedBox(height: 16),

                              const Text(
                                'Specific Service',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedSubService,
                                hint: Text(
                                  _selectedCategory == null
                                      ? 'Select category first'
                                      : 'Select Specific Service',
                                ),
                                isExpanded: true,
                                decoration: _dropdownDecoration(),
                                items: _selectedCategory == null
                                    ? []
                                    : _serviceMap[_selectedCategory]!.map((
                                        subService,
                                      ) {
                                        return DropdownMenuItem(
                                          value: subService,
                                          child: Text(
                                            subService,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                onChanged: _selectedCategory == null
                                    ? null
                                    : (val) => setState(
                                        () => _selectedSubService = val,
                                      ),
                                validator: (v) => v == null
                                    ? 'Please select a specific service'
                                    : null,
                              ),
                              const SizedBox(height: 16),

                              const Text(
                                'District Office',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedDistrict,
                                hint: const Text('Select District'),
                                isExpanded: true,
                                menuMaxHeight: 200,
                                decoration: _dropdownDecoration(),
                                items: _districts.map((district) {
                                  return DropdownMenuItem(
                                    value: district,
                                    child: Text(
                                      district,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedDistrict = val),
                                validator: (v) => v == null
                                    ? 'Please select a district'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Back',
                        isPrimary: false,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Next',
                        isPrimary: true,
                        onPressed: _onNextPressed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
