import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthify/models/clinic.dart';

class Appointment {
  final String id;
  final String userId;
  final Clinic clinic;
  final DateTime appointmentDateTime;
  final String serviceType;
  final String status;
  final DateTime createdAt;
  final String additionalInfo;

  Appointment({
    required this.id,
    required this.userId,
    required this.clinic,
    required this.appointmentDateTime,
    required this.serviceType,
    required this.status,
    this.additionalInfo = '',
    required this.createdAt,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      userId: data['userId'] ?? '',
      clinic: Clinic.fromJson(data['clinic'] as Map<String, dynamic>),
      appointmentDateTime: (data['appointmentDateTime'] as Timestamp).toDate(),
      serviceType: data['serviceType'] ?? '',
      status: data['status'] ?? 'upcoming',
      additionalInfo: data['additionalInfo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
