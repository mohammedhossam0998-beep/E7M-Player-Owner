
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';

import '../../data/models/academy_program_model.dart';

class AcademyProgramCard extends StatelessWidget {
final AcademyProgramModel program;
final bool isLoading;
final VoidCallback? onApply;

const AcademyProgramCard({
super.key,
required this.program,
this.isLoading = false,
this.onApply,
});

@override
Widget build(BuildContext context) {
return Container(
padding: const EdgeInsets.all(16),

decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(18),

boxShadow: [
BoxShadow(
color: Colors.black.withValues(alpha: 0.05),
blurRadius: 15,
offset: const Offset(0, 6),
),
],
),

child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// ==========================================================
// PROGRAM HEADER
// ==========================================================

Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Expanded(
child: Text(
program.name,
maxLines: 2,
overflow: TextOverflow.ellipsis,

style: const TextStyle(
color: Color(0xff1E1446),
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
),

const SizedBox(width: 10),

Container(
width: 38,
height: 38,

decoration: BoxDecoration(
color: const Color(0xffEAF7D9),
borderRadius: BorderRadius.circular(11),
),

child: const Icon(
Icons.sports_soccer_rounded,
color: Color(0xff7CC000),
size: 21,
),
),
],
),

const SizedBox(height: 14),

// ==========================================================
// LEVEL
// ==========================================================

if (program.level != null &&
program.level!.trim().isNotEmpty)
_buildInfoRow(
icon: Icons.bar_chart_rounded,
value: program.level!.trim(),
),

// ==========================================================
// DURATION
// ==========================================================

if (program.durationWeeks != null)
_buildInfoRow(
icon: Icons.calendar_month_outlined,
value:
'${program.durationWeeks} ${_weeksLabel(context)}',
),

// ==========================================================
// PRICE
// ==========================================================

if (program.price != null)
_buildInfoRow(
icon: Icons.payments_outlined,
value:
'${program.price!.toStringAsFixed(0)} EGP',
),

// ==========================================================
// DESCRIPTION
// ==========================================================

if (program.description != null &&
program.description!.trim().isNotEmpty) ...[
const SizedBox(height: 10),

Text(
program.description!.trim(),
maxLines: 3,
overflow: TextOverflow.ellipsis,

style: const TextStyle(
color: Colors.black54,
fontSize: 13,
height: 1.45,
),
),
],

const SizedBox(height: 16),

// ==========================================================
// APPLY BUTTON
// ==========================================================

SizedBox(
width: double.infinity,
height: 48,

child: ElevatedButton(
onPressed: isLoading ? null : onApply,

style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xff7CC000),
foregroundColor: Colors.white,

disabledBackgroundColor:
const Color(0xffBFD99A),

disabledForegroundColor: Colors.white,

elevation: 0,

shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(13),
),
),

child: isLoading
? const SizedBox(
width: 21,
height: 21,

child: CircularProgressIndicator(
strokeWidth: 2.5,
color: Colors.white,
),
)
    : Text(
_applyLabel(context),

style: const TextStyle(
fontSize: 15,
fontWeight: FontWeight.bold,
),
),
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
required String value,
}) {
return Padding(
padding: const EdgeInsets.only(
bottom: 8,
),

child: Row(
children: [
Icon(
icon,
size: 18,
color: const Color(0xff7CC000),
),

const SizedBox(width: 8),

Expanded(
child: Text(
value,
maxLines: 1,
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
// LOCALIZATION
// ================================================================

String _weeksLabel(
BuildContext context,
) {
return context
    .read<LanguageProvider>()
    .translate('weeks');
}

String _applyLabel(
BuildContext context,
) {
return context
    .read<LanguageProvider>()
    .translate('apply_now');
}
}