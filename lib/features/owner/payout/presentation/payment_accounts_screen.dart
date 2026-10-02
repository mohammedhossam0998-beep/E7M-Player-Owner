import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/owner_payment_account_model.dart';
import '../providers/owner_payment_account_provider.dart';

class PaymentAccountsScreen extends StatelessWidget {
  const PaymentAccountsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
      OwnerPaymentAccountProvider()
        ..loadAccounts(),
      child: const _PaymentAccountsBody(),
    );
  }
}

class _PaymentAccountsBody
    extends StatelessWidget {
  const _PaymentAccountsBody();

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<OwnerPaymentAccountProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Accounts',
        ),
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () {
          _openAccountForm(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),

      body: RefreshIndicator(
        onRefresh: () =>
            provider.loadAccounts(
              refresh: true,
            ),
        child: _buildBody(
          context,
          provider,
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      OwnerPaymentAccountProvider provider,
      ) {
    if (provider.isLoading &&
        provider.accounts.isEmpty) {
      return ListView(
        children: const [
          SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (provider.errorMessage != null &&
        provider.accounts.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 120),
          const Icon(
            Icons.error_outline,
            size: 55,
          ),
          const SizedBox(height: 16),
          Text(
            provider.errorMessage!,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              provider.loadAccounts(
                refresh: true,
              );
            },
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (provider.accounts.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 100),
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 70,
          ),
          SizedBox(height: 20),
          Text(
            'No payment accounts yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add InstaPay or a wallet so players can pay you.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Your Payment Accounts',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Players will use these accounts to transfer booking payments.',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 20),

        ...provider.accounts.map(
              (account) =>
              _buildAccountCard(
                context,
                provider,
                account,
              ),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildAccountCard(
      BuildContext context,
      OwnerPaymentAccountProvider provider,
      OwnerPaymentAccountModel account,
      ) {
    final isWallet =
        account.paymentMethod == 'wallet';

    final title = isWallet
        ? _walletProviderName(
      account.walletProvider,
    )
        : 'InstaPay';

    return Card(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(
                    isWallet
                        ? Icons.phone_android
                        : Icons.account_balance,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _openAccountForm(
                        context,
                        account: account,
                      );
                    }

                    if (value == 'delete') {
                      _confirmDeactivate(
                        context,
                        provider,
                        account,
                      );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Deactivate'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Account name',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              account.accountName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              isWallet
                  ? 'Wallet number'
                  : 'InstaPay account',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 4),

            SelectableText(
              account.accountIdentifier,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _walletProviderName(
      String? provider,
      ) {
    switch (provider) {
      case 'vodafone_cash':
        return 'Vodafone Cash';

      case 'orange_cash':
        return 'Orange Cash';

      case 'etisalat_cash':
        return 'Etisalat Cash';

      case 'we_pay':
        return 'WE Pay';

      case 'other_wallet':
        return 'Other Wallet';

      default:
        return 'Wallet';
    }
  }

  Future<void> _openAccountForm(
      BuildContext context, {
        OwnerPaymentAccountModel? account,
      }) async {
    // The bottom sheet is pushed on the Navigator, which sits ABOVE
    // this screen's ChangeNotifierProvider, so we pass the existing
    // provider instance into the sheet explicitly.
    final provider =
    context.read<OwnerPaymentAccountProvider>();

    final result =
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return ChangeNotifierProvider<
            OwnerPaymentAccountProvider>.value(
          value: provider,
          child: _PaymentAccountForm(
            account: account,
          ),
        );
      },
    );

    if (result == true &&
        context.mounted) {
      await context
          .read<OwnerPaymentAccountProvider>()
          .loadAccounts(
        refresh: true,
      );
    }
  }

  Future<void> _confirmDeactivate(
      BuildContext context,
      OwnerPaymentAccountProvider provider,
      OwnerPaymentAccountModel account,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Deactivate account?',
          ),
          content: Text(
            'Players will no longer see ${account.accountName} as an active payment account.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Deactivate',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !context.mounted) {
      return;
    }

    final success =
    await provider.deactivateAccount(
      account.id,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Payment account deactivated'
                : provider.errorMessage ??
                'Failed to deactivate account',
          ),
        ),
      );
  }
}


// ============================================================
// FORM
// ============================================================

class _PaymentAccountForm
    extends StatefulWidget {
  final OwnerPaymentAccountModel? account;

  const _PaymentAccountForm({
    this.account,
  });

  @override
  State<_PaymentAccountForm> createState() =>
      _PaymentAccountFormState();
}

class _PaymentAccountFormState
    extends State<_PaymentAccountForm> {
  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _nameController;

  late final TextEditingController
  _identifierController;

  String _paymentMethod = 'instapay';

  String? _walletProvider;

  bool get _isEdit =>
      widget.account != null;

  @override
  void initState() {
    super.initState();

    final account = widget.account;

    _nameController =
        TextEditingController(
          text: account?.accountName ?? '',
        );

    _identifierController =
        TextEditingController(
          text:
          account?.accountIdentifier ?? '',
        );

    if (account != null) {
      _paymentMethod =
          account.paymentMethod;

      _walletProvider =
          account.walletProvider;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<OwnerPaymentAccountProvider>();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom:
        MediaQuery.of(context)
            .viewInsets
            .bottom +
            20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                _isEdit
                    ? 'Edit Payment Account'
                    : 'Add Payment Account',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration:
                const InputDecoration(
                  labelText: 'Payment Method',
                  border:
                  OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'instapay',
                    child: Text('InstaPay'),
                  ),
                  DropdownMenuItem(
                    value: 'wallet',
                    child: Text('Wallet'),
                  ),
                ],
                onChanged: provider.isSaving
                    ? null
                    : (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _paymentMethod =
                        value;

                    if (value ==
                        'instapay') {
                      _walletProvider =
                      null;
                    }
                  });
                },
              ),

              if (_paymentMethod ==
                  'wallet') ...[
                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: _walletProvider,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Wallet Provider',
                    border:
                    OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value:
                      'vodafone_cash',
                      child:
                      Text(
                        'Vodafone Cash',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                      'orange_cash',
                      child:
                      Text(
                        'Orange Cash',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                      'etisalat_cash',
                      child:
                      Text(
                        'Etisalat Cash',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'we_pay',
                      child:
                      Text('WE Pay'),
                    ),
                    DropdownMenuItem(
                      value:
                      'other_wallet',
                      child:
                      Text(
                        'Other Wallet',
                      ),
                    ),
                  ],
                  onChanged:
                  provider.isSaving
                      ? null
                      : (value) {
                    setState(() {
                      _walletProvider =
                          value;
                    });
                  },
                  validator: (value) {
                    if (_paymentMethod ==
                        'wallet' &&
                        (value == null ||
                            value.isEmpty)) {
                      return 'Select wallet provider';
                    }

                    return null;
                  },
                ),
              ],

              const SizedBox(height: 14),

              TextFormField(
                controller:
                _nameController,
                enabled:
                !provider.isSaving,
                decoration:
                const InputDecoration(
                  labelText:
                  'Account Name',
                  border:
                  OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter account name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller:
                _identifierController,
                enabled:
                !provider.isSaving,
                keyboardType:
                _paymentMethod ==
                    'wallet'
                    ? TextInputType.phone
                    : TextInputType
                    .emailAddress,
                decoration:
                InputDecoration(
                  labelText:
                  _paymentMethod ==
                      'wallet'
                      ? 'Wallet Number'
                      : 'InstaPay Account',
                  hintText:
                  _paymentMethod ==
                      'wallet'
                      ? '01012345678'
                      : 'name@instapay',
                  border:
                  const OutlineInputBorder(),
                ),
                validator: (value) {
                  final text =
                      value?.trim() ?? '';

                  if (text.isEmpty) {
                    return 'Enter account identifier';
                  }

                  if (_paymentMethod ==
                      'wallet' &&
                      !RegExp(
                        r'^01[0125][0-9]{8}$',
                      ).hasMatch(text)) {
                    return 'Enter a valid Egyptian mobile number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed:
                  provider.isSaving
                      ? null
                      : _save,
                  child: provider.isSaving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    _isEdit
                        ? 'Save Changes'
                        : 'Add Account',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final provider =
    context
        .read<OwnerPaymentAccountProvider>();

    final success = _isEdit
        ? await provider.updateAccount(
      accountId:
      widget.account!.id,
      paymentMethod:
      _paymentMethod,
      walletProvider:
      _paymentMethod ==
          'wallet'
          ? _walletProvider
          : null,
      accountName:
      _nameController.text.trim(),
      accountIdentifier:
      _identifierController.text
          .trim(),
    )
        : await provider.addAccount(
      paymentMethod:
      _paymentMethod,
      walletProvider:
      _paymentMethod ==
          'wallet'
          ? _walletProvider
          : null,
      accountName:
      _nameController.text.trim(),
      accountIdentifier:
      _identifierController.text
          .trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(
        context,
        true,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Payment account updated'
                : 'Payment account added',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Operation failed',
          ),
        ),
      );
    }
  }
}