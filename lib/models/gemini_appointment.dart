import 'package:healthify/models/clinic.dart';

class GeminiAppointment {
  final Clinic clinic;
  final String serviceCategory;
  final String serviceType;
  final String additionalInfo;

  GeminiAppointment({
    required this.clinic,
    required this.serviceCategory,
    required this.serviceType,
    required this.additionalInfo,
  });
}