
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';

import '../../data/models/academy_enrollment_model.dart';

class EnrollmentStatusCard extends StatelessWidget {
final AcademyEnrollmentModel enrollment;

const EnrollmentStatusCard({
super.key,
required this.enrollment,
});

@override
Widget build(BuildContext context) {
final t = context.watch<LanguageProvider>().translate;

return Container(
padding: const EdgeInsets.all(17),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(20),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(alpha: 0.05),
blurRadius: 16,
offset: const Offset(0, 6),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// ==========================================================
// HEADER
// ==========================================================

Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: 48,
height: 48,
decoration: BoxDecoration(
color: const Color(0xffEAF7D9),
borderRadius: BorderRadius.circular(14),
),
child: const Icon(
Icons.school_rounded,
color: Color(0xff7CC000),
size: 25,
),
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
enrollment.academyName ??
t('academy'),
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: Color(0xff1E1446),
fontSize: 17,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 4),

Text(
enrollment.programName ??
t('training_program'),
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: Colors.black54,
fontSize: 13,
height: 1.35,
),
),
],
),
),

const SizedBox(width: 8),

_buildStatusBadge(
context,
t,
),
],
),

const SizedBox(height: 18),

// ==========================================================
// PROGRAM INFO
// ==========================================================

if (enrollment.programLevel != null &&
enrollment.programLevel!.trim().isNotEmpty)
_buildInfoRow(
icon: Icons.bar_chart_rounded,
label: t('level'),
value: enrollment.programLevel!.trim(),
),

if (enrollment.programDurationWeeks != null)
_buildInfoRow(
icon: Icons.calendar_month_outlined,
label: t('duration'),
value:
'${enrollment.programDurationWeeks} ${t('weeks')}',
),

if (enrollment.programPrice != null)
_buildInfoRow(
icon: Icons.payments_outlined,
label: t('price'),
value:
'${enrollment.programPrice!.toStringAsFixed(0)} EGP',
),

// ==========================================================
// APPLICATION DATE
// ==========================================================

const SizedBox(height: 6),

_buildInfoRow(
icon: Icons.access_time_rounded,
label: t('applied_on'),
value: _formatDate(
enrollment.enrolledAt,
),
),

const SizedBox(height: 14),

// ==========================================================
// STATUS MESSAGE
// ==========================================================

Container(
width: double.infinity,
padding: const EdgeInsets.symmetric(
horizontal: 13,
vertical: 11,
),
decoration: BoxDecoration(
color: _statusBackgroundColor(),
borderRadius: BorderRadius.circular(13),
),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(
_statusIcon(),
size: 19,
color: _statusColor(),
),
const SizedBox(width: 8),
Expanded(
child: Text(
_statusMessage(t),
style: TextStyle(
color: _statusColor(),
fontSize: 12.5,
fontWeight: FontWeight.w600,
height: 1.4,
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

// ================================================================
// INFO ROW
// ================================================================

Widget _buildInfoRow({
required IconData icon,
required String label,
required String value,
}) {
return Padding(
padding: const EdgeInsets.only(
bottom: 9,
),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(
icon,
size: 18,
color: const Color(0xff7CC000),
),
const SizedBox(width: 8),
Text(
'$label: ',
style: const TextStyle(
color: Colors.black54,
fontSize: 13,
fontWeight: FontWeight.w500,
),
),
Expanded(
child: Text(
value,
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: Color(0xff1E1446),
fontSize: 13,
fontWeight: FontWeight.w600,
),
),
),
],
),
);
}

// ================================================================
// STATUS BADGE
// ================================================================

Widget _buildStatusBadge(
BuildContext context,
String Function(String) t,
) {
return Container(
padding: const EdgeInsets.symmetric(
horizontal: 10,
vertical: 7,
),
decoration: BoxDecoration(
color: _statusBackgroundColor(),
borderRadius: BorderRadius.circular(10),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
_statusIcon(),
size: 15,
color: _statusColor(),
),
const SizedBox(width: 5),
Text(
_statusLabel(t),
style: TextStyle(
color: _statusColor(),
fontSize: 11.5,
fontWeight: FontWeight.bold,
),
),
],
),
);
}

// ================================================================
// STATUS HELPERS
// ================================================================

String _normalizedStatus() {
return enrollment.status
    .trim()
    .toLowerCase();
}

Color _statusColor() {
switch (_normalizedStatus()) {
case 'approved':
return const Color(0xff2E7D32);

case 'rejected':
return const Color(0xffC0392B);

case 'pending':
default:
return const Color(0xffB26A00);
}
}

Color _statusBackgroundColor() {
switch (_normalizedStatus()) {
case 'approved':
return const Color(0xffE8F5E9);

case 'rejected':
return const Color(0xffFDECEC);

case 'pending':
default:
return const Color(0xffFFF4DD);
}
}

IconData _statusIcon() {
switch (_normalizedStatus()) {
case 'approved':
return Icons.check_circle_rounded;

case 'rejected':
return Icons.cancel_rounded;

case 'pending':
default:
return Icons.hourglass_top_rounded;
}
}

String _statusLabel(
String Function(String) t,
) {
switch (_normalizedStatus()) {
case 'approved':
return t('approved');

case 'rejected':
return t('rejected');

case 'pending':
default:
return t('pending');
}
}

String _statusMessage(
String Function(String) t,
) {
switch (_normalizedStatus()) {
case 'approved':
return t('academy_application_approved');

case 'rejected':
return t('academy_application_rejected');

case 'pending':
default:
return t('academy_application_pending');
}
}

// ================================================================
// DATE
// ================================================================

String _formatDate(DateTime date) {
final day = date.day.toString().padLeft(2, '0');
final month = date.month.toString().padLeft(2, '0');
final year = date.year.toString();

return '$day/$month/$year';
}
}
