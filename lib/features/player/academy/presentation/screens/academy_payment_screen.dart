import 'package:flutter/material.dart';

import 'package:e7m/core/network/api_client.dart';
import 'package:e7m/features/player/payments/models/payment_account_model.dart';

class AcademyPaymentScreen extends StatefulWidget {
  final int enrollmentId;
  final String academyName;
  final String programName;
  final double? programPrice;

  const AcademyPaymentScreen({
    super.key,
    required this.enrollmentId,
    required this.academyName,
    required this.programName,
    this.programPrice,
  });

  @override
  State<AcademyPaymentScreen> createState() => _AcademyPaymentScreenState();
}

class _AcademyPaymentScreenState extends State<AcademyPaymentScreen> {
  static const Color _primary = Color(0xff1E1446);
  static const Color _accent = Color(0xff7CC000);
  static const Color _background = Color(0xffF7F7F3);

  final ApiClient _api = ApiClient();
  final TextEditingController _referenceController = TextEditingController();

  List<PaymentAccountModel> _accounts = [];
  PaymentAccountModel? _selectedAccount;
  Map<String, dynamic>? _payment;
  bool _loading = true;
  bool _creating = false;
  bool _submitting = false;
  String? _error;

  bool get _ar => Localizations.localeOf(context).languageCode == 'ar';

  String _tr(String ar, String en) => _ar ? ar : en;

  bool get _pending =>
      _payment?['status']?.toString().toLowerCase() == 'pending';

  bool get _paid => _payment?['status']?.toString().toLowerCase() == 'paid';

  bool get _rejected =>
      _payment?['status']?.toString().toLowerCase() == 'rejected';

  String get _reference =>
      _payment?['transaction_reference']?.toString().trim() ?? '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final responses = await Future.wait<dynamic>([
        _api.get(
          '/payments/academy/enrollments/${widget.enrollmentId}/accounts',
        ),
        _api.get(
          '/payments/academy/enrollments/${widget.enrollmentId}',
        ),
      ]);

      final accountsJson = _asMap(responses[0]);
      final paymentsJson = _asMap(responses[1]);
      final accountItems = accountsJson['accounts'];
      final paymentItems = paymentsJson['payments'];

      if (accountItems is! List || paymentItems is! List) {
        throw Exception(
          _tr(
            'استجابة بيانات الدفع غير صحيحة.',
            'Invalid payment response.',
          ),
        );
      }

      final accounts = accountItems
          .whereType<Map>()
          .map(
            (item) => PaymentAccountModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();

      Map<String, dynamic>? latest;
      for (final item in paymentItems) {
        if (item is Map) {
          latest = Map<String, dynamic>.from(item);
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        _accounts = accounts;
        _payment = latest;
        _selectedAccount = accounts.length == 1 ? accounts.first : null;
        _referenceController.text =
            latest?['transaction_reference']?.toString() ?? '';
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = _cleanError(error);
        _loading = false;
      });
    }
  }

  Future<void> _createPayment() async {
    final account = _selectedAccount;

    if (account == null) {
      _message(
        _tr('اختار طريقة الدفع الأول.', 'Choose a payment method first.'),
        error: true,
      );
      return;
    }

    setState(() {
      _creating = true;
      _error = null;
    });

    try {
      final response = _asMap(
        await _api.post(
          '/payments/academy/enrollments/${widget.enrollmentId}',
          {
            'owner_payment_account_id': account.id,
          },
        ),
      );

      final payment = response['payment'];

      if (payment is! Map) {
        throw Exception(
          _tr('بيانات الدفعة غير صحيحة.', 'Invalid payment data.'),
        );
      }

      if (!mounted) return;

      setState(() {
        _payment = Map<String, dynamic>.from(payment);
        _creating = false;
      });

      _message(
        _tr(
          'تم إنشاء طلب الدفع. حوّل المبلغ ثم أدخل رقم المعاملة.',
          'Payment request created. Transfer the amount, then enter the reference.',
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = _cleanError(error);
        _creating = false;
      });
    }
  }

  Future<void> _submitReference() async {
    final paymentId = _toInt(_payment?['id']);
    final reference = _referenceController.text.trim();

    if (paymentId == null || paymentId <= 0) {
      _message(
        _tr(
          'رقم الدفعة غير متاح. حدّث الصفحة.',
          'Payment ID is unavailable. Refresh the page.',
        ),
        error: true,
      );
      return;
    }

    if (reference.isEmpty) {
      _message(
        _tr(
          'اكتب رقم المعاملة بعد التحويل.',
          'Enter the transaction reference after transferring.',
        ),
        error: true,
      );
      return;
    }

    if (reference.length > 255) {
      _message(
        _tr('رقم المعاملة طويل جدًا.', 'The transaction reference is too long.'),
        error: true,
      );
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final response = _asMap(
        await _api.post(
          '/payments/academy/$paymentId/submit',
          {
            'transaction_reference': reference,
          },
        ),
      );

      final updated = response['payment'];

      if (updated is! Map) {
        throw Exception(
          _tr(
            'استجابة إرسال رقم المعاملة غير صحيحة.',
            'Invalid transaction submission response.',
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        _payment = Map<String, dynamic>.from(updated);
        _referenceController.text = _reference;
        _submitting = false;
      });

      _message(
        _tr(
          'تم إرسال رقم المعاملة للمراجعة.',
          'Transaction reference sent for review.',
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = _cleanError(error);
        _submitting = false;
      });
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);

    throw Exception(
      _tr('استجابة غير صحيحة من الخادم.', 'Invalid server response.'),
    );
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String _cleanError(Object error) {
    final value = error.toString();
    return value.startsWith('Exception: ')
        ? value.substring(11)
        : value;
  }

  void _message(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? Colors.redAccent : _accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _tr('دفع الأكاديمية', 'Academy Payment'),
          style: const TextStyle(
            color: _primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _tr('تحديث', 'Refresh'),
            onPressed: _loading ? null : _load,
            icon: const Icon(
              Icons.refresh_rounded,
              color: _primary,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(
          color: _accent,
        ),
      )
          : _error != null && _accounts.isEmpty && _payment == null
          ? _errorView()
          : RefreshIndicator(
        color: _accent,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            28,
          ),
          children: [
            _programCard(),
            if (_error != null) ...[
              const SizedBox(height: 14),
              _inlineError(),
            ],
            const SizedBox(height: 16),
            if (_paid)
              _status(
                Icons.check_circle_rounded,
                _accent,
                _tr('تم تأكيد الدفع', 'Payment Approved'),
                _tr(
                  'تم اعتماد دفعة هذا البرنامج.',
                  'The payment for this program has been approved.',
                ),
              )
            else if (_pending && _reference.isNotEmpty)
              _status(
                Icons.hourglass_top_rounded,
                Colors.orange.shade700,
                _tr('الدفع قيد المراجعة', 'Payment Under Review'),
                _tr(
                  'رقم المعاملة وصل للأكاديمية. انتظر مراجعة الدفع.',
                  'The academy received your reference. Please wait for review.',
                ),
                showReference: true,
              )
            else if (_pending)
                _transferForm()
              else ...[
                  if (_rejected) ...[
                    _status(
                      Icons.cancel_rounded,
                      Colors.redAccent,
                      _tr('تم رفض الدفعة', 'Payment Rejected'),
                      _tr(
                        'أنشئ طلب دفع جديدًا وأرسل رقم معاملة صحيحًا.',
                        'Create a new payment request and submit a valid reference.',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _accountSelection(),
                ],
          ],
        ),
      ),
    );
  }

  Widget _programCard() {
    final dynamic rawAmount = _payment?['amount'] ?? widget.programPrice;
    final amount = double.tryParse(rawAmount?.toString() ?? '');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.academyName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.programName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (amount != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  color: _accent,
                ),
                const SizedBox(width: 8),
                Text(
                  '${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)} ${_tr('جنيه', 'EGP')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _accountSelection() {
    if (_accounts.isEmpty) {
      return _status(
        Icons.account_balance_wallet_outlined,
        Colors.blueGrey,
        _tr('لا توجد حسابات دفع', 'No Payment Accounts'),
        _tr(
          'الأكاديمية لم تضف حساب دفع نشطًا. حاول مرة أخرى لاحقًا.',
          'This academy has no active payment account. Try again later.',
        ),
      );
    }

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr('اختار طريقة الدفع', 'Choose a Payment Method'),
            style: const TextStyle(
              color: _primary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _tr(
              'اختار الحساب الذي ستحول إليه قيمة الاشتراك.',
              'Choose the account where you will transfer the program fee.',
            ),
            style: const TextStyle(
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ..._accounts.map(_accountTile),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _creating ? null : _createPayment,
              icon: _creating
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.arrow_forward_rounded),
              label: Text(
                _creating
                    ? _tr('جاري إنشاء الدفعة...', 'Creating payment...')
                    : _tr('متابعة للدفع', 'Continue to Payment'),
              ),
              style: _buttonStyle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountTile(PaymentAccountModel account) {
    final selected = _selectedAccount?.id == account.id;
    final provider = account.walletProvider;

    return InkWell(
      onTap: _creating
          ? null
          : () => setState(() => _selectedAccount = account),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffF0F7E7) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _accent : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              account.isInstaPay
                  ? Icons.account_balance_rounded
                  : Icons.phone_android_rounded,
              color: _primary,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _methodName(account),
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (account.accountName.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      account.accountName,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                  const SizedBox(height: 3),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      account.accountIdentifier,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (provider != null && provider.trim().isNotEmpty)
                    Text(
                      _providerName(provider),
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? _accent : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  String _methodName(PaymentAccountModel account) {
    if (!_ar) return account.displayMethod;
    if (account.isInstaPay) return 'إنستا باي';
    return _providerName(account.walletProvider ?? '');
  }

  String _providerName(String value) {
    switch (value.toLowerCase()) {
      case 'vodafone_cash':
        return _ar ? 'فودافون كاش' : 'Vodafone Cash';
      case 'orange_cash':
        return _ar ? 'أورنج كاش' : 'Orange Cash';
      case 'etisalat_cash':
        return _ar ? 'اتصالات كاش' : 'Etisalat Cash';
      case 'we_pay':
        return _ar ? 'وي باي' : 'WE Pay';
      default:
        return _ar ? 'محفظة إلكترونية' : 'Wallet';
    }
  }

  Widget _transferForm() {
    final account = _paymentAccount();

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr('بيانات التحويل', 'Transfer Details'),
            style: const TextStyle(
              color: _primary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (account != null) ...[
            _detail(_tr('طريقة الدفع', 'Method'), _methodName(account)),
            if (account.accountName.trim().isNotEmpty)
              _detail(
                _tr('اسم الحساب', 'Account Name'),
                account.accountName,
              ),
            _detail(
              _tr('رقم الحساب', 'Account Number'),
              account.accountIdentifier,
              ltr: true,
            ),
          ] else ...[
            if (_payment?['payment_method'] != null)
              _detail(
                _tr('طريقة الدفع', 'Method'),
                _payment!['payment_method'].toString(),
              ),
            if (_payment?['account_identifier'] != null)
              _detail(
                _tr('رقم الحساب', 'Account Number'),
                _payment!['account_identifier'].toString(),
                ltr: true,
              ),
            if (_payment?['account_name'] != null)
              _detail(
                _tr('اسم الحساب', 'Account Name'),
                _payment!['account_name'].toString(),
              ),
            if (_payment?['owner_payment_account_id'] != null &&
                _payment?['account_identifier'] == null)
              _detail(
                _tr('رقم حساب الدفع', 'Payment Account ID'),
                _payment!['owner_payment_account_id'].toString(),
              ),
          ],
          const SizedBox(height: 12),
          Text(
            _tr(
              'حوّل قيمة الاشتراك إلى الحساب الموضح، ثم اكتب رقم المعاملة.',
              'Transfer the fee to the account above, then enter the transaction reference.',
            ),
            style: const TextStyle(
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 13),
          TextField(
            controller: _referenceController,
            enabled: _reference.isEmpty && !_submitting,
            maxLength: 255,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: _tr('رقم المعاملة', 'Transaction Reference'),
              hintText: _tr('اكتب رقم التحويل', 'Enter transfer reference'),
              prefixIcon: const Icon(Icons.receipt_long_outlined),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _reference.isNotEmpty || _submitting
                  ? null
                  : _submitReference,
              icon: _submitting
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.send_rounded),
              label: Text(
                _submitting
                    ? _tr('جاري الإرسال...', 'Submitting...')
                    : _reference.isNotEmpty
                    ? _tr('تم إرسال رقم المعاملة', 'Reference Submitted')
                    : _tr('إرسال للمراجعة', 'Submit for Review'),
              ),
              style: _buttonStyle(),
            ),
          ),
        ],
      ),
    );
  }

  PaymentAccountModel? _paymentAccount() {
    final id = _toInt(_payment?['owner_payment_account_id']);

    for (final account in _accounts) {
      if (account.id == id) return account;
    }

    return null;
  }

  Widget _status(
      IconData icon,
      Color color,
      String title,
      String message, {
        bool showReference = false,
      }) {
    return _card(
      Column(
        children: [
          Icon(icon, size: 50, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              height: 1.45,
            ),
          ),
          if (showReference && _reference.isNotEmpty) ...[
            const SizedBox(height: 12),
            _detail(
              _tr('رقم المعاملة', 'Transaction Reference'),
              _reference,
              ltr: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _detail(
      String label,
      String value, {
        bool ltr = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Directionality(
              textDirection:
              ltr ? TextDirection.ltr : Directionality.of(context),
              child: Text(
                value,
                style: const TextStyle(
                  color: _primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inlineError() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xffffeeee),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _error!,
        style: const TextStyle(
          color: Colors.redAccent,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: _primary,
            ),
            const SizedBox(height: 14),
            Text(
              _error ??
                  _tr(
                    'تعذر تحميل بيانات الدفع.',
                    'Could not load payment data.',
                  ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(_tr('حاول مرة أخرى', 'Try Again')),
              style: _buttonStyle(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _accent,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),
    );
  }
}