import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healthify/models/clinic.dart';
import 'package:healthify/screens/home.dart' as home_screen;
import 'package:healthify/utilities/firebase_calls.dart';
import 'package:resend/resend.dart';

import '../../models/appointment.dart';

class BottomActionButton extends StatelessWidget {
  final Clinic clinic;
  final String? selectedCategory;
  final String? selectedService;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final TextEditingController additionalInfoController;

  final Appointment? appointment;

  const BottomActionButton({
    super.key,
    required this.clinic,
    required this.selectedCategory,
    required this.selectedService,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.additionalInfoController,
    this.appointment,
  });

  Resend get _resend {
    final apiKey = dotenv.env['RESEND_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('RESEND_API_KEY is not set in .env');
    }
    Resend(apiKey: apiKey);
    return Resend.instance;
  }

  DateTime combineDateAndTime(DateTime date, String timeString) {
    String time = timeString.trim().toUpperCase();
    final hasAM = time.endsWith('AM');
    final hasPM = time.endsWith('PM');
    if (hasAM || hasPM) {
      time = time.replaceAll('AM', '').replaceAll('PM', '').trim();
    }

    int hour, minute = 0;
    if (time.contains(':')) {
      final parts = time.split(':');
      hour = int.parse(parts[0].trim());
      minute = int.parse(parts[1].trim());
    } else {
      hour = int.parse(time);
    }

    if (hasPM && hour != 12) hour += 12;
    if (hasAM && hour == 12) hour = 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _formatAppointmentDateTimeLocal(DateTime dt) {
    final local = dt.toLocal();
    int h = local.hour;
    final am = h < 12;
    final h12 = (h == 0 ? 12 : (h > 12 ? h - 12 : h));
    final m = _two(local.minute);
    final d = _two(local.day);
    final mo = _two(local.month);
    final y = local.year;
    return '$d/$mo/$y at $h12:$m ${am ? 'AM' : 'PM'}';
  }

  String _emailHtml({
    required bool isEdit,
    required String clinicName,
    required String address,
    required String serviceCategory,
    required String serviceType,
    required String whenText,
    required String notes,
  }) {
    final logo =
        'https://res.cloudinary.com/dv7xjn1wg/image/upload/v1754383685/zsqvtra0elbtgo4bbxhi.png';
    final title = isEdit ? 'Appointment Updated' : 'Booking Confirmed';
    final intro = isEdit
        ? 'We’ve updated your appointment.'
        : 'Your appointment is booked.';

    return '''
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="x-apple-disable-message-reformatting">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>$title • Healthify</title>
  <style>
    body { margin:0; padding:0; background:#f6f7f9; color:#0f172a; font-family: -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Ubuntu,"Helvetica Neue",Arial; }
    .container { max-width: 560px; margin: 24px auto; padding: 0 16px; }
    .card { background:#ffffff; border-radius:16px; box-shadow:0 2px 12px rgba(15, 23, 42, 0.06); overflow:hidden; }
    .header { padding:24px 24px 8px; text-align:center; }
    .logo { width:100px;  height: 100px; display:block; margin:0 auto 12px; border-radius: 12px;}
    h1 { font-size:20px; margin:0; letter-spacing:-0.2px; }
    p.lead { margin:8px 0 0; color:#475569; }
    .divider { height:1px; background:#eef2f7; margin:16px 0; }
    .row { display:flex; gap:12px; margin:0 0 8px; }
    .key { width:110px; font-weight:600; color:#334155; }
    .val { flex:1; color:#0f172a; }
    .notes { background:#f8fafc; border:1px solid #e5e7eb; padding:12px; border-radius:12px; color:#334155; }
    .footer { text-align:center; color:#64748b; font-size:12px; padding:16px 12px 24px; }
    a.btn { display:inline-block; background:#2563eb; color:#fff!important; text-decoration:none; padding:10px 14px; border-radius:10px; margin-top:8px;}
  </style>
</head>
<body>
  <div class="container">
    <div class="card">
      <div class="header">
        <img class="logo" src="$logo" alt="Healthify logo" />
        <h1>$title</h1>
        <p class="lead">$intro</p>
      </div>

      <div class="content" style="padding:0 24px 16px;">
        <div class="divider"></div>

        <div class="row"><div class="key">Clinic</div><div class="val">$clinicName</div></div>
        <div class="row"><div class="key">Address</div><div class="val">$address</div></div>
        <div class="row"><div class="key">Category</div><div class="val">$serviceCategory</div></div>
        <div class="row"><div class="key">Service</div><div class="val">$serviceType</div></div>
        <div class="row"><div class="key">When</div><div class="val">$whenText</div></div>

        ${notes.isEmpty ? '' : '<div class="divider"></div><div class="notes">${_escapeHtml(notes)}</div>'}

      </div>

      <div class="footer">
        This email was sent by Healthify • Do not reply to this address
      </div>
    </div>
  </div>
</body>
</html>
''';
  }

  String _escapeHtml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  Future<bool> _sendBookingEmail({
    required String to,
    required bool isEdit,
    required String html,
  }) async {
    try {
      await _resend.sendEmail(
        from: 'noreply@healthifyapp.me',
        to: [to],
        subject: isEdit
            ? 'Your appointment was updated'
            : 'Your appointment is booked',
        html: html,
      );
      return true;
    } catch (e) {
      debugPrint('Email sending failed: $e');
      return false;
    }
  }

  void _showUpdateConfirmation(BuildContext context, ThemeData theme) {
    _showNiceDialog(
      context: context,
      theme: theme,
      title: 'Changes saved',
      subtitle: 'Your appointment has been updated.',
      primaryLabel: 'Done',
      onPrimary: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const home_screen.HomeScreen()),
          (Route<dynamic> route) => false,
        );
      },
    );
  }

  void _showError(BuildContext context, ThemeData theme, String msg) {
    _showNiceDialog(
      context: context,
      theme: theme,
      title: 'Something went wrong',
      subtitle: msg,
      icon: Icons.error_outline,
      iconColor: theme.colorScheme.error,
      primaryLabel: 'OK',
      onPrimary: () => Navigator.pop(context),
    );
  }

  void _showNiceDialog({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required String subtitle,
    IconData icon = Icons.check_circle,
    Color? iconColor,
    required String primaryLabel,
    required VoidCallback onPrimary,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        titlePadding: const EdgeInsets.only(top: 16, left: 20, right: 20),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color:
                    (iconColor ?? theme.colorScheme.primary).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                color: iconColor ?? theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        actions: [
          FilledButton(
            onPressed: onPrimary,
            style: FilledButton.styleFrom(
              minimumSize: const Size(120, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(primaryLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool isEdit =
        appointment != null && appointment!.status == 'upcoming';

    final canSubmit = selectedCategory != null &&
        selectedService != null &&
        selectedDate != null &&
        selectedTimeSlot != null;

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
              color: theme.colorScheme.surfaceContainer.withOpacity(0.85),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
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
                      color: theme.colorScheme.surface.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointment Summary',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (selectedService != null &&
                            selectedDate != null &&
                            selectedTimeSlot != null)
                          Text(
                            '$selectedService\n'
                            '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at $selectedTimeSlot',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: isEdit ? 4 : 1, // bigger width for main button
                        child: FilledButton(
                          onPressed: !canSubmit
                              ? null
                              : () => _bookAppointment(context, theme,
                                  isEdit: isEdit),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            isEdit ? 'Save Changes' : 'Book Appointment',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      if (isEdit) ...[
                        const SizedBox(width: 8), // space between buttons
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: FilledButton(
                            onPressed: () => _confirmAndDelete(context, theme),
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.error,
                              foregroundColor: theme.colorScheme.onError,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Icon(Icons.delete_forever),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, ThemeData theme) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete appointment?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseCalls().deleteAppointment(appointment!.id);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const home_screen.HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      _showError(context, theme, e.toString());
    }
  }

  Future<void> _bookAppointment(BuildContext context, ThemeData theme,
      {required bool isEdit}) async {
    try {
      final finalDateTime =
          combineDateAndTime(selectedDate!, selectedTimeSlot!);

      final whenText = _formatAppointmentDateTimeLocal(finalDateTime);
      final toEmail = appUser.email;

      final clinicName = clinic.name;
      final address = clinic.address;

      final html = _emailHtml(
        isEdit: isEdit,
        clinicName: clinicName,
        address: address,
        serviceCategory: selectedCategory ?? '',
        serviceType: selectedService ?? '',
        whenText: whenText,
        notes: additionalInfoController.text,
      );

      if (appointment != null) {
        await FirebaseCalls().updateAppointment(
          id: appointment!.id,
          placeId: clinic.placeId,
          appointmentDateTime: finalDateTime,
          serviceType: selectedService!,
          additionalInfo: additionalInfoController.text,
          serviceCategory: selectedCategory!,
          status: 'upcoming',
        );
        if (toEmail.isNotEmpty) {
          _sendBookingEmail(to: toEmail, isEdit: true, html: html);
        }
        _showUpdateConfirmation(context, theme);
      } else {
        await FirebaseCalls().addAppointment(
          placeId: clinic.placeId,
          appointmentDateTime: finalDateTime,
          serviceType: selectedService!,
          additionalInfo: additionalInfoController.text,
          serviceCategory: selectedCategory!,
        );
        if (toEmail.isNotEmpty) {
          _sendBookingEmail(to: toEmail, isEdit: false, html: html);
        }
        _showBookingConfirmation(context, theme,
            whenText: whenText, clinicName: clinicName);
      }
    } catch (e) {
      _showError(context, theme, e.toString());
    }
  }

  void _showBookingConfirmation(BuildContext context, ThemeData theme,
      {required String whenText, required String clinicName}) {
    _showNiceDialog(
      context: context,
      theme: theme,
      title: 'Booking confirmed',
      subtitle:
          'Appointment scheduled for $whenText at $clinicName.\nConfirmation email sent.',
      primaryLabel: 'Done',
      onPrimary: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const home_screen.HomeScreen()),
          (Route<dynamic> route) => false,
        );
      },
    );
  }
}
