import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> deliverRevenueExport({
  required List<int> bytes,
  required String fileName,
  required String mimeType,
  required String shareText,
}) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$fileName');

  await file.writeAsBytes(bytes, flush: true);

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path)],
      text: shareText,
    ),
  );
}