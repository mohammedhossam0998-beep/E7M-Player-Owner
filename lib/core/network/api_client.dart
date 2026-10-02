import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:e7m/core/services/token_storage.dart';

// ============================================================
// API EXCEPTION
//
// toString() returns only the message, so existing code that does
//   e.toString().replaceFirst('Exception: ', '')
// keeps working and never shows a technical prefix to the user.
// ============================================================

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  // ============================================================
  // BASE URL
  //
  // Priority:
  //   1. --dart-define=API_BASE_URL=https://api.example.com
  //   2. Release build  -> _prodBaseUrl (must be HTTPS)
  //   3. Debug build    -> _devBaseUrl  (local LAN IP)
  //
  // Release example:
  //   flutter build appbundle --release \
  //     --dart-define=API_BASE_URL=https://api.your-domain.com
  //
  // Do NOT include /api here. _buildUrl adds it automatically.
  // ============================================================

  static const String _envBaseUrl =
  String.fromEnvironment('API_BASE_URL');

  // TODO: replace with your real production HTTPS domain.
  static const String _prodBaseUrl = 'https://api.your-domain.com';

  static const String _devBaseUrl = 'http://192.168.1.3:5000';

  static const String baseUrl = _envBaseUrl != ''
      ? _envBaseUrl
      : (kReleaseMode ? _prodBaseUrl : _devBaseUrl);

  // ============================================================
  // API PREFIX
  //
  // Backend mounts all API routes under /api.
  // _buildUrl adds it automatically, so both:
  //   '/pitches'      -> /api/pitches
  //   '/api/pitches'  -> /api/pitches
  // work without producing /api/api/...
  // ============================================================

  static const String apiPrefix = '/api';

  // Paths served by the backend OUTSIDE /api (static files, health).
  static const List<String> _nonApiPrefixes = [
    '/uploads',
    '/health',
  ];

  // ============================================================
  // TIMEOUTS
  // ============================================================

  static const Duration _requestTimeout = Duration(seconds: 30);
  static const Duration _uploadTimeout = Duration(seconds: 90);

  // ============================================================
  // UNAUTHORIZED CALLBACK
  //
  // Optional. Set once in main.dart to send the user back to login
  // after the token is cleared on a 401 response.
  // ============================================================

  static void Function()? onUnauthorized;

  // ============================================================
  // MEDIA URL HELPER
  //
  // Turns a stored image path (/uploads/x.jpg) into a full URL.
  // Returns '' for null / empty / 'null'. Full http(s) URLs are
  // returned unchanged.
  // ============================================================

  static String resolveMediaUrl(String? path) {
    final value = path?.trim() ?? '';

    if (value.isEmpty || value == 'null') {
      return '';
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    return value.startsWith('/') ? '$baseUrl$value' : '$baseUrl/$value';
  }

  // ============================================================
  // DEBUG LOGGING (debug builds only)
  //
  // Never logs tokens, request bodies, or response bodies.
  // ============================================================

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  // ============================================================
  // HEADERS
  // ============================================================

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();

    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ============================================================
  // BUILD URL
  // ============================================================

  Uri _buildUrl(String endpoint) {
    var cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';

    final alreadyHasApiPrefix = cleanEndpoint == apiPrefix ||
        cleanEndpoint.startsWith('$apiPrefix/');

    final isNonApiPath = _nonApiPrefixes.any(
          (prefix) => cleanEndpoint.startsWith(prefix),
    );

    if (!alreadyHasApiPrefix && !isNonApiPath) {
      cleanEndpoint = '$apiPrefix$cleanEndpoint';
    }

    return Uri.parse('$baseUrl$cleanEndpoint');
  }

  // ============================================================
  // GET
  // ============================================================

  Future<dynamic> get(String endpoint) {
    return _request('GET', endpoint);
  }

  // ============================================================
  // POST
  // ============================================================

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) {
    return _request('POST', endpoint, body: body);
  }

  // ============================================================
  // PUT
  // ============================================================

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) {
    return _request('PUT', endpoint, body: body);
  }

  // ============================================================
  // PATCH
  // ============================================================

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) {
    return _request('PATCH', endpoint, body: body);
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<dynamic> delete(String endpoint) {
    return _request('DELETE', endpoint);
  }

  // ============================================================
  // SHARED REQUEST (GET / POST / PUT / PATCH / DELETE)
  // ============================================================

  Future<dynamic> _request(
      String method,
      String endpoint, {
        Map<String, dynamic>? body,
      }) async {
    final url = _buildUrl(endpoint);

    _log('🌐 $method: $url');

    try {
      final headers = await _headers();

      if (body != null) {
        headers['Content-Type'] = 'application/json';
      }

      final encodedBody = body != null ? jsonEncode(body) : null;

      final http.Response response;

      switch (method) {
        case 'GET':
          response = await http
              .get(url, headers: headers)
              .timeout(_requestTimeout);
          break;

        case 'POST':
          response = await http
              .post(url, headers: headers, body: encodedBody)
              .timeout(_requestTimeout);
          break;

        case 'PUT':
          response = await http
              .put(url, headers: headers, body: encodedBody)
              .timeout(_requestTimeout);
          break;

        case 'PATCH':
          response = await http
              .patch(url, headers: headers, body: encodedBody)
              .timeout(_requestTimeout);
          break;

        case 'DELETE':
          response = await http
              .delete(url, headers: headers)
              .timeout(_requestTimeout);
          break;

        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      _log('📡 $method STATUS: ${response.statusCode}');

      return await _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException {
      throw const ApiException(
        'The request took too long. Please try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Could not reach the server. Please try again.',
      );
    }
  }

  // ============================================================
  // UPLOAD FILES
  // ============================================================

  Future<dynamic> uploadFiles(
      String endpoint,
      List<File> files, {
        String fieldName = 'images',
      }) async {
    if (files.isEmpty) {
      throw const ApiException('No files selected for upload');
    }

    return _sendMultipart(
      endpoint: endpoint,
      fields: const {},
      files: files,
      fieldName: fieldName,
      fallbackToJpeg: true,
    );
  }

  // ============================================================
  // MULTIPART POST - FIELDS + FILES
  // ============================================================

  Future<dynamic> uploadMultipart({
    required String endpoint,
    required Map<String, String> fields,
    required List<File> files,
    String fieldName = 'images',
  }) async {
    if (files.isEmpty) {
      throw const ApiException('No files selected for upload');
    }

    return _sendMultipart(
      endpoint: endpoint,
      fields: fields,
      files: files,
      fieldName: fieldName,
      fallbackToJpeg: false,
    );
  }

  // ============================================================
  // UPLOAD BYTES (works on Android, iOS AND Flutter Web)
  //
  // Use this with XFile.readAsBytes() instead of dart:io File,
  // which is not supported on web ("Unsupported operation: _Namespace").
  // ============================================================

  Future<dynamic> uploadBytes(
      String endpoint, {
        required Uint8List bytes,
        required String filename,
        String fieldName = 'image',
        Map<String, String> fields = const {},
      }) async {
    if (bytes.isEmpty) {
      throw const ApiException('Selected file is empty');
    }

    final multipartFile = http.MultipartFile.fromBytes(
      fieldName,
      bytes,
      filename: filename,
      contentType: _mediaTypeFor(filename) ?? MediaType('image', 'jpeg'),
    );

    return _sendMultipartFiles(
      endpoint: endpoint,
      fields: fields,
      files: [multipartFile],
    );
  }

  // ============================================================
  // BUILD MULTIPART FILES FROM dart:io FILES (mobile only)
  // ============================================================

  Future<dynamic> _sendMultipart({
    required String endpoint,
    required Map<String, String> fields,
    required List<File> files,
    required String fieldName,
    required bool fallbackToJpeg,
  }) async {
    final multipartFiles = <http.MultipartFile>[];

    for (final file in files) {
      if (!await file.exists()) {
        throw const ApiException('Selected file could not be found');
      }

      var contentType = _mediaTypeFor(file.path);

      if (contentType == null && fallbackToJpeg) {
        contentType = MediaType('image', 'jpeg');
      }

      multipartFiles.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: contentType,
        ),
      );
    }

    return _sendMultipartFiles(
      endpoint: endpoint,
      fields: fields,
      files: multipartFiles,
    );
  }

  // ============================================================
  // SHARED MULTIPART SENDER
  // ============================================================

  Future<dynamic> _sendMultipartFiles({
    required String endpoint,
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
  }) async {
    final url = _buildUrl(endpoint);

    _log('🌐 MULTIPART POST: $url (${files.length} file(s))');

    try {
      final token = await TokenStorage.getToken();

      if (token == null || token.isEmpty) {
        throw const ApiException('Authentication token not found');
      }

      final request = http.MultipartRequest('POST', url);

      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $token';

      request.fields.addAll(fields);
      request.files.addAll(files);

      final streamedResponse = await request.send().timeout(_uploadTimeout);

      final response = await http.Response.fromStream(streamedResponse);

      _log('📡 MULTIPART STATUS: ${response.statusCode}');

      return await _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException {
      throw const ApiException(
        'The upload took too long. Please try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Could not reach the server. Please try again.',
      );
    }
  }

  // ============================================================
  // MIME TYPE BY EXTENSION
  // ============================================================

  MediaType? _mediaTypeFor(String path) {
    final dotIndex = path.lastIndexOf('.');

    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return null;
    }

    switch (path.substring(dotIndex + 1).toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');

      case 'png':
        return MediaType('image', 'png');

      case 'webp':
        return MediaType('image', 'webp');

      case 'pdf':
        return MediaType('application', 'pdf');

      default:
        return null;
    }
  }

  // ============================================================
  // RESPONSE HANDLER
  // ============================================================

  Future<dynamic> _handleResponse(http.Response response) async {
    dynamic data;

    try {
      data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } catch (_) {
      throw ApiException(
        'Unexpected server response. Please try again later.',
        statusCode: response.statusCode,
      );
    }

    // ==========================================================
    // SUCCESS
    // ==========================================================

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    // ==========================================================
    // EMAIL VERIFICATION REQUIRED
    // ==========================================================

    if (response.statusCode == 403 &&
        data is Map &&
        data['requiresVerification'] == true) {
      return data;
    }

    // ==========================================================
    // UNAUTHORIZED / EXPIRED TOKEN
    // ==========================================================

    if (response.statusCode == 401) {
      await TokenStorage.clearToken();

      onUnauthorized?.call();
    }

    // ==========================================================
    // ERROR MESSAGE
    // ==========================================================

    final message = data is Map ? data['message']?.toString() : null;

    throw ApiException(
      (message != null && message.trim().isNotEmpty)
          ? message
          : 'Request failed (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }
}