class TransactionModel {
  final String id;
  final String sourceType;
  final String sourceReferenceId;
  final String bookingId;
  final String playerName;
  final String playerEmail;
  final String pitchName;
  final double amount;
  final double refundedAmount;

  final String paymentMethod;
  final String paymentType;
  final String status;
  final String bookingStatus;
  final String paymentStatus;
  final DateTime date;
  final DateTime? slotDate;
  final String? startTime;
  final String? endTime;

  double get recognizedAmount {
    if (status == 'refunded') return 0;

    if (status == 'partially_refunded') {
      return (amount - refundedAmount).clamp(0, amount).toDouble();
    }

    return amount;
  }

  const TransactionModel({
    required this.id,
    this.sourceType = 'booking',
    this.sourceReferenceId = '',
    required this.bookingId,
    required this.playerName,
    required this.playerEmail,
    required this.pitchName,
    required this.amount,
    this.refundedAmount = 0,
    required this.paymentMethod,
    required this.paymentType,
    required this.status,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.date,
    this.slotDate,
    this.startTime,
    this.endTime,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id']?.toString() ?? '',
      sourceType: map['source_type']?.toString() ?? 'booking',
      sourceReferenceId: map['source_reference_id']?.toString() ??
          map['booking_id']?.toString() ??
          '',
      bookingId: map['booking_id']?.toString() ?? '',
      playerName: map['player_name']?.toString() ?? '',
      playerEmail: map['player_email']?.toString() ?? '',
      pitchName: map['pitch_name']?.toString() ?? '',
      amount: _toDouble(map['amount']),
      refundedAmount:
      _toDouble(map['refunded_amount'] ?? map['refund_amount']),
      paymentMethod: map['payment_method']?.toString() ?? '',
      paymentType: map['payment_type']?.toString() ?? '',
      status: normalizePaymentStatus(
        map['status']?.toString() ??
            map['payment_status']?.toString() ??
            '',
      ),
      bookingStatus: map['booking_status']?.toString() ?? '',
      paymentStatus: map['payment_status']?.toString() ?? '',
      date: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      slotDate: map['slot_date'] != null
          ? DateTime.tryParse(map['slot_date'].toString())
          : null,
      startTime: map['start_time']?.toString(),
      endTime: map['end_time']?.toString(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}

String normalizePaymentStatus(String rawStatus) {
  switch (rawStatus.trim().toLowerCase()) {
    case 'approved':
    case 'success':
    case 'succeeded':
    case 'complete':
    case 'completed':
      return 'paid';

    case 'submitted':
    case 'review':
    case 'awaiting':
    case 'processing':
      return 'pending';

    case 'rejected':
    case 'cancelled':
    case 'canceled':
    case 'expired':
      return 'failed';

    case 'partially_refunded':
      return 'partially_refunded';

    default:
      return rawStatus.trim().toLowerCase();
  }
}