import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';

import '../models/transaction_model.dart';
import '../providers/revenue_provider.dart';

class RevenueChart extends StatefulWidget {
  const RevenueChart({super.key});

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final revenueProvider = context.watch<RevenueProvider>();

    final filters = [
      languageProvider.translate('week'),
      languageProvider.translate('month'),
      languageProvider.translate('year'),
    ];

    final chartData = _buildChartData(
      revenueProvider.transactions,
      selectedIndex,
    );

    final values = chartData.values;

    final maxValue = values.isEmpty
        ? 0.0
        : values.reduce(
          (a, b) => a > b ? a : b,
    );

    final chartMaxY = maxValue <= 0
        ? 10.0
        : maxValue * 1.25;

    final average = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a + b) / values.length;

    final highestValue = values.isEmpty
        ? 0.0
        : values.reduce(
          (a, b) => a > b ? a : b,
    );

    final highestIndex = values.isEmpty
        ? -1
        : values.indexOf(highestValue);

    final highestLabel = highestIndex >= 0
        ? chartData.labels[highestIndex]
        : '-';

    final growth = revenueProvider.revenueGrowthPercentage;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.translate('revenue_analytics'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E1446),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            languageProvider.translate('revenue_performance'),
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) =>
              const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final selected =
                    selectedIndex == index;

                return ChoiceChip(
                  label: Text(filters[index]),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  selectedColor:
                  const Color(0xff7CC000),
                  backgroundColor:
                  Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(30),
                  ),
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : const Color(0xff1E1446),
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          if (revenueProvider.isLoading)
            const SizedBox(
              height: 260,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xff7CC000),
                ),
              ),
            )
          else
            SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  alignment:
                  BarChartAlignment.spaceAround,

                  maxY: chartMaxY,

                  borderData:
                  FlBorderData(show: false),

                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval:
                    _getGridInterval(chartMaxY),
                  ),

                  titlesData: FlTitlesData(
                    rightTitles:
                    const AxisTitles(),
                    topTitles:
                    const AxisTitles(),
                    leftTitles:
                    const AxisTitles(),

                    bottomTitles:
                    AxisTitles(
                      sideTitles:
                      SideTitles(
                        showTitles: true,

                        reservedSize: 32,

                        getTitlesWidget:
                            (value, meta) {
                          final index =
                          value.toInt();

                          if (index < 0 ||
                              index >=
                                  chartData
                                      .labels
                                      .length) {
                            return const SizedBox();
                          }

                          return Padding(
                            padding:
                            const EdgeInsets.only(
                              top: 10,
                            ),
                            child: Text(
                              chartData
                                  .labels[index],
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  barGroups:
                  List.generate(
                    values.length,
                        (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: values[index],
                            width:
                            values.length > 15
                                ? 10
                                : 18,
                            borderRadius:
                            BorderRadius.circular(
                              8,
                            ),
                            color:
                            const Color(
                              0xff7CC000,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _RevenueInfoCard(
                  title:
                  languageProvider.translate(
                    'average',
                  ),
                  value:
                  '${average.toStringAsFixed(0)} EGP',
                  icon:
                  Icons.analytics_outlined,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _RevenueInfoCard(
                  title:
                  languageProvider.translate(
                    'highest',
                  ),
                  value: highestLabel,
                  icon:
                  Icons.trending_up,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color:
              const Color(0xff7CC000)
                  .withOpacity(.08),
              borderRadius:
              BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor:
                  Color(0xff7CC000),
                  child: Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        languageProvider
                            .translate(
                          'revenue_growth_title',
                        ),
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                          color:
                          Color(0xff1E1446),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        languageProvider
                            .translate(
                          'revenue_growth_description',
                        ),
                        style: TextStyle(
                          color:
                          Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  '${growth >= 0 ? '+' : ''}'
                      '${growth.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 22,
                    color: growth >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getGridInterval(double maxY) {
    if (maxY <= 20) return 5;
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    return maxY / 5;
  }

  _ChartData _buildChartData(
      List<TransactionModel> transactions,
      int filter,
      ) {
    final paidTransactions = transactions
        .where(
          (transaction) =>
      transaction.status.toLowerCase() ==
          'paid',
    )
        .toList();

    if (filter == 0) {
      return _buildWeekData(
        paidTransactions,
      );
    }

    if (filter == 1) {
      return _buildMonthData(
        paidTransactions,
      );
    }

    return _buildYearData(
      paidTransactions,
    );
  }

  _ChartData _buildWeekData(
      List<TransactionModel> transactions,
      ) {
    final now = DateTime.now();

    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(
      const Duration(days: 6),
    );

    final values = List<double>.filled(
      7,
      0,
    );

    final labels = <String>[];

    for (int i = 0; i < 7; i++) {
      final date = start.add(
        Duration(days: i),
      );

      labels.add(
        _dayName(date.weekday),
      );
    }

    for (final transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      final difference =
          date.difference(start).inDays;

      if (difference >= 0 &&
          difference < 7) {
        values[difference] +=
            transaction.amount;
      }
    }

    return _ChartData(
      values: values,
      labels: labels,
    );
  }

  _ChartData _buildMonthData(
      List<TransactionModel> transactions,
      ) {
    final now = DateTime.now();

    final daysInMonth = DateTime(
      now.year,
      now.month + 1,
      0,
    ).day;

    final values = List<double>.filled(
      daysInMonth,
      0,
    );

    final labels = List<String>.generate(
      daysInMonth,
          (index) => '${index + 1}',
    );

    for (final transaction in transactions) {
      if (transaction.date.year ==
          now.year &&
          transaction.date.month ==
              now.month) {
        final day =
            transaction.date.day - 1;

        if (day >= 0 &&
            day < values.length) {
          values[day] +=
              transaction.amount;
        }
      }
    }

    return _ChartData(
      values: values,
      labels: labels,
    );
  }

  _ChartData _buildYearData(
      List<TransactionModel> transactions,
      ) {
    final now = DateTime.now();

    final values = List<double>.filled(
      12,
      0,
    );

    final labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    for (final transaction in transactions) {
      if (transaction.date.year ==
          now.year) {
        final month =
            transaction.date.month - 1;

        if (month >= 0 &&
            month < 12) {
          values[month] +=
              transaction.amount;
        }
      }
    }

    return _ChartData(
      values: values,
      labels: labels,
    );
  }

  String _dayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }
}

class _ChartData {
  final List<double> values;
  final List<String> labels;

  const _ChartData({
    required this.values,
    required this.labels,
  });
}

class _RevenueInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _RevenueInfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor:
            const Color(0xff7CC000)
                .withOpacity(.10),
            child: Icon(
              icon,
              color:
              const Color(0xff7CC000),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: TextStyle(
              color:
              Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            textAlign: TextAlign.center,
            style:
            const TextStyle(
              fontWeight:
              FontWeight.bold,
              fontSize: 18,
              color:
              Color(0xff1E1446),
            ),
          ),
        ],
      ),
    );
  }
}