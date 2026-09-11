class CompetitionModel {
  final int id;
  final int ownerId;

  final String name;
  final String? description;
  final String? imageUrl;
  final String? location;

  final DateTime? startDate;
  final DateTime? endDate;

  final DateTime? registrationStartDate;
  final DateTime? registrationDeadline;

  final double entryFee;

  final String competitionType;
  final String approvalMode;

  final int? maxParticipants;
  final int currentParticipants;

  final int? minPlayersPerTeam;
  final int? maxPlayersPerTeam;

  final bool waitingListEnabled;
  final String visibility;

  final bool allowWithdrawal;
  final String refundPolicy;

  final int? paymentWindowMinutes;

  final String status;

  // Player registration data
  final int? registrationId;
  final String? registrationStatus;
  final DateTime? paymentDeadline;
  final DateTime? slotLockedAt;
  final DateTime? registeredAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompetitionModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.imageUrl,
    this.location,
    this.startDate,
    this.endDate,
    this.registrationStartDate,
    this.registrationDeadline,
    required this.entryFee,
    required this.competitionType,
    required this.approvalMode,
    this.maxParticipants,
    required this.currentParticipants,
    this.minPlayersPerTeam,
    this.maxPlayersPerTeam,
    required this.waitingListEnabled,
    required this.visibility,
    required this.allowWithdrawal,
    required this.refundPolicy,
    this.paymentWindowMinutes,
    required this.status,
    this.registrationId,
    this.registrationStatus,
    this.paymentDeadline,
    this.slotLockedAt,
    this.registeredAt,
    this.createdAt,
    this.updatedAt,
  });

  factory CompetitionModel.fromJson(
      Map<String, dynamic> json,
      ) {
    // /competitions response
    // uses id/name/status.
    //
    // /competitions/my response
    // uses competition_id/competition_name/competition_status.

    final startDate = _parseDateTime(
      json['start_date'] ??
          json['startDate'],
    );

    return CompetitionModel(
      // ----------------------------------------------------------
      // ID
      // ----------------------------------------------------------
      id: _parseInt(
        json['id'] ??
            json['competition_id'],
      ),

      // ----------------------------------------------------------
      // OWNER
      // ----------------------------------------------------------
      ownerId: _parseInt(
        json['created_by'] ??
            json['owner_id'] ??
            json['ownerId'],
      ),

      // ----------------------------------------------------------
      // BASIC DATA
      // ----------------------------------------------------------
      name: (
          json['name'] ??
              json['competition_name'] ??
              ''
      ).toString(),

      description:
      json['description']?.toString(),

      imageUrl:
      json['image_url']?.toString() ??
          json['imageUrl']?.toString(),

      location:
      json['location']?.toString(),

      // ----------------------------------------------------------
      // DATES
      // ----------------------------------------------------------
      // NOTE: start_date/end_date can legitimately be null (e.g. a
      // draft competition where dates haven't been set yet), so both
      // are parsed as optional. Never throw here — callers must
      // handle null (e.g. show "TBD" in the UI) instead of relying
      // on a guaranteed non-null value.
      startDate: startDate,

      // /competitions/my may not return end_date.
      // Fall back to start_date only if start_date itself is present.
      endDate: _parseOptionalDateTime(
        json['end_date'] ??
            json['endDate'],
      ) ??
          startDate,

      registrationStartDate:
      _parseDateTime(
        json['registration_start_date'] ??
            json['registrationStartDate'],
      ),

      registrationDeadline:
      _parseDateTime(
        json['registration_deadline'] ??
            json['registrationDeadline'],
      ),

      // ----------------------------------------------------------
      // PAYMENT
      // ----------------------------------------------------------
      entryFee: _parseDouble(
        json['entry_fee'] ??
            json['entryFee'],
      ),

      // ----------------------------------------------------------
      // COMPETITION TYPE
      // ----------------------------------------------------------
      competitionType: (
          json['competition_type'] ??
              json['competitionType'] ??
              'individual'
      ).toString(),

      approvalMode: (
          json['approval_mode'] ??
              json['approvalMode'] ??
              'manual'
      ).toString(),

      // ----------------------------------------------------------
      // PARTICIPANTS
      // ----------------------------------------------------------
      maxParticipants:
      _parseNullableInt(
        json['max_participants'] ??
            json['maxParticipants'],
      ),

      currentParticipants: _parseInt(
        json['current_participants'] ??
            json['currentParticipants'] ??
            0,
      ),

      minPlayersPerTeam:
      _parseNullableInt(
        json['min_players_per_team'] ??
            json['minPlayersPerTeam'],
      ),

      maxPlayersPerTeam:
      _parseNullableInt(
        json['max_players_per_team'] ??
            json['maxPlayersPerTeam'],
      ),

      // ----------------------------------------------------------
      // SETTINGS
      // ----------------------------------------------------------
      waitingListEnabled: _parseBool(
        json['waiting_list_enabled'] ??
            json['waitingListEnabled'] ??
            false,
      ),

      visibility: (
          json['visibility'] ??
              'public'
      ).toString(),

      allowWithdrawal: _parseBool(
        json['allow_withdrawal'] ??
            json['allowWithdrawal'] ??
            false,
      ),

      refundPolicy: (
          json['refund_policy'] ??
              json['refundPolicy'] ??
              'none'
      ).toString(),

      paymentWindowMinutes:
      _parseNullableInt(
        json['payment_window_minutes'] ??
            json['paymentWindowMinutes'],
      ),

      // ----------------------------------------------------------
      // STATUS
      // ----------------------------------------------------------
      status: (
          json['status'] ??
              json['competition_status'] ??
              'draft'
      ).toString(),

      // ----------------------------------------------------------
      // PLAYER REGISTRATION
      // ----------------------------------------------------------
      registrationId:
      _parseNullableInt(
        json['registration_id'],
      ),

      registrationStatus: (
          json['registration_status'] ??
              json['registrationStatus']
      )?.toString(),

      paymentDeadline:
      _parseDateTime(
        json['payment_deadline'] ??
            json['paymentDeadline'],
      ),

      slotLockedAt:
      _parseDateTime(
        json['slot_locked_at'] ??
            json['slotLockedAt'],
      ),

      registeredAt:
      _parseDateTime(
        json['registered_at'] ??
            json['registeredAt'],
      ),

      createdAt:
      _parseDateTime(
        json['created_at'] ??
            json['createdAt'],
      ),

      updatedAt:
      _parseDateTime(
        json['updated_at'] ??
            json['updatedAt'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'location': location,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'registration_start_date':
      registrationStartDate?.toIso8601String(),
      'registration_deadline':
      registrationDeadline?.toIso8601String(),
      'entry_fee': entryFee,
      'competition_type': competitionType,
      'approval_mode': approvalMode,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'min_players_per_team': minPlayersPerTeam,
      'max_players_per_team': maxPlayersPerTeam,
      'waiting_list_enabled': waitingListEnabled,
      'visibility': visibility,
      'allow_withdrawal': allowWithdrawal,
      'refund_policy': refundPolicy,
      'payment_window_minutes':
      paymentWindowMinutes,
      'status': status,
      'registration_id': registrationId,
      'registration_status':
      registrationStatus,
      'payment_deadline':
      paymentDeadline?.toIso8601String(),
      'slot_locked_at':
      slotLockedAt?.toIso8601String(),
      'registered_at':
      registeredAt?.toIso8601String(),
      'created_at':
      createdAt?.toIso8601String(),
      'updated_at':
      updatedAt?.toIso8601String(),
    };
  }

  CompetitionModel copyWith({
    int? id,
    int? ownerId,
    String? name,
    String? description,
    String? imageUrl,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? registrationStartDate,
    DateTime? registrationDeadline,
    double? entryFee,
    String? competitionType,
    String? approvalMode,
    int? maxParticipants,
    int? currentParticipants,
    int? minPlayersPerTeam,
    int? maxPlayersPerTeam,
    bool? waitingListEnabled,
    String? visibility,
    bool? allowWithdrawal,
    String? refundPolicy,
    int? paymentWindowMinutes,
    String? status,
    int? registrationId,
    String? registrationStatus,
    DateTime? paymentDeadline,
    DateTime? slotLockedAt,
    DateTime? registeredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompetitionModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      registrationStartDate:
      registrationStartDate ??
          this.registrationStartDate,
      registrationDeadline:
      registrationDeadline ??
          this.registrationDeadline,
      entryFee: entryFee ?? this.entryFee,
      competitionType:
      competitionType ??
          this.competitionType,
      approvalMode:
      approvalMode ??
          this.approvalMode,
      maxParticipants:
      maxParticipants ??
          this.maxParticipants,
      currentParticipants:
      currentParticipants ??
          this.currentParticipants,
      minPlayersPerTeam:
      minPlayersPerTeam ??
          this.minPlayersPerTeam,
      maxPlayersPerTeam:
      maxPlayersPerTeam ??
          this.maxPlayersPerTeam,
      waitingListEnabled:
      waitingListEnabled ??
          this.waitingListEnabled,
      visibility:
      visibility ??
          this.visibility,
      allowWithdrawal:
      allowWithdrawal ??
          this.allowWithdrawal,
      refundPolicy:
      refundPolicy ??
          this.refundPolicy,
      paymentWindowMinutes:
      paymentWindowMinutes ??
          this.paymentWindowMinutes,
      status: status ?? this.status,
      registrationId:
      registrationId ??
          this.registrationId,
      registrationStatus:
      registrationStatus ??
          this.registrationStatus,
      paymentDeadline:
      paymentDeadline ??
          this.paymentDeadline,
      slotLockedAt:
      slotLockedAt ??
          this.slotLockedAt,
      registeredAt:
      registeredAt ??
          this.registeredAt,
      createdAt:
      createdAt ??
          this.createdAt,
      updatedAt:
      updatedAt ??
          this.updatedAt,
    );
  }

  // ============================================================
  // PARSERS
  // ============================================================

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static int? _parseNullableInt(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static double _parseDouble(
      dynamic value,
      ) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0.0;
  }

  static bool _parseBool(
      dynamic value,
      ) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized =
    value?.toString().toLowerCase().trim();

    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes';
  }

  static DateTime? _parseOptionalDateTime(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    final text =
    value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }

  static DateTime? _parseDateTime(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    final text =
    value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }
}