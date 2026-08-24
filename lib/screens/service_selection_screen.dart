import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../providers/appointment_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryMaroon,
        title: const Text(
          'Department of Motor Traffic',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
                        const Text(
                          'Select Preferred Office and Required Service',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryMaroon,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select the service category, specific service, and your preferred district office. Availability varies by location.',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Selection Form Card
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
                              // 1. Service Category
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
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
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

                              // 2. Specific Sub-Service
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
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                // Dynamically load items based on selected category
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

                              // 3. District Office
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
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
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

                // Navigation Controls (Back & Next)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          side: const BorderSide(
                            color: AppColors.primaryMaroon,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Back',
                          style: TextStyle(color: AppColors.primaryMaroon),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: AppColors.primaryMaroon,
                        ),
                        onPressed: _onNextPressed,
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.white),
                        ),
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
