import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/competition_model.dart';
import '../../models/competition_payment_account_model.dart';
import '../../providers/competition_provider.dart';

class CompetitionPaymentScreen extends StatelessWidget {
  const CompetitionPaymentScreen({
    super.key,
    required this.competition,
    required this.registrationId,
  });

  final CompetitionModel competition;
  final int registrationId;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);
  static const Color background = Color(0xFFF7F9FC);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
      CompetitionProvider()
        ..loadPaymentAccounts(competition.id),
      child: _CompetitionPaymentView(
        competition: competition,
        registrationId: registrationId,
      ),
    );
  }
}

class _CompetitionPaymentView extends StatefulWidget {
  const _CompetitionPaymentView({
    required this.competition,
    required this.registrationId,
  });

  final CompetitionModel competition;
  final int registrationId;

  @override
  State<_CompetitionPaymentView> createState() =>
      _CompetitionPaymentViewState();
}

class _CompetitionPaymentViewState
    extends State<_CompetitionPaymentView> {
  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);
  static const Color background = Color(0xFFF7F9FC);

  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _transactionController =
  TextEditingController();

  CompetitionPaymentAccountModel? _selectedAccount;
  File? _proofImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _transactionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: e7mNavy,
          ),
        ),
        title: const Text(
          'Competition Payment',
          style: TextStyle(
            color: e7mNavy,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Consumer<CompetitionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading &&
              provider.paymentAccounts.isEmpty) {
            return const _LoadingView();
          }

          if (provider.hasError &&
              provider.paymentAccounts.isEmpty) {
            return _ErrorView(
              message: provider.errorMessage ??
                  'Failed to load payment accounts.',
              onRetry: () {
                provider.loadPaymentAccounts(
                  widget.competition.id,
                );
              },
            );
          }

          return _PaymentContent(
            competition: widget.competition,
            accounts: provider.paymentAccounts,
            selectedAccount: _selectedAccount,
            transactionController: _transactionController,
            proofImage: _proofImage,
            isSubmitting: _isSubmitting,
            onAccountSelected: (account) {
              setState(() {
                _selectedAccount = account;
              });
            },
            onPickProof: _pickProof,
            onRemoveProof: () {
              setState(() {
                _proofImage = null;
              });
            },
            onSubmit: () => _submitPayment(provider),
          );
        },
      ),
    );
  }

  // ==========================================================
  // PICK PAYMENT PROOF
  // ==========================================================

  Future<void> _pickProof() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Payment Proof',
                  style: TextStyle(
                    color: e7mNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: _SourceIcon(
                    icon: Icons.photo_library_outlined,
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                      ImageSource.gallery,
                    );
                  },
                ),
                ListTile(
                  leading: _SourceIcon(
                    icon: Icons.camera_alt_outlined,
                  ),
                  title: const Text(
                    'Take a Photo',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                      ImageSource.camera,
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (picked == null) return;

      setState(() {
        _proofImage = File(picked.path);
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Failed to select image: $error',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // SUBMIT PAYMENT
  // ==========================================================

  Future<void> _submitPayment(
      CompetitionProvider provider,
      ) async {
    if (_selectedAccount == null) {
      _showMessage(
        'Please select a payment method.',
        isError: true,
      );
      return;
    }

    final transactionReference =
    _transactionController.text.trim();

    if (transactionReference.length < 3) {
      _showMessage(
        'Please enter the transaction reference.',
        isError: true,
      );
      return;
    }

    if (_proofImage == null) {
      _showMessage(
        'Please upload your payment proof.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success =
      await provider.submitCompetitionPayment(
        registrationId: widget.registrationId,
        ownerPaymentAccountId:
        _selectedAccount!.id,
        transactionReference:
        transactionReference,
        proofImage: _proofImage!,
      );

      if (!mounted) return;

      if (success) {
        _showSuccessDialog();
      } else {
        _showMessage(
          provider.errorMessage ??
              'Failed to submit payment.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ==========================================================
  // SUCCESS
  // ==========================================================

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: e7mGreen.withValues(
                    alpha: 0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: e7mGreen,
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Payment Submitted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: e7mNavy,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your payment proof has been submitted successfully. The competition owner will review it.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                      ..pop()
                      ..pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: e7mGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMessage(
      String message, {
        required bool isError,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
        isError ? Colors.redAccent : e7mGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PAYMENT CONTENT
// ============================================================

class _PaymentContent extends StatelessWidget {
  const _PaymentContent({
    required this.competition,
    required this.accounts,
    required this.selectedAccount,
    required this.transactionController,
    required this.proofImage,
    required this.isSubmitting,
    required this.onAccountSelected,
    required this.onPickProof,
    required this.onRemoveProof,
    required this.onSubmit,
  });

  final CompetitionModel competition;
  final List<CompetitionPaymentAccountModel> accounts;
  final CompetitionPaymentAccountModel? selectedAccount;
  final TextEditingController transactionController;
  final File? proofImage;
  final bool isSubmitting;
  final ValueChanged<CompetitionPaymentAccountModel>
  onAccountSelected;
  final VoidCallback onPickProof;
  final VoidCallback onRemoveProof;
  final VoidCallback onSubmit;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CompetitionSummary(
            competition: competition,
          ),

          const SizedBox(height: 24),

          const _SectionTitle(
            icon: Icons.payments_outlined,
            title: 'Entry Fee',
          ),

          const SizedBox(height: 12),

          _AmountCard(
            amount: competition.entryFee,
          ),

          const SizedBox(height: 24),

          const _SectionTitle(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Payment Method',
          ),

          const SizedBox(height: 12),

          if (accounts.isEmpty)
            const _NoAccountsView()
          else
            Column(
              children: [
                for (final account in accounts)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: _PaymentAccountCard(
                      account: account,
                      selected:
                      selectedAccount?.id ==
                          account.id,
                      onTap: () {
                        onAccountSelected(account);
                      },
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 24),

          const _SectionTitle(
            icon: Icons.receipt_long_outlined,
            title: 'Transaction Reference',
          ),

          const SizedBox(height: 12),

          TextField(
            controller: transactionController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText:
              'Enter transaction reference',
              prefixIcon: const Icon(
                Icons.tag_rounded,
                color: e7mGreen,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E9EF),
                ),
              ),
              enabledBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E9EF),
                ),
              ),
              focusedBorder:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: e7mGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const _SectionTitle(
            icon: Icons.image_outlined,
            title: 'Payment Proof',
          ),

          const SizedBox(height: 12),

          _ProofCard(
            image: proofImage,
            onPick: onPickProof,
            onRemove: onRemoveProof,
          ),

          const SizedBox(height: 14),

          _PaymentNotice(),

          const SizedBox(height: 26),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: e7mGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                e7mGreen.withValues(
                  alpha: 0.45,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                width: 24,
                height: 24,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send_rounded,
                    size: 21,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Submit Payment',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COMPETITION SUMMARY
// ============================================================

class _CompetitionSummary extends StatelessWidget {
  const _CompetitionSummary({
    required this.competition,
  });

  final CompetitionModel competition;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: e7mNavy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: e7mGreen.withValues(
                alpha: 0.14,
              ),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: e7mGreen,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment for',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  competition.name,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// AMOUNT CARD
// ============================================================

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.amount,
  });

  final double amount;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: e7mGreen.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.price_check_rounded,
            color: e7mGreen,
            size: 27,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Amount to pay',
              style: TextStyle(
                color: e7mNavy,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '${_formatMoney(amount)} EGP',
            style: const TextStyle(
              color: e7mGreen,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PAYMENT ACCOUNT CARD
// ============================================================

class _PaymentAccountCard extends StatelessWidget {
  const _PaymentAccountCard({
    required this.account,
    required this.selected,
    required this.onTap,
  });

  final CompetitionPaymentAccountModel account;
  final bool selected;
  final VoidCallback onTap;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    final isWallet = account.isWallet;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? e7mGreen
                : const Color(0xFFE5E9EF),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isWallet
                    ? e7mGreen.withValues(
                  alpha: 0.10,
                )
                    : e7mNavy.withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                BorderRadius.circular(14),
              ),
              child: Icon(
                isWallet
                    ? Icons.phone_android_rounded
                    : Icons.account_balance_rounded,
                color: isWallet
                    ? e7mGreen
                    : e7mNavy,
                size: 24,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    isWallet
                        ? 'Wallet'
                        : 'InstaPay',
                    style: const TextStyle(
                      color: e7mNavy,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    account.accountName,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    account.accountIdentifier,
                    style: const TextStyle(
                      color: e7mNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            AnimatedContainer(
              duration:
              const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? e7mGreen
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: selected
                  ? Container(
                margin:
                const EdgeInsets.all(4),
                decoration:
                const BoxDecoration(
                  color: e7mGreen,
                  shape: BoxShape.circle,
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PROOF CARD
// ============================================================

class _ProofCard extends StatelessWidget {
  const _ProofCard({
    required this.image,
    required this.onPick,
    required this.onRemove,
  });

  final File? image;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  static const Color e7mGreen = Color(0xFF7CC000);

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          height: 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: e7mGreen.withValues(
                alpha: 0.30,
              ),
              width: 1.3,
            ),
          ),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: e7mGreen.withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: e7mGreen,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Upload Payment Proof',
                style: TextStyle(
                  color: Color(0xFF082B5C),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'JPG, PNG or WEBP',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E9EF),
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(
              top: Radius.circular(17),
            ),
            child: Image.file(
              image!,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: e7mGreen,
                  size: 21,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Payment proof selected',
                    style: TextStyle(
                      color: Color(0xFF082B5C),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onPick,
                  child: const Text(
                    'Change',
                    style: TextStyle(
                      color: e7mGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onRemove,
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.w700,
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
}

// ============================================================
// PAYMENT NOTICE
// ============================================================

class _PaymentNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.orange.withValues(
            alpha: 0.16,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Make the payment using the selected account, then upload a clear screenshot and enter the transaction reference.',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: e7mGreen.withValues(
              alpha: 0.10,
            ),
            borderRadius:
            BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: e7mGreen,
            size: 19,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: e7mNavy,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// NO ACCOUNTS
// ============================================================

class _NoAccountsView extends StatelessWidget {
  const _NoAccountsView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E9EF),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.grey.shade400,
            size: 36,
          ),
          const SizedBox(height: 10),
          const Text(
            'No payment accounts available',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF082B5C),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'The competition owner has not added an active payment account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOADING
// ============================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: e7mNavy.withValues(
                    alpha: 0.08,
                  ),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: e7mGreen,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading payment accounts...',
            style: TextStyle(
              color: e7mNavy,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load payment accounts',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: e7mNavy,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: e7mGreen,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SOURCE ICON
// ============================================================

class _SourceIcon extends StatelessWidget {
  const _SourceIcon({
    required this.icon,
  });

  final IconData icon;

  static const Color e7mGreen = Color(0xFF7CC000);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: e7mGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: e7mGreen,
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

String _formatMoney(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(2);
}