import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    return Scaffold(
      appBar: AppBar(title: Text(t('booking_status'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time, size: 100, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              t('booking_submitted'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              t('waiting_payment_verification'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
