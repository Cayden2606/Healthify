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

import '../models/appointment.dart';

class MakeAppointmentsScreen extends StatefulWidget {
  final Clinic clinic;
  final Appointment? appointment;

  const MakeAppointmentsScreen(
    this.clinic, {
    super.key,
    this.appointment,
  });

  @override
  State<MakeAppointmentsScreen> createState() => _MakeAppointmentsScreenState();
}

class _MakeAppointmentsScreenState extends State<MakeAppointmentsScreen> {
  String? selectedServiceCategory;
  String? selectedService;
  DateTime? selectedDate;
  String? selectedTimeSlot;
  final _additionalInfoController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _maybePrefillFromAppointment();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _maybePrefillFromAppointment() {
    final appointment = widget.appointment;
    if (appointment != null && appointment.status == 'upcoming') {
      selectedServiceCategory = appointment.serviceCategory;
      selectedService = appointment.serviceType;

      final dateTime = appointment.appointmentDateTime;
      selectedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
      selectedTimeSlot = _formatTimeSlot(dateTime);
      _additionalInfoController.text = appointment.additionalInfo;

      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _formatTimeSlot(DateTime dateTime) {
    int hour = dateTime.hour;
    final minute = _twoDigits(dateTime.minute);
    final am = hour < 12;
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return "$hour12:$minute ${am ? 'AM' : 'PM'}";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appointment = widget.appointment;

    final titleText = appointment == null
        ? 'Make an Appointment'
        : appointment.status == 'passed'
            ? 'Book Another Appointment'
            : appointment.status == 'upcoming'
                ? 'Edit Appointment'
                : 'Make an Appointment';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          titleText,
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
            controller: _scrollController,
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
                      _scrollToBottom();
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Additional Info
                if (selectedTimeSlot != null) ...[
                  const SectionTitle(title: 'Additional Information'),
                  const SizedBox(height: 12),
                  AdditionalInfoCard(controller: _additionalInfoController),
                ],
                const SizedBox(height: 250), // Space for bottom button
              ],
            ),
          ),

          // Bottom Action Button
          if (selectedTimeSlot != null)
            BottomActionButton(
              clinic: widget.clinic,
              selectedCategory: selectedServiceCategory,
              selectedService: selectedService,
              selectedDate: selectedDate,
              selectedTimeSlot: selectedTimeSlot,
              additionalInfoController: _additionalInfoController,
              appointment: widget.appointment,
            )
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
