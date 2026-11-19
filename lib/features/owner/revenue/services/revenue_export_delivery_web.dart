import 'dart:async';
import 'dart:html' as html;

Future<void> deliverRevenueExport({
  required List<int> bytes,
  required String fileName,
  required String mimeType,
  required String shareText,
}) async {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..download = fileName
    ..style.display = 'none';

  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();

  Timer(
    const Duration(seconds: 1),
        () => html.Url.revokeObjectUrl(url),
  );
}