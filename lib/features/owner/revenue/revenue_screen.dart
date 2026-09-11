import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import '../payout/presentation/payout_screen.dart';
import 'providers/revenue_provider.dart';
import 'services/revenue_export_service.dart';
import 'widgets/recent_transactions_card.dart';
import 'widgets/revenue_chart.dart';
import 'widgets/revenue_summary_card.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

// ============================================================
// EXPORT TARGET
// ============================================================

enum _ExportTarget { excel, pdf }

class _RevenueScreenState extends State<RevenueScreen> {
  // ==========================================================
  // EXPORT STATE
  //
  // Tracks which export (if any) is currently running, so the
  // relevant AppBar action can show a spinner and both actions
  // get disabled to prevent duplicate taps.
  // ==========================================================

  _ExportTarget? _exportingTarget;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RevenueProvider>().fetchRevenue();
    });
  }

  String _formatAmount(double amount) {
    return '${NumberFormat('#,##0.00').format(amount)} EGP';
  }

  // ==========================================================
  // EXPORT HANDLERS
  // ==========================================================

  Future<void> _handleExport(_ExportTarget target) async {
    if (_exportingTarget != null) return;

    final languageProvider = context.read<LanguageProvider>();
    final revenueProvider = context.read<RevenueProvider>();

    setState(() {
      _exportingTarget = target;
    });

    try {
      final file = target == _ExportTarget.excel
          ? await RevenueExportService.exportToExcel(
        provider: revenueProvider,
        languageProvider: languageProvider,
      )
          : await RevenueExportService.exportToPdf(
        provider: revenueProvider,
        languageProvider: languageProvider,
      );

      if (!mounted) return;

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: languageProvider.translate('revenue_report'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.translate('export_failed'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _exportingTarget = null;
        });
      }
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final languageProvider =
    context.watch<LanguageProvider>();

    final revenueProvider =
    context.watch<RevenueProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,

        title: Text(
          languageProvider.translate(
            'revenue_payments',
          ),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),

        // ========================================================
        // EXPORT ACTIONS (EXCEL / PDF)
        // ========================================================

        actions: [
          IconButton(
            tooltip: languageProvider.translate('export_excel'),
            onPressed: _exportingTarget != null
                ? null
                : () => _handleExport(_ExportTarget.excel),
            icon: _exportingTarget == _ExportTarget.excel
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xff1E1446),
              ),
            )
                : const Icon(
              Icons.table_chart_outlined,
              color: Color(0xff1E1446),
            ),
          ),

          IconButton(
            tooltip: languageProvider.translate('export_pdf'),
            onPressed: _exportingTarget != null
                ? null
                : () => _handleExport(_ExportTarget.pdf),
            icon: _exportingTarget == _ExportTarget.pdf
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xff1E1446),
              ),
            )
                : const Icon(
              Icons.picture_as_pdf_outlined,
              color: Color(0xff1E1446),
            ),
          ),

          const SizedBox(width: 4),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xff7CC000),

          onRefresh: revenueProvider.refresh,

          child: ListView(
            padding: const EdgeInsets.all(20),
            physics:
            const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),

            children: [
              // ============================================================
              // LOADING
              // ============================================================

              if (revenueProvider.isLoading)
                const Padding(
                  padding:
                  EdgeInsets.only(bottom: 20),
                  child: LinearProgressIndicator(
                    color: Color(0xff7CC000),
                    backgroundColor:
                    Color(0xffE8E8E8),
                  ),
                ),

              // ============================================================
              // ERROR
              // ============================================================

              if (revenueProvider.error != null)
                Container(
                  margin:
                  const EdgeInsets.only(
                    bottom: 20,
                  ),
                  padding:
                  const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                    Colors.red.withOpacity(.08),
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          revenueProvider.error!,
                          style:
                          const TextStyle(
                            color: Colors.red,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed:
                        revenueProvider.refresh,
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

              // ============================================================
              // REVENUE OVERVIEW
              // ============================================================

              Container(
                padding:
                const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(.05),
                      blurRadius: 12,
                      offset:
                      const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      languageProvider.translate(
                        'revenue_overview',
                      ),
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                        fontSize: 22,
                        color:
                        Color(0xff1E1446),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      languageProvider.translate(
                        'this_month',
                      ),
                      style: TextStyle(
                        color:
                        Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      _formatAmount(
                        revenueProvider
                            .currentMonthRevenue,
                      ),
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                        fontSize: 34,
                        color:
                        Color(0xff1E1446),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          revenueProvider
                              .revenueGrowthPercentage >=
                              0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color:
                          revenueProvider
                              .revenueGrowthPercentage >=
                              0
                              ? Colors.green
                              : Colors.red,
                        ),

                        const SizedBox(width: 6),

                        Expanded(
                          child: Text(
                            '${revenueProvider.revenueGrowthPercentage >= 0 ? '+' : ''}'
                                '${revenueProvider.revenueGrowthPercentage.toStringAsFixed(1)}% '
                                '${languageProvider.translate('revenue_growth')}',
                            style: TextStyle(
                              color: revenueProvider
                                  .revenueGrowthPercentage >=
                                  0
                                  ? Colors.green
                                  .shade700
                                  : Colors.red
                                  .shade700,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ============================================================
              // CHART
              // ============================================================

              const RevenueChart(),

              const SizedBox(height: 24),

              // ============================================================
              // SUMMARY
              // ============================================================

              const RevenueSummaryCard(),

              const SizedBox(height: 24),

              // ============================================================
              // RECENT TRANSACTIONS
              // ============================================================

              RecentTransactionsCard(
                transactions:
                revenueProvider
                    .recentTransactions,

                onViewAll: () {
                  // لا توجد شاشة All Transactions
                  // مرتبطة بالـ Backend حاليًا.
                },
              ),

              const SizedBox(height: 24),

              // ============================================================
              // PAYOUT
              // ============================================================

              Container(
                padding:
                const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(.05),
                      blurRadius: 12,
                      offset:
                      const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    const Icon(
                      Icons
                          .account_balance_wallet_rounded,
                      color:
                      Color(0xff7CC000),
                      size: 50,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      languageProvider.translate(
                        'withdraw_your_earnings',
                      ),
                      textAlign:
                      TextAlign.center,
                      style:
                      const TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        Color(0xff1E1446),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${languageProvider.translate('available_balance')}: '
                          '${_formatAmount(revenueProvider.totalRevenue)}',
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        color:
                        Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child:
                      FilledButton.icon(
                        style:
                        FilledButton.styleFrom(
                          backgroundColor:
                          const Color(
                            0xff7CC000,
                          ),
                        ),

                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const PayoutScreen(),
                            ),
                          );
                        },

                        icon: const Icon(
                          Icons.payments,
                          color: Colors.white,
                        ),

                        label: Text(
                          languageProvider
                              .translate(
                            'request_payout',
                          ),
                          style:
                          const TextStyle(
                            color: Colors.white,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}