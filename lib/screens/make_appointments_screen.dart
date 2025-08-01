import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/svg.dart';
import 'package:healthify/screens/home.dart' as home_screen;

class MakeAppointmentsScreen extends StatefulWidget {
  final List<String> clinicDetails;
  const MakeAppointmentsScreen(this.clinicDetails, {super.key});

  @override
  State<MakeAppointmentsScreen> createState() => _MakeAppointmentsScreenState();
}

class _MakeAppointmentsScreenState extends State<MakeAppointmentsScreen> {
  String? selectedServiceCategory;
  String? selectedService;
  DateTime? selectedDate;
  String? selectedTimeSlot;

  final Map<String, List<String>> services = {
    'Doctor Consultation': [
      'General Consultation',
      'Chronic Conditions Follow-up',
      'Family Planning Consultation',
      'Specialist Referral Review',
    ],
    'Vaccination': [
      'Adult Vaccination',
      'Child Vaccination (6 months - 17 years)',
      'COVID-19 Vaccination',
      'Flu Vaccination',
      'Travel Vaccination',
    ],
    'Screening & Tests': [
      'Cervical Cancer Screening',
      'Diabetic Eye Screening',
      'Mammogram Screening',
      'Blood Pressure Check',
      'Cholesterol Test',
    ],
    'Nursing Services': [
      'Wound Dressing',
      'Injection Administration',
      'Health Education',
      'Postnatal Care',
    ],
    'Allied Health': [
      'Nutritionist Consultation',
      'Physiotherapy',
      'Medical Social Service',
      'Financial Counselling',
    ],
    'Dental': [
      'Dental Cleaning',
      'Dental Check-up',
      'Fluoride Treatment',
      'Dental X-Ray',
    ],
  };

  final List<String> timeSlots = [
    '9:00 AM',
    '9:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '2:00 PM',
    '2:30 PM',
    '3:00 PM',
    '3:30 PM',
    '4:00 PM',
    '4:30 PM'
  ];

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Make an Appointment',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clinic Info Card
                _buildClinicInfoCard(theme),
                const SizedBox(height: 24),

                // Service Category Selection
                _buildSectionTitle(theme, 'Select Service Category'),
                const SizedBox(height: 12),
                _buildServiceCategoryGrid(theme),
                const SizedBox(height: 24),

                // Specific Service Selection
                if (selectedServiceCategory != null) ...[
                  _buildSectionTitle(theme, 'Select Service'),
                  const SizedBox(height: 12),
                  _buildServiceList(theme),
                  const SizedBox(height: 24),
                ],

                // Date Selection
                if (selectedService != null) ...[
                  _buildSectionTitle(theme, 'Select Date'),
                  const SizedBox(height: 12),
                  _buildDateSelector(theme),
                  const SizedBox(height: 24),
                ],

                // Time Selection
                if (selectedDate != null) ...[
                  _buildSectionTitle(theme, 'Select Time'),
                  const SizedBox(height: 12),
                  _buildTimeSlotGrid(theme),
                  const SizedBox(height: 24),
                ],

                // Additional Info
                if (selectedTimeSlot != null) ...[
                  _buildSectionTitle(theme, 'Additional Information'),
                  const SizedBox(height: 12),
                  _buildAdditionalInfoCard(theme),
                  const SizedBox(height: 120), // Space for bottom button
                ],
              ],
            ),
          ),

          // Bottom Action Button
          if (selectedTimeSlot != null) _buildBottomActionButton(theme),
        ],
      ),
    );
  }

  Widget _buildClinicInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SvgPicture.asset(
              'images/medical.svg',
              width: 35,
              height: 35,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.clinicDetails[0],
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 200,
                  child: Text(
                    widget.clinicDetails[1].endsWith(', Singapore')
                        ? widget.clinicDetails[1]
                            .replaceFirst(', Singapore', '')
                        : widget.clinicDetails[1],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildServiceCategoryGrid(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemCount: services.keys.length,
      itemBuilder: (context, index) {
        final category = services.keys.elementAt(index);
        final isSelected = selectedServiceCategory == category;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedServiceCategory = category;
              selectedService = null;
              selectedDate = null;
              selectedTimeSlot = null;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.8)
                  : theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.secondary.withValues(alpha: 0.3)
                    : theme.colorScheme.outline.withValues(alpha: 0.12),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color:
                            theme.colorScheme.secondary.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _getCategoryIcon(category),
                  color: isSelected
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  category,
                  textAlign: TextAlign.left,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 18,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceList(ThemeData theme) {
    final categoryServices = services[selectedServiceCategory] ?? [];

    return Column(
      children: categoryServices.map((service) {
        final isSelected = selectedService == service;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedService = service;
                selectedDate = null;
                selectedTimeSlot = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                    : theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      service,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 18,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                selectedDate != null
                    ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                    : 'Tap to select date',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: selectedDate != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );

                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                      selectedTimeSlot = null;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Select'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotGrid(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.5,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = timeSlots[index];
        final isSelected = selectedTimeSlot == timeSlot;
        final isAvailable = index % 4 != 0; // Mock availability

        return GestureDetector(
          onTap: isAvailable
              ? () {
                  setState(() {
                    selectedTimeSlot = timeSlot;
                  });
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: !isAvailable
                  ? theme.colorScheme.surfaceVariant.withValues(alpha: 0.3)
                  : isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                timeSlot,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: !isAvailable
                      ? theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5)
                      : isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdditionalInfoCard(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Additional Notes (Optional)',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintStyle: TextStyle(fontSize: 16),
                  hintText:
                      'Any specific concerns or symptoms you\'d like to mention...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHigh,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.onSecondaryContainer,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please arrive 15 minutes before your appointment time. Bring your NRIC and any relevant medical documents.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 140),
      ],
    );
  }

  Widget _buildBottomActionButton(ThemeData theme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color:
                  theme.colorScheme.secondaryContainer.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointment Summary',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$selectedService\n${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at $selectedTimeSlot',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Handle appointment booking
                      _showBookingConfirmation(theme);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 4,
                      shadowColor: theme.colorScheme.primary.withOpacity(0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: Text(
                      'Book Appointment',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Doctor Consultation':
        return Icons.medical_services;
      case 'Vaccination':
        return Icons.vaccines;
      case 'Screening & Tests':
        return Icons.health_and_safety;
      case 'Nursing Services':
        return Icons.healing;
      case 'Allied Health':
        return Icons.support;
      case 'Dental':
        return FontAwesomeIcons.tooth;
      default:
        return Icons.local_hospital;
    }
  }

  void _showBookingConfirmation(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Booking Confirmed'),
          ],
        ),
        content: Text(
          'Your appointment has been successfully booked. \nYou will receive a confirmation Email shortly.',
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Navigator.of(context).pop();
              // Navigator.of(context).pop(); // Go back to previous screen

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => home_screen.HomeScreen()),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
