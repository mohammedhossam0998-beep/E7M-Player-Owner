import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/competition_model.dart';
import '../../data/models/competition_prize_model.dart';
import '../providers/competition_provider.dart';
import 'create_prize_screen.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class CompetitionPrizesScreen extends StatefulWidget {
  final CompetitionModel competition;

  const CompetitionPrizesScreen({
    super.key,
    required this.competition,
  });

  @override
  State<CompetitionPrizesScreen> createState() =>
      _CompetitionPrizesScreenState();
}

class _CompetitionPrizesScreenState
    extends State<CompetitionPrizesScreen> {
  static const Color primaryColor = Color(0xff7CC000);
  static const Color darkColor = Color(0xff1E1446);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<CompetitionProvider>()
          .loadPrizes(widget.competition.id);
    });
  }

  String _t(String key) {
    return context
        .read<LanguageProvider>()
        .translate(key);
  }

  String _amount(CompetitionPrizeModel prize) {
    if (prize.amount == null) {
      return _t('not_set');
    }

    final amount = prize.amount! % 1 == 0
        ? prize.amount!.toInt().toString()
        : prize.amount!.toString();

    if (prize.currency != null &&
        prize.currency!.trim().isNotEmpty) {
      return '$amount ${prize.currency}';
    }

    return amount;
  }

  Widget _buildPrizeCard(
      CompetitionPrizeModel prize,
      bool isLoading,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.emoji_events_outlined,
                  color: primaryColor,
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prize.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      prize.prizeType,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              if (prize.position != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF7F8FA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#${prize.position}',
                    style: const TextStyle(
                      color: darkColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),

          if (prize.description != null &&
              prize.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),

            Text(
              prize.description!,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xffF7F8FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  size: 19,
                  color: primaryColor,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    _amount(prize),
                    style: const TextStyle(
                      color: darkColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                PopupMenuButton<String>(
                  enabled: !isLoading,
                  onSelected: (value) async {
                    if (value == 'delete') {
                      await _deletePrize(prize);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          SizedBox(width: 10),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePrize(
      CompetitionPrizeModel prize,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Prize',
          ),
          content: Text(
            'Are you sure you want to delete "${prize.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final provider =
    context.read<CompetitionProvider>();

    final success = await provider.deletePrize(
      widget.competition.id,
      prize.id,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Prize deleted successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Failed to delete prize',
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                color: primaryColor,
                size: 46,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No prizes yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Add prizes to this competition.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                // هنربطه بشاشة Create Prize
                // بعد بنائها.
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Prize'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
      CompetitionProvider provider,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 58,
              color: Colors.red.shade400,
            ),

            const SizedBox(height: 16),

            Text(
              provider.errorMessage ??
                  'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<CompetitionProvider>()
                    .loadPrizes(
                  widget.competition.id,
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<CompetitionProvider>();

    final languageProvider =
    context.watch<LanguageProvider>();

    final isArabic =
        languageProvider.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xffF6F8FB),

        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: darkColor,
          elevation: 0,
          title: const Text(
            'Prizes',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreatePrizeScreen(
                  competition: widget.competition,
                ),
              ),
            );
          },
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),

        body: SafeArea(
          child: Builder(
            builder: (context) {
              if (provider.isLoading &&
                  provider.prizes.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                );
              }

              if (provider.errorMessage != null &&
                  provider.prizes.isEmpty) {
                return _buildErrorState(provider);
              }

              if (provider.prizes.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                color: primaryColor,
                onRefresh: () {
                  return provider.loadPrizes(
                    widget.competition.id,
                  );
                },
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    90,
                  ),
                  itemCount: provider.prizes.length,
                  itemBuilder: (context, index) {
                    return _buildPrizeCard(
                      provider.prizes[index],
                      provider.isLoading,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}