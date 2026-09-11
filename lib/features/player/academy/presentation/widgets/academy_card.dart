
import 'package:flutter/material.dart';

import '../../data/models/academy_model.dart';
import '../screens/academy_details_screen.dart';

class AcademyCard extends StatelessWidget {
final AcademyModel academy;

const AcademyCard({
super.key,
required this.academy,
});

@override
Widget build(BuildContext context) {
return Material(
color: Colors.transparent,
child: InkWell(
borderRadius: BorderRadius.circular(20),
onTap: () {
Navigator.of(context).push(
MaterialPageRoute(
builder: (_) => AcademyDetailsScreen(
academyId: academy.id,
),
),
);
},
child: Container(
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(20),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(alpha: 0.06),
blurRadius: 18,
offset: const Offset(0, 7),
),
],
),
clipBehavior: Clip.antiAlias,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// ========================================================
// IMAGE
// ========================================================

AspectRatio(
aspectRatio: 16 / 8.5,
child: _buildAcademyImage(),
),

// ========================================================
// CONTENT
// ========================================================

Padding(
padding: const EdgeInsets.fromLTRB(
16,
14,
16,
16,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// --------------------------------------------------
// NAME
// --------------------------------------------------

Text(
academy.name,
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: Color(0xff1E1446),
fontSize: 19,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

// --------------------------------------------------
// LOCATION
// --------------------------------------------------

if (_hasLocation()) ...[
Row(
children: [
const Icon(
Icons.location_on_outlined,
size: 18,
color: Color(0xff7CC000),
),
const SizedBox(width: 6),
Expanded(
child: Text(
_locationText(),
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: Colors.black54,
fontSize: 13,
),
),
),
],
),
const SizedBox(height: 10),
],

// --------------------------------------------------
// DESCRIPTION
// --------------------------------------------------

if (academy.description != null &&
academy.description!.trim().isNotEmpty)
Text(
academy.description!.trim(),
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: Colors.black54,
height: 1.45,
fontSize: 13.5,
),
),

const SizedBox(height: 14),

// --------------------------------------------------
// BOTTOM ROW
// --------------------------------------------------

Row(
children: [
_buildStatusBadge(),
const Spacer(),
Container(
width: 38,
height: 38,
decoration: BoxDecoration(
color: const Color(0xff7CC000),
borderRadius: BorderRadius.circular(12),
),
child: const Icon(
Icons.arrow_forward_rounded,
color: Colors.white,
size: 21,
),
),
],
),
],
),
),
],
),
),
),
);
}

// ================================================================
// ACADEMY IMAGE
// ================================================================

Widget _buildAcademyImage() {
final imageUrl = academy.imageUrl?.trim();

if (imageUrl == null || imageUrl.isEmpty) {
return _buildImageFallback();
}

return Image.network(
imageUrl,
fit: BoxFit.cover,
errorBuilder: (
context,
error,
stackTrace,
) {
return _buildImageFallback();
},
loadingBuilder: (
context,
child,
loadingProgress,
) {
if (loadingProgress == null) {
return child;
}

return Container(
color: const Color(0xffECEDE8),
alignment: Alignment.center,
child: const CircularProgressIndicator(
strokeWidth: 2.5,
color: Color(0xff7CC000),
),
);
},
);
}

// ================================================================
// IMAGE FALLBACK
// ================================================================

Widget _buildImageFallback() {
return Container(
color: const Color(0xffECEDE8),
alignment: Alignment.center,
child: const Icon(
Icons.sports_soccer_rounded,
size: 58,
color: Color(0xff7CC000),
),
);
}

// ================================================================
// LOCATION
// ================================================================

bool _hasLocation() {
final city = academy.cityName?.trim();
final address = academy.address?.trim();

return (city != null && city.isNotEmpty) ||
(address != null && address.isNotEmpty);
}

String _locationText() {
final city = academy.cityName?.trim();
final address = academy.address?.trim();

if (city != null &&
city.isNotEmpty &&
address != null &&
address.isNotEmpty) {
return '$city • $address';
}

if (city != null && city.isNotEmpty) {
return city;
}

return address ?? '';
}

// ================================================================
// STATUS BADGE
// ================================================================

Widget _buildStatusBadge() {
final isApproved =
academy.status.toLowerCase() == 'approved';

return Container(
padding: const EdgeInsets.symmetric(
horizontal: 11,
vertical: 7,
),
decoration: BoxDecoration(
color: isApproved
? const Color(0xffEAF7D9)
    : const Color(0xffF1F1F1),
borderRadius: BorderRadius.circular(10),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
isApproved
? Icons.verified_rounded
    : Icons.info_outline_rounded,
size: 15,
color: isApproved
? const Color(0xff5B9500)
    : Colors.black54,
),
const SizedBox(width: 5),
Text(
isApproved ? 'Approved' : academy.status,
style: TextStyle(
color: isApproved
? const Color(0xff5B9500)
    : Colors.black54,
fontSize: 12,
fontWeight: FontWeight.w600,
),
),
],
),
);
}
}