class OwnerPaymentModel {
  final int id;
  final int bookingId;
  final int userId;
  final double amount;

  final String paymentMethod;
  final String status;
  final String? transactionReference;
  final String paymentType;

  final int? ownerPaymentAccountId;
  final DateTime createdAt;

  final String bookingStatus;
  final double totalPrice;
  final double depositAmount;
  final double remainingAmount;
  final String paymentStatus;

  final int slotId;
  final DateTime slotDate;
  final String startTime;
  final String endTime;

  final int pitchId;
  final String pitchName;

  final String playerName;
  final String playerEmail;

  OwnerPaymentModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionReference,
    required this.paymentType,
    this.ownerPaymentAccountId,
    required this.createdAt,
    required this.bookingStatus,
    required this.totalPrice,
    required this.depositAmount,
    required this.remainingAmount,
    required this.paymentStatus,
    required this.slotId,
    required this.slotDate,
    required this.startTime,
    required this.endTime,
    required this.pitchId,
    required this.pitchName,
    required this.playerName,
    required this.playerEmail,
  });

  factory OwnerPaymentModel.fromJson(Map<String, dynamic> json) {
    return OwnerPaymentModel(
      id: int.parse(json['id'].toString()),
      bookingId: int.parse(json['booking_id'].toString()),
      userId: int.parse(json['user_id'].toString()),

      amount: double.parse(json['amount'].toString()),

      paymentMethod:
      json['payment_method']?.toString() ?? '',

      status:
      json['status']?.toString() ?? '',

      transactionReference:
      json['transaction_reference']?.toString(),

      paymentType:
      json['payment_type']?.toString() ?? '',

      ownerPaymentAccountId:
      json['owner_payment_account_id'] != null
          ? int.parse(
        json['owner_payment_account_id'].toString(),
      )
          : null,

      createdAt:
      DateTime.parse(json['created_at'].toString()),

      bookingStatus:
      json['booking_status']?.toString() ?? '',

      totalPrice:
      double.parse(json['total_price'].toString()),

      depositAmount:
      double.parse(json['deposit_amount'].toString()),

      remainingAmount:
      double.parse(json['remaining_amount'].toString()),

      paymentStatus:
      json['payment_status']?.toString() ?? '',

      slotId:
      int.parse(json['slot_id'].toString()),

      slotDate:
      DateTime.parse(json['slot_date'].toString()),

      startTime:
      json['start_time']?.toString() ?? '',

      endTime:
      json['end_time']?.toString() ?? '',

      pitchId:
      int.parse(json['pitch_id'].toString()),

      pitchName:
      json['pitch_name']?.toString() ?? '',

      playerName:
      json['player_name']?.toString() ?? '',

      playerEmail:
      json['player_email']?.toString() ?? '',
    );
  }
}