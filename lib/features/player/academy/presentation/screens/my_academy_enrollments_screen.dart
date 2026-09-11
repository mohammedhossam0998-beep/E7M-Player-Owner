
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';

import '../providers/academy_provider.dart';
import '../widgets/academy_empty_state.dart';
import '../widgets/enrollment_status_card.dart';

class MyAcademyEnrollmentsScreen extends StatefulWidget {
const MyAcademyEnrollmentsScreen({
super.key,
});

@override
State<MyAcademyEnrollmentsScreen> createState() =>
_MyAcademyEnrollmentsScreenState();
}

class _MyAcademyEnrollmentsScreenState
extends State<MyAcademyEnrollmentsScreen> {
@override
void initState() {
super.initState();

WidgetsBinding.instance.addPostFrameCallback((_) {
if (!mounted) return;

context.read<AcademyProvider>().loadMyEnrollments();
});
}

@override
Widget build(BuildContext context) {
final t = context.watch<LanguageProvider>().translate;
final provider = context.watch<AcademyProvider>();

return Scaffold(
backgroundColor: const Color(0xffF7F7F3),

// ============================================================
// APP BAR
// ============================================================

appBar: AppBar(
backgroundColor: const Color(0xffF7F7F3),
elevation: 0,
centerTitle: true,

title: Text(
t('my_academy_enrollments'),
style: const TextStyle(
color: Color(0xff1E1446),
fontSize: 21,
fontWeight: FontWeight.bold,
),
),
),

// ============================================================
// BODY
// ============================================================

body: _buildBody(
context,
provider,
t,
),
);
}

Widget _buildBody(
BuildContext context,
AcademyProvider provider,
String Function(String) t,
) {
// ============================================================
// INITIAL LOADING
// ============================================================

if (provider.isLoadingEnrollments &&
provider.myEnrollments.isEmpty) {
return const Center(
child: CircularProgressIndicator(
color: Color(0xff7CC000),
),
);
}

// ============================================================
// ERROR
// ============================================================

if (provider.errorMessage != null &&
provider.myEnrollments.isEmpty) {
return _buildErrorState(
provider,
t,
);
}

// ============================================================
// EMPTY
// ============================================================

if (provider.myEnrollments.isEmpty) {
return AcademyEmptyState(
title: t('no_academy_enrollments'),
subtitle: t('no_academy_enrollments_description'),
icon: Icons.school_outlined,
);
}

// ============================================================
// SUCCESS
// ============================================================

return RefreshIndicator(
color: const Color(0xff7CC000),
onRefresh: provider.loadMyEnrollments,
child: ListView.separated(
physics: const AlwaysScrollableScrollPhysics(),
padding: const EdgeInsets.fromLTRB(
16,
12,
16,
30,
),
itemCount: provider.myEnrollments.length,
separatorBuilder: (_, _) {
return const SizedBox(height: 14);
},
itemBuilder: (context, index) {
final enrollment =
provider.myEnrollments[index];

return EnrollmentStatusCard(
enrollment: enrollment,
);
},
),
);
}

// ================================================================
// ERROR STATE
// ================================================================

Widget _buildErrorState(
AcademyProvider provider,
String Function(String) t,
) {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(
Icons.cloud_off_rounded,
size: 60,
color: Color(0xff1E1446),
),

const SizedBox(height: 18),

Text(
t('something_went_wrong'),
textAlign: TextAlign.center,
style: const TextStyle(
color: Color(0xff1E1446),
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

Text(
provider.errorMessage ??
t('unable_to_load_enrollments'),
textAlign: TextAlign.center,
style: const TextStyle(
color: Colors.black54,
fontSize: 14,
height: 1.45,
),
),

const SizedBox(height: 20),

ElevatedButton.icon(
onPressed: provider.loadMyEnrollments,
icon: const Icon(Icons.refresh_rounded),
label: Text(
t('try_again'),
),
style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xff7CC000),
foregroundColor: Colors.white,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(13),
),
padding: const EdgeInsets.symmetric(
horizontal: 20,
vertical: 13,
),
),
),
],
),
),
);
}
}
