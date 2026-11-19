import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:e7m/shared/localization/language_provider.dart';

import '../providers/revenue_provider.dart';
import 'revenue_export_delivery.dart';

class RevenueExportService {
  RevenueExportService._();

  static const String _arabicFontAssetPath =
      'assets/fonts/Cairo-Regular.ttf';

  static Future<void> exportToExcel({
    required RevenueProvider provider,
    required LanguageProvider languageProvider,
  }) async {
    final excel = Excel.createExcel();

    final sheetName = languageProvider.translate('revenue_report');
    final Sheet sheet = excel[sheetName];

    if (excel.sheets.containsKey('Sheet1') && sheetName != 'Sheet1') {
      excel.delete('Sheet1');
    }

    void writeTitle(String text) {
      sheet.appendRow([TextCellValue(text)]);
    }

    void writeRow(List<String> values) {
      sheet.appendRow(
        values.map((value) => TextCellValue(value)).toList(),
      );
    }

    void writeBlank() {
      sheet.appendRow([]);
    }

    writeTitle(languageProvider.translate('overview'));

    writeRow([
      languageProvider.translate('current_month'),
      _amount(provider.currentMonthRevenue),
    ]);

    writeRow([
      languageProvider.translate('previous_month'),
      _amount(provider.previousMonthRevenue),
    ]);

    writeRow([
      languageProvider.translate('revenue_growth'),
      '${provider.revenueGrowthPercentage.toStringAsFixed(1)}%',
    ]);

    writeRow([
      languageProvider.translate('total_revenue'),
      _amount(provider.totalRevenue),
    ]);

    writeRow([
      languageProvider.translate('total_payments'),
      _amount(provider.totalPayments),
    ]);

    writeRow([
      languageProvider.translate('paid'),
      provider.paidCount.toString(),
    ]);

    writeRow([
      languageProvider.translate('pending'),
      provider.pendingCount.toString(),
    ]);

    writeRow([
      languageProvider.translate('failed'),
      provider.failedCount.toString(),
    ]);

    writeRow([
      languageProvider.translate('refunded'),
      provider.refundedCount.toString(),
    ]);

    writeBlank();

    writeTitle(languageProvider.translate('chart_last_7_days'));

    writeRow([
      languageProvider.translate('date'),
      languageProvider.translate('total_revenue'),
    ]);

    final chartData = provider.last7DaysRevenue;
    final sortedDates = chartData.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    for (final date in sortedDates) {
      writeRow([
        DateFormat('dd MMM yyyy').format(date),
        _amount(chartData[date] ?? 0),
      ]);
    }

    writeBlank();

    writeTitle(languageProvider.translate('transactions'));

    final isArabic =
        languageProvider.currentLocale.languageCode == 'ar';

    writeRow([
      languageProvider.translate('player'),
      languageProvider.translate('date'),
      isArabic ? 'مصدر الدفع' : 'Payment source',
      isArabic ? 'رقم المرجع' : 'Reference ID',
      languageProvider.translate('amount'),
      languageProvider.translate('status'),
    ]);

    for (final transaction in provider.allPayments) {
      writeRow([
        transaction.playerName,
        DateFormat('dd MMM yyyy').format(transaction.date),
        _sourceLabel(transaction.sourceType, isArabic),
        transaction.sourceReferenceId,
        _amount(transaction.amount),
        languageProvider.translate(transaction.status.toLowerCase()),
      ]);
    }

    final bytes = excel.save();

    if (bytes == null) {
      throw Exception('Failed to generate Excel file');
    }

    await deliverRevenueExport(
      bytes: bytes,
      fileName: _fileName('xlsx'),
      mimeType:
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      shareText: languageProvider.translate('revenue_report'),
    );
  }

  static Future<void> exportToPdf({
    required RevenueProvider provider,
    required LanguageProvider languageProvider,
  }) async {
    final pdf = pw.Document();

    final isArabic =
        languageProvider.currentLocale.languageCode == 'ar';

    final font = await _loadArabicFont();

    final theme = font != null
        ? pw.ThemeData.withFont(base: font, bold: font)
        : null;

    final textDirection =
    isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    final dateFormat = DateFormat('dd MMM yyyy');
    final chartData = provider.last7DaysRevenue;
    final sortedDates = chartData.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        textDirection: textDirection,
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Text(
          languageProvider.translate('revenue_report'),
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 12),

          pw.Text(
            languageProvider.translate('overview'),
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 8),

          pw.Table.fromTextArray(
            cellAlignment: isArabic
                ? pw.Alignment.centerRight
                : pw.Alignment.centerLeft,
            headers: [
              languageProvider.translate('overview'),
              '',
            ],
            data: [
              [
                languageProvider.translate('current_month'),
                _amount(provider.currentMonthRevenue),
              ],
              [
                languageProvider.translate('previous_month'),
                _amount(provider.previousMonthRevenue),
              ],
              [
                languageProvider.translate('revenue_growth'),
                '${provider.revenueGrowthPercentage.toStringAsFixed(1)}%',
              ],
              [
                languageProvider.translate('total_revenue'),
                _amount(provider.totalRevenue),
              ],
              [
                languageProvider.translate('total_payments'),
                _amount(provider.totalPayments),
              ],
              [
                languageProvider.translate('paid'),
                provider.paidCount.toString(),
              ],
              [
                languageProvider.translate('pending'),
                provider.pendingCount.toString(),
              ],
              [
                languageProvider.translate('failed'),
                provider.failedCount.toString(),
              ],
              [
                languageProvider.translate('refunded'),
                provider.refundedCount.toString(),
              ],
            ],
          ),

          pw.SizedBox(height: 20),

          pw.Text(
            languageProvider.translate('chart_last_7_days'),
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 8),

          pw.Table.fromTextArray(
            cellAlignment: isArabic
                ? pw.Alignment.centerRight
                : pw.Alignment.centerLeft,
            headers: [
              languageProvider.translate('date'),
              languageProvider.translate('total_revenue'),
            ],
            data: sortedDates
                .map(
                  (date) => [
                dateFormat.format(date),
                _amount(chartData[date] ?? 0),
              ],
            )
                .toList(),
          ),

          pw.SizedBox(height: 20),

          pw.Text(
            languageProvider.translate('transactions'),
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 8),

          pw.Table.fromTextArray(
            cellAlignment: isArabic
                ? pw.Alignment.centerRight
                : pw.Alignment.centerLeft,
            headers: [
              languageProvider.translate('player'),
              languageProvider.translate('date'),
              isArabic ? 'مصدر الدفع' : 'Payment source',
              isArabic ? 'رقم المرجع' : 'Reference ID',
              languageProvider.translate('amount'),
              languageProvider.translate('status'),
            ],
            data: provider.allPayments
                .map(
                  (transaction) => [
                transaction.playerName,
                dateFormat.format(transaction.date),
                _sourceLabel(transaction.sourceType, isArabic),
                transaction.sourceReferenceId,
                _amount(transaction.amount),
                languageProvider.translate(
                  transaction.status.toLowerCase(),
                ),
              ],
            )
                .toList(),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();

    await deliverRevenueExport(
      bytes: bytes,
      fileName: _fileName('pdf'),
      mimeType: 'application/pdf',
      shareText: languageProvider.translate('revenue_report'),
    );
  }

  static String _amount(double value) {
    return '${NumberFormat('#,##0.00').format(value)} EGP';
  }

  static String _sourceLabel(String source, bool isArabic) {
    switch (source) {
      case 'academy':
        return isArabic ? 'الأكاديمية' : 'Academy';
      case 'competition':
        return isArabic ? 'البطولة' : 'Tournament';
      default:
        return isArabic ? 'حجز ملعب' : 'Stadium booking';
    }
  }

  static Future<pw.Font?> _loadArabicFont() async {
    try {
      final fontData = await rootBundle.load(_arabicFontAssetPath);
      return pw.Font.ttf(fontData);
    } catch (_) {
      return null;
    }
  }

  static String _fileName(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'revenue_report_$timestamp.$extension';
  }
}