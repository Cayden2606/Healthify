import 'package:flutter/material.dart';

class MakeAppointmentsScreen extends StatefulWidget {
  const MakeAppointmentsScreen({super.key});

  @override
  State<MakeAppointmentsScreen> createState() => _MakeAppointmentsScreenState();
}

class _MakeAppointmentsScreenState extends State<MakeAppointmentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
      'Make an Appointment',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    )));
  }
}
