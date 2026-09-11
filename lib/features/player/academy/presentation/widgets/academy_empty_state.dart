
import 'package:flutter/material.dart';

class AcademyEmptyState extends StatelessWidget {
final String title;
final String? subtitle;
final IconData icon;

const AcademyEmptyState({
super.key,
required this.title,
this.subtitle,
this.icon = Icons.school_outlined,
});

@override
Widget build(BuildContext context) {
return Center(
child: SingleChildScrollView(
physics: const AlwaysScrollableScrollPhysics(),
padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
// ==========================================================
// ICON
// ==========================================================

Container(
width: 92,
height: 92,
decoration: BoxDecoration(
color: const Color(0xffEAF7D9),
borderRadius: BorderRadius.circular(28),
),
child: Icon(
icon,
size: 48,
color: const Color(0xff7CC000),
),
),

const SizedBox(height: 22),

// ==========================================================
// TITLE
// ==========================================================

Text(
title,
textAlign: TextAlign.center,
style: const TextStyle(
color: Color(0xff1E1446),
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

// ==========================================================
// SUBTITLE
// ==========================================================

if (subtitle != null &&
subtitle!.trim().isNotEmpty) ...[
const SizedBox(height: 10),
Text(
subtitle!.trim(),
textAlign: TextAlign.center,
style: const TextStyle(
color: Colors.black54,
fontSize: 14,
height: 1.5,
),
),
],
],
),
),
);
}
}
