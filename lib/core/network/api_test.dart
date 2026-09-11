import 'api_client.dart';

Future<void> testApi() async {
  final api = ApiClient();

  try {
    final result = await api.get('/pitches');
    print('API RESULT: $result');
  } catch (e) {
    print('API ERROR: $e');
  }
}