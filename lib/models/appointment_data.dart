import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const Map<String, List<String>> appointmentServices = {
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

const List<String> appointmentTimeSlots = [
  '9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
  '2:00 PM', '2:30 PM', '3:00 PM', '3:30 PM', '4:00 PM', '4:30 PM'
];

IconData getCategoryIcon(String category) {
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