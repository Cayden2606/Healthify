import 'package:flutter/material.dart';
import 'package:healthify/models/clinic.dart';
import 'package:healthify/utilities/status_bar_utils.dart';
import 'package:healthify/widgets/make_appointments/additional_info_card.dart';
import 'package:healthify/widgets/make_appointments/bottom_action_button.dart';
import 'package:healthify/widgets/make_appointments/clinic_info_card.dart';
import 'package:healthify/widgets/make_appointments/date_selector.dart';
import 'package:healthify/widgets/make_appointments/service_category_grid.dart';
import 'package:healthify/widgets/make_appointments/service_list.dart';
import 'package:healthify/widgets/make_appointments/time_slot_grid.dart';

class MakeAppointmentsScreen extends StatefulWidget {
  final Clinic clinic;
  const MakeAppointmentsScreen(this.clinic, {super.key});

  @override
  State<MakeAppointmentsScreen> createState() => _MakeAppointmentsScreenState();
}

class _MakeAppointmentsScreenState extends State<MakeAppointmentsScreen> {
  String? selectedServiceCategory;
  String? selectedService;
  DateTime? selectedDate;
  String? selectedTimeSlot;
  final _additionalInfoController = TextEditingController();

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
        systemOverlayStyle: StatusBarUtils.getStatusBarStyle(context),
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
                ClinicInfoCard(clinic: widget.clinic),
                const SizedBox(height: 24),

                // Service Category Selection
                const SectionTitle(title: 'Select Service Category'),
                const SizedBox(height: 12),
                ServiceCategoryGrid(
                  selectedServiceCategory: selectedServiceCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      selectedServiceCategory = category;
                      selectedService = null;
                      selectedDate = null;
                      selectedTimeSlot = null;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Specific Service Selection
                if (selectedServiceCategory != null) ...[
                  const SectionTitle(title: 'Select Service'),
                  const SizedBox(height: 12),
                  ServiceList(
                    selectedServiceCategory: selectedServiceCategory,
                    selectedService: selectedService,
                    onServiceSelected: (service) {
                      setState(() {
                        selectedService = service;
                        selectedDate = null;
                        selectedTimeSlot = null;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Date Selection
                if (selectedService != null) ...[
                  const SectionTitle(title: 'Select Date'),
                  const SizedBox(height: 12),
                  DateSelector(
                    selectedDate: selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        selectedDate = date;
                        selectedTimeSlot = null;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Time Selection
                if (selectedDate != null) ...[
                  const SectionTitle(title: 'Select Time'),
                  const SizedBox(height: 12),
                  TimeSlotGrid(
                    selectedTimeSlot: selectedTimeSlot,
                    onTimeSlotSelected: (timeSlot) {
                      setState(() {
                        selectedTimeSlot = timeSlot;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Additional Info
                if (selectedTimeSlot != null) ...[
                  const SectionTitle(title: 'Additional Information'),
                  const SizedBox(height: 12),
                  AdditionalInfoCard(controller: _additionalInfoController),
                  const SizedBox(height: 120), // Space for bottom button
                ],
              ],
            ),
          ),

          // Bottom Action Button
          if (selectedTimeSlot != null)
            BottomActionButton(
              clinic: widget.clinic,
              selectedService: selectedService,
              selectedDate: selectedDate,
              selectedTimeSlot: selectedTimeSlot,
              additionalInfoController: _additionalInfoController,
            ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
