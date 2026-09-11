
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/competition_model.dart';
import '../../presentation/providers/competition_provider.dart';
import 'package:e7m/shared/localization/language_provider.dart';
class CreateCompetitionScreen extends StatefulWidget {
const CreateCompetitionScreen({super.key});

@override
State<CreateCompetitionScreen> createState() =>
_CreateCompetitionScreenState();
}

class _CreateCompetitionScreenState
extends State<CreateCompetitionScreen> {
final GlobalKey<FormState> _formKey =
GlobalKey<FormState>();

final TextEditingController _nameController =
TextEditingController();

final TextEditingController _descriptionController =
TextEditingController();

final TextEditingController _locationController =
TextEditingController();

final TextEditingController _entryFeeController =
TextEditingController();

final TextEditingController _maxParticipantsController =
TextEditingController();

final TextEditingController _minPlayersPerTeamController =
TextEditingController();

final TextEditingController _maxPlayersPerTeamController =
TextEditingController();

DateTime? _registrationStartDate;
DateTime? _registrationDeadline;
DateTime? _startDate;
DateTime? _endDate;

String _competitionType = 'team';
String _approvalMode = 'auto';
String _visibility = 'public';
String _refundPolicy = 'none';

bool _waitingListEnabled = false;
bool _allowWithdrawal = true;

bool _submitting = false;

static const Color primaryColor =
Color(0xff7CC000);

static const Color darkColor =
Color(0xff1E1446);

String _t(
BuildContext context,
String key,
) {
return context
    .read<LanguageProvider>()
    .translate(key);
}

@override
void dispose() {
_nameController.dispose();
_descriptionController.dispose();
_locationController.dispose();
_entryFeeController.dispose();
_maxParticipantsController.dispose();
_minPlayersPerTeamController.dispose();
_maxPlayersPerTeamController.dispose();

super.dispose();
}

// ============================================================
// DATE PICKER
// ============================================================

Future<DateTime?> _pickDateTime({
required DateTime firstDate,
DateTime? initialDate,
}) async {
DateTime initial =
initialDate ?? firstDate;

if (initial.isBefore(firstDate)) {
initial = firstDate;
}

final DateTime? date =
await showDatePicker(
context: context,
initialDate: initial,
firstDate: firstDate,
lastDate: DateTime(2100),
);

if (!mounted || date == null) {
return null;
}

final TimeOfDay? time =
await showTimePicker(
context: context,
initialTime: initialDate != null
? TimeOfDay.fromDateTime(
initialDate,
)
    : TimeOfDay.now(),
);

if (!mounted || time == null) {
return null;
}

return DateTime(
date.year,
date.month,
date.day,
time.hour,
time.minute,
);
}

Future<void> _selectRegistrationStart() async {
final value =
await _pickDateTime(
firstDate: DateTime.now(),
initialDate:
_registrationStartDate,
);

if (value == null) return;

setState(() {
_registrationStartDate = value;

if (_registrationDeadline != null &&
_registrationDeadline!.isBefore(value)) {
_registrationDeadline = null;
}
});
}

Future<void> _selectRegistrationDeadline() async {
final value =
await _pickDateTime(
firstDate:
_registrationStartDate ??
DateTime.now(),
initialDate:
_registrationDeadline,
);

if (value == null) return;

setState(() {
_registrationDeadline = value;

if (_startDate != null &&
_startDate!.isBefore(value)) {
_startDate = null;
_endDate = null;
}
});
}

Future<void> _selectStartDate() async {
final value =
await _pickDateTime(
firstDate:
_registrationDeadline ??
DateTime.now(),
initialDate: _startDate,
);

if (value == null) return;

setState(() {
_startDate = value;

if (_endDate != null &&
_endDate!.isBefore(value)) {
_endDate = null;
}
});
}

Future<void> _selectEndDate() async {
final value =
await _pickDateTime(
firstDate:
_startDate ??
DateTime.now(),
initialDate: _endDate,
);

if (value == null) return;

setState(() {
_endDate = value;
});
}

// ============================================================
// VALIDATION
// ============================================================

String? _requiredText(
String? value,
String key,
) {
if (value == null ||
value.trim().isEmpty) {
return _t(context, key);
}

return null;
}

String? _numberValidator(
String? value,
) {
if (value == null ||
value.trim().isEmpty) {
return null;
}

if (double.tryParse(value.trim()) == null) {
return _t(
context,
'entry_fee_invalid',
);
}

return null;
}

String _formatDateTime(
DateTime? value,
) {
if (value == null) {
return _t(
context,
'not_set',
);
}

final day =
value.day
    .toString()
    .padLeft(2, '0');

final month =
value.month
    .toString()
    .padLeft(2, '0');

final hour =
value.hour
    .toString()
    .padLeft(2, '0');

final minute =
value.minute
    .toString()
    .padLeft(2, '0');

return '$day/$month/${value.year} '
'$hour:$minute';
}

// ============================================================
// SUBMIT
// ============================================================

Future<void> _createCompetition() async {
FocusScope.of(context).unfocus();

if (_submitting) {
return;
}

if (!(_formKey.currentState?.validate() ?? false)) {
return;
}

if (_registrationStartDate == null ||
_registrationDeadline == null) {
_showError(
_t(
context,
'registration_dates_required',
),
);
return;
}

if (_registrationDeadline!
    .isBefore(_registrationStartDate!)) {
_showError(
_t(
context,
'registration_dates_invalid',
),
);
return;
}

if (_startDate == null ||
_endDate == null) {
_showError(
_t(
context,
'competition_dates_required',
),
);
return;
}

if (_startDate!
    .isBefore(_registrationDeadline!)) {
_showError(
_t(
context,
'competition_after_registration',
),
);
return;
}

if (_endDate!.isBefore(_startDate!)) {
_showError(
_t(
context,
'competition_end_after_start',
),
);
return;
}

final entryFeeText =
_entryFeeController.text.trim();

final double entryFee =
entryFeeText.isEmpty
? 0
    : double.parse(entryFeeText);

final maxParticipantsText =
_maxParticipantsController.text
    .trim();

final int? maxParticipants =
maxParticipantsText.isEmpty
? null
    : int.tryParse(
maxParticipantsText,
);

final minPlayersText =
_minPlayersPerTeamController.text
    .trim();

final maxPlayersText =
_maxPlayersPerTeamController.text
    .trim();

final int? minPlayersPerTeam =
minPlayersText.isEmpty
? null
    : int.tryParse(
minPlayersText,
);

final int? maxPlayersPerTeam =
maxPlayersText.isEmpty
? null
    : int.tryParse(
maxPlayersText,
);

if (maxParticipantsText.isNotEmpty &&
maxParticipants == null) {
_showError(
_t(
context,
'teams_count_invalid',
),
);
return;
}

if (_competitionType == 'team') {
if (minPlayersPerTeam == null ||
maxPlayersPerTeam == null) {
_showError(
_t(
context,
'teams_count_invalid',
),
);
return;
}

if (minPlayersPerTeam <= 0 ||
maxPlayersPerTeam <= 0 ||
minPlayersPerTeam >
maxPlayersPerTeam) {
_showError(
_t(
context,
'teams_count_invalid',
),
);
return;
}
}

// ==========================================================
// API BODY
// ==========================================================

final Map<String, dynamic> data =
<String, dynamic>{
'name':
_nameController.text.trim(),

'description':
_descriptionController.text
    .trim()
    .isEmpty
? null
    : _descriptionController
    .text
    .trim(),

'location':
_locationController.text
    .trim()
    .isEmpty
? null
    : _locationController
    .text
    .trim(),

'start_date':
_startDate!.toIso8601String(),

'end_date':
_endDate!.toIso8601String(),

'registration_start_date':
_registrationStartDate!
    .toIso8601String(),

'registration_deadline':
_registrationDeadline!
    .toIso8601String(),

'entry_fee':
entryFee,

'competition_type':
_competitionType,

'max_participants':
maxParticipants,

'min_players_per_team':
_competitionType == 'team'
? minPlayersPerTeam
    : null,

'max_players_per_team':
_competitionType == 'team'
? maxPlayersPerTeam
    : null,

'approval_mode':
_approvalMode,

'waiting_list_enabled':
_waitingListEnabled,

'visibility':
_visibility,

'allow_withdrawal':
_allowWithdrawal,

'refund_policy':
_refundPolicy,
};

// ==========================================================
// PROVIDER → REPOSITORY → SERVICE → API
// ==========================================================

setState(() {
_submitting = true;
});

final provider =
context.read<CompetitionProvider>();

final CompetitionModel? competition =
await provider.createCompetition(
data,
);

if (!mounted) {
return;
}

setState(() {
_submitting = false;
});

if (competition != null) {
ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
_t(
context,
'competition_created_successfully',
),
),
),
);

Navigator.of(context).pop(
competition,
);

return;
}

final error =
provider.errorMessage;

_showError(
error != null &&
error.trim().isNotEmpty
? error
    : _t(
context,
'error_occurred',
),
);
}

// ============================================================
// ERROR
// ============================================================

void _showError(
String message,
) {
if (!mounted) return;

ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(message),
),
);
}

// ============================================================
// INPUT DECORATION
// ============================================================

InputDecoration _decoration({
required String labelKey,
required IconData icon,
}) {
return InputDecoration(
labelText:
_t(context, labelKey),
prefixIcon: Icon(
icon,
color: primaryColor,
),
filled: true,
fillColor: Colors.white,
border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(16),
),
enabledBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(16),
borderSide:
BorderSide(
color:
Colors.grey.shade300,
),
),
focusedBorder:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(16),
borderSide:
const BorderSide(
color: primaryColor,
width: 1.5,
),
),
);
}

// ============================================================
// SECTION
// ============================================================

Widget _sectionTitle(
String key,
) {
return Padding(
padding:
const EdgeInsets.only(
bottom: 14,
),
child: Text(
_t(context, key),
style:
const TextStyle(
color: darkColor,
fontSize: 20,
fontWeight:
FontWeight.w800,
),
),
);
}

// ============================================================
// DATE FIELD
// ============================================================

Widget _dateField({
required String labelKey,
required DateTime? value,
required VoidCallback onTap,
required IconData icon,
}) {
return InkWell(
onTap:
_submitting
? null
    : onTap,
borderRadius:
BorderRadius.circular(16),
child: InputDecorator(
decoration:
_decoration(
labelKey: labelKey,
icon: icon,
),
child: Text(
_formatDateTime(value),
style: TextStyle(
color: value == null
? Colors.grey.shade500
    : darkColor,
fontWeight:
FontWeight.w600,
),
),
),
);
}

// ============================================================
// DROPDOWN
// ============================================================

Widget _dropdown({
required String labelKey,
required String value,
required IconData icon,
required List<
DropdownMenuItem<String>>
items,
required ValueChanged<String?>
onChanged,
}) {
return DropdownButtonFormField<
String>(
initialValue: value,
decoration:
_decoration(
labelKey: labelKey,
icon: icon,
),
items: items,
onChanged:
_submitting
? null
    : onChanged,
);
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(
BuildContext context,
) {
final languageProvider =
context.watch<LanguageProvider>();

final provider =
context.watch<CompetitionProvider>();

final bool loading =
_submitting ||
provider.isLoading;

final bool isArabic =
languageProvider
    .locale
    .languageCode ==
'ar';

return Directionality(
textDirection: isArabic
? TextDirection.rtl
    : TextDirection.ltr,
child: Scaffold(
backgroundColor:
const Color(0xffF6F8FB),
appBar: AppBar(
backgroundColor:
Colors.white,
foregroundColor:
darkColor,
elevation: 0,
centerTitle: true,
title: Text(
_t(
context,
'create_competition',
),
style:
const TextStyle(
fontWeight:
FontWeight.w800,
),
),
),
body: SafeArea(
child: Form(
key: _formKey,
child: ListView(
padding:
const EdgeInsets.all(
20,
),
children: [
// ==================================================
// INFORMATION
// ==================================================

_sectionTitle(
'competition_information',
),

TextFormField(
controller:
_nameController,
enabled: !loading,
maxLength: 150,
validator: (value) =>
_requiredText(
value,
'competition_name_required',
),
decoration:
_decoration(
labelKey:
'competition_name',
icon: Icons
    .emoji_events_outlined,
),
),

const SizedBox(
height: 16,
),

TextFormField(
controller:
_descriptionController,
enabled: !loading,
maxLines: 4,
decoration:
_decoration(
labelKey:
'description',
icon: Icons
    .description_outlined,
),
),

const SizedBox(
height: 16,
),

TextFormField(
controller:
_locationController,
enabled: !loading,
decoration:
_decoration(
labelKey:
'location',
icon: Icons
    .location_on_outlined,
),
),

const SizedBox(
height: 24,
),

// ==================================================
// SYSTEM
// ==================================================

_sectionTitle(
'competition_system',
),

_dropdown(
labelKey:
'competition_system',
value:
_competitionType,
icon:
Icons.groups_outlined,
items: [
DropdownMenuItem(
value: 'team',
child: Text(
_t(
context,
'teams',
),
),
),
DropdownMenuItem(
value: 'individual',
child: Text(
_t(
context,
'player',
),
),
),
],
onChanged:
(value) {
if (value == null) {
return;
}

setState(() {
_competitionType =
value;

if (value ==
'individual') {
_minPlayersPerTeamController
    .clear();

_maxPlayersPerTeamController
    .clear();
}
});
},
),

const SizedBox(
height: 16,
),

TextFormField(
controller:
_maxParticipantsController,
enabled: !loading,
keyboardType:
TextInputType.number,
decoration:
_decoration(
labelKey:
'maximum_teams',
icon: Icons
    .groups_2_outlined,
),
),

if (_competitionType ==
'team') ...[
const SizedBox(
height: 16,
),

TextFormField(
controller:
_minPlayersPerTeamController,
enabled: !loading,
keyboardType:
TextInputType.number,
decoration:
_decoration(
labelKey:
'minimum_teams',
icon: Icons
    .person_add_alt_1_outlined,
),
),

const SizedBox(
height: 16,
),

TextFormField(
controller:
_maxPlayersPerTeamController,
enabled: !loading,
keyboardType:
TextInputType.number,
decoration:
_decoration(
labelKey:
'maximum_teams',
icon: Icons
    .groups_outlined,
),
),
],

const SizedBox(
height: 28,
),

// ==================================================
// REGISTRATION
// ==================================================

_sectionTitle(
'registration_opens',
),

_dateField(
labelKey:
'registration_opens',
value:
_registrationStartDate,
icon: Icons
    .event_available_outlined,
onTap:
_selectRegistrationStart,
),

const SizedBox(
height: 16,
),

_dateField(
labelKey:
'registration_closes',
value:
_registrationDeadline,
icon: Icons
    .event_busy_outlined,
onTap:
_selectRegistrationDeadline,
),

const SizedBox(
height: 28,
),

// ==================================================
// SCHEDULE
// ==================================================

_sectionTitle(
'competition_schedule',
),

_dateField(
labelKey:
'competition_starts',
value:
_startDate,
icon: Icons
    .play_circle_outline,
onTap:
_selectStartDate,
),

const SizedBox(
height: 16,
),

_dateField(
labelKey:
'competition_ends',
value:
_endDate,
icon: Icons
    .stop_circle_outlined,
onTap:
_selectEndDate,
),

const SizedBox(
height: 28,
),

// ==================================================
// FINANCIAL
// ==================================================

_sectionTitle(
'financial',
),

TextFormField(
controller:
_entryFeeController,
enabled: !loading,
keyboardType:
const TextInputType
    .numberWithOptions(
decimal: true,
),
validator:
_numberValidator,
decoration:
_decoration(
labelKey:
'entry_fee',
icon: Icons
    .payments_outlined,
),
),

const SizedBox(
height: 28,
),

// ==================================================
// RULES
// ==================================================

_sectionTitle(
'competition_rules',
),

_dropdown(
labelKey:
'approval_mode',
value:
_approvalMode,
icon: Icons
    .fact_check_outlined,
items: [
DropdownMenuItem(
value: 'auto',
child: Text(
_t(
context,
'auto',
),
),
),
DropdownMenuItem(
value: 'manual',
child: Text(
_t(
context,
'manual',
),
),
),
],
onChanged:
(value) {
if (value == null) {
return;
}

setState(() {
_approvalMode =
value;
});
},
),

const SizedBox(
height: 16,
),

_dropdown(
labelKey:
'visibility',
value:
_visibility,
icon: Icons
    .visibility_outlined,
items: [
DropdownMenuItem(
value: 'public',
child: Text(
_t(
context,
'public',
),
),
),
DropdownMenuItem(
value: 'private',
child: Text(
_t(
context,
'private',
),
),
),
],
onChanged:
(value) {
if (value == null) {
return;
}

setState(() {
_visibility =
value;
});
},
),

const SizedBox(
height: 16,
),

_dropdown(
labelKey:
'refund_policy',
value:
_refundPolicy,
icon: Icons
    .currency_exchange_outlined,
items: [
DropdownMenuItem(
value: 'none',
child: Text(
_t(
context,
'not_set',
),
),
),
DropdownMenuItem(
value:
'full_before_deadline',
child: Text(
_t(
context,
'full_refund_before_deadline',
),
),
),
DropdownMenuItem(
value: 'tiered',
child: Text(
_t(
context,
'tiered_refund',
),
),
),
],
onChanged:
(value) {
if (value == null) {
return;
}

setState(() {
_refundPolicy =
value;
});
},
),

SwitchListTile.adaptive(
contentPadding:
EdgeInsets.zero,
value:
_waitingListEnabled,
activeColor:
primaryColor,
title: Text(
_t(
context,
'waiting_list_enabled',
),
),
onChanged: loading
? null
    : (value) {
setState(() {
_waitingListEnabled =
value;
});
},
),

SwitchListTile.adaptive(
contentPadding:
EdgeInsets.zero,
value:
_allowWithdrawal,
activeColor:
primaryColor,
title: Text(
_t(
context,
'allow_withdrawal',
),
),
onChanged: loading
? null
    : (value) {
setState(() {
_allowWithdrawal =
value;
});
},
),

const SizedBox(
height: 24,
),

// ==================================================
// CREATE
// ==================================================

SizedBox(
height: 56,
width:
double.infinity,
child:
ElevatedButton(
onPressed:
loading
? null
    : _createCompetition,
style:
ElevatedButton
    .styleFrom(
backgroundColor:
primaryColor,
foregroundColor:
Colors.white,
disabledBackgroundColor:
Colors.grey
    .shade300,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius
    .circular(
16,
),
),
),
child: loading
? const SizedBox(
width: 24,
height: 24,
child:
CircularProgressIndicator(
strokeWidth:
2.5,
color:
Colors.white,
),
)
    : Text(
_t(
context,
'create_competition',
),
style:
const TextStyle(
fontSize:
16,
fontWeight:
FontWeight.w800,
),
),
),
),
],
),
),
),
),
);
}
}
