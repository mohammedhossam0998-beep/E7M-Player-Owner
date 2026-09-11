import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:e7m/shared/localization/language_provider.dart';

import '../providers/revenue_provider.dart';

// ============================================================
// REVENUE EXPORT SERVICE
//
// Builds a comprehensive revenue report (Overview + last 7 days
// chart data + full transactions list) and saves it either as
// an Excel (.xlsx) or PDF (.pdf) file inside the app's temporary
// directory, ready to be shared via share_plus.
//
// NOTE (Arabic PDF text):
// The `pdf` package does not ship with an Arabic-capable font.
// To render Arabic labels correctly in the PDF, add a font that
// supports Arabic glyphs (e.g. Cairo, Noto Kufi Arabic, Tajawal)
// to your project and register it in pubspec.yaml:
//
//   flutter:
//     assets:
//       - assets/fonts/Cairo-Regular.ttf
//
// If the font asset below isn't found, the service silently
// falls back to the default PDF font (Arabic glyphs will not
// render correctly in that case, but the export will not crash).
// ============================================================

class RevenueExportService {
  RevenueExportService._();

  static const String _arabicFontAssetPath =
      'assets/fonts/Cairo-Regular.ttf';

  // ==========================================================
  // PUBLIC: EXPORT TO EXCEL
  // ==========================================================

  static Future<File> exportToExcel({
    required RevenueProvider provider,
    required LanguageProvider languageProvider,
  }) async {
    final excel = Excel.createExcel();

    final sheetName = languageProvider.translate('revenue_report');
    final Sheet sheet = excel[sheetName];

    // Excel.createExcel() ships with a default "Sheet1"; remove it
    // once our named sheet exists to avoid an extra empty tab.
    if (excel.sheets.containsKey('Sheet1') && sheetName != 'Sheet1') {
      excel.delete('Sheet1');
    }

    int row = 0;

    void writeTitle(String text) {
      sheet.appendRow([TextCellValue(text)]);
      row++;
    }

    void writeRow(List<String> values) {
      sheet.appendRow(
        values.map((v) => TextCellValue(v)).toList(),
      );
      row++;
    }

    void writeBlank() {
      sheet.appendRow([]);
      row++;
    }

    // ------------------------------------------------------
    // OVERVIEW
    // ------------------------------------------------------

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

    // ------------------------------------------------------
    // CHART DATA (LAST 7 DAYS)
    // ------------------------------------------------------

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

    // ------------------------------------------------------
    // TRANSACTIONS (ALL)
    // ------------------------------------------------------

    writeTitle(languageProvider.translate('transactions'));

    writeRow([
      languageProvider.translate('player'),
      languageProvider.translate('date'),
      languageProvider.translate('amount'),
      languageProvider.translate('status'),
    ]);

    for (final transaction in provider.allPayments) {
      writeRow([
        transaction.playerName,
        DateFormat('dd MMM yyyy').format(transaction.date),
        _amount(transaction.amount),
        languageProvider.translate(
          transaction.status.toLowerCase(),
        ),
      ]);
    }

    final bytes = excel.save();

    if (bytes == null) {
      throw Exception('Failed to generate Excel file');
    }

    final file = await _writeBytes(
      bytes: bytes,
      extension: 'xlsx',
    );

    return file;
  }

  // ==========================================================
  // PUBLIC: EXPORT TO PDF
  // ==========================================================

  static Future<File> exportToPdf({
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
          // --------------------------------------------------
          // OVERVIEW
          // --------------------------------------------------

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

          // --------------------------------------------------
          // CHART DATA (LAST 7 DAYS)
          // --------------------------------------------------

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

          // --------------------------------------------------
          // TRANSACTIONS (ALL)
          // --------------------------------------------------

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
              languageProvider.translate('amount'),
              languageProvider.translate('status'),
            ],
            data: provider.allPayments
                .map(
                  (transaction) => [
                transaction.playerName,
                dateFormat.format(transaction.date),
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

    final file = await _writeBytes(
      bytes: bytes,
      extension: 'pdf',
    );

    return file;
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  static String _amount(double value) {
    return '${NumberFormat('#,##0.00').format(value)} EGP';
  }

  static Future<pw.Font?> _loadArabicFont() async {
    try {
      final fontData = await rootBundle.load(_arabicFontAssetPath);
      return pw.Font.ttf(fontData);
    } catch (_) {
      // Font asset not found/registered — fall back to the
      // default PDF font. Arabic glyphs may not render correctly
      // in that case, but the export itself will not crash.
      return null;
    }
  }

  static Future<File> _writeBytes({
    required List<int> bytes,
    required String extension,
  }) async {
    final directory = await getTemporaryDirectory();

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final path =
        '${directory.path}/revenue_report_$timestamp.$extension';

    final file = File(path);

    await file.writeAsBytes(bytes, flush: true);

    return file;
  }
}