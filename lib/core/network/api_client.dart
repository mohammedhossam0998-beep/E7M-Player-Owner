import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:e7m/core/services/token_storage.dart';

class ApiClient {
  // ============================================================
  // BASE URL
  // ============================================================

  static const String baseUrl =
      'http://192.168.1.2:5000/api';

  // ============================================================
  // HEADERS
  // ============================================================

  Future<Map<String, String>> _headers() async {
    final token =
    await TokenStorage.getToken();

    if (token != null && token.isNotEmpty) {
      final preview = token.length > 20
          ? '${token.substring(0, 20)}...'
          : 'TOKEN_EXISTS';

      print(
        '🔐 TOKEN FROM STORAGE: $preview',
      );
    } else {
      print(
        '❌ TOKEN FROM STORAGE: NULL / EMPTY',
      );
    }

    final headers =
    <String, String>{
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] =
      'Bearer $token';

      print(
        '✅ Authorization Header Added',
      );
    } else {
      print(
        '⚠️ Authorization Header NOT Added',
      );
    }

    return headers;
  }

  // ============================================================
  // BUILD URL
  // ============================================================

  Uri _buildUrl(String endpoint) {
    final cleanEndpoint =
    endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';

    return Uri.parse(
      '$baseUrl$cleanEndpoint',
    );
  }

  // ============================================================
  // GET
  // ============================================================

  Future<dynamic> get(
      String endpoint,
      ) async {
    try {
      final url =
      _buildUrl(endpoint);

      print('🌐 GET: $url');

      final headers =
      await _headers();

      print(
        '📤 GET HEADERS: '
            '${_safeHeaders(headers)}',
      );

      final response =
      await http.get(
        url,
        headers: headers,
      );

      print(
        '📡 GET STATUS: '
            '${response.statusCode}',
      );

      print(
        '📦 GET BODY: '
            '${response.body}',
      );

      return _handleResponse(
        response,
      );
    } catch (e) {
      print(
        '❌ GET ERROR: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // POST
  // ============================================================

  Future<dynamic> post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    try {
      final url =
      _buildUrl(endpoint);

      print(
        '🌐 POST: $url',
      );

      print(
        '📤 POST BODY: '
            '${jsonEncode(body)}',
      );

      final headers =
      await _headers();

      print(
        '📤 POST HEADERS: '
            '${_safeHeaders(headers)}',
      );

      final response =
      await http.post(
        url,
        headers: {
          ...headers,
          'Content-Type':
          'application/json',
        },
        body: jsonEncode(body),
      );

      print(
        '📡 POST STATUS: '
            '${response.statusCode}',
      );

      print(
        '📦 POST BODY: '
            '${response.body}',
      );

      return _handleResponse(
        response,
      );
    } catch (e) {
      print(
        '❌ POST ERROR: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // PUT
  // ============================================================

  Future<dynamic> put(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    try {
      final url =
      _buildUrl(endpoint);

      print(
        '🌐 PUT: $url',
      );

      print(
        '📤 PUT BODY: '
            '${jsonEncode(body)}',
      );

      final headers =
      await _headers();

      print(
        '📤 PUT HEADERS: '
            '${_safeHeaders(headers)}',
      );

      final response =
      await http.put(
        url,
        headers: {
          ...headers,
          'Content-Type':
          'application/json',
        },
        body: jsonEncode(body),
      );

      print(
        '📡 PUT STATUS: '
            '${response.statusCode}',
      );

      print(
        '📦 PUT BODY: '
            '${response.body}',
      );

      return _handleResponse(
        response,
      );
    } catch (e) {
      print(
        '❌ PUT ERROR: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // PATCH
  // ============================================================

  Future<dynamic> patch(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    try {
      final url =
      _buildUrl(endpoint);

      print(
        '🌐 PATCH: $url',
      );

      print(
        '📤 PATCH BODY: '
            '${jsonEncode(body)}',
      );

      final headers =
      await _headers();

      print(
        '📤 PATCH HEADERS: '
            '${_safeHeaders(headers)}',
      );

      final response =
      await http.patch(
        url,
        headers: {
          ...headers,
          'Content-Type':
          'application/json',
        },
        body: jsonEncode(body),
      );

      print(
        '📡 PATCH STATUS: '
            '${response.statusCode}',
      );

      print(
        '📦 PATCH BODY: '
            '${response.body}',
      );

      return _handleResponse(
        response,
      );
    } catch (e) {
      print(
        '❌ PATCH ERROR: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<dynamic> delete(
      String endpoint,
      ) async {
    try {
      final url =
      _buildUrl(endpoint);

      print(
        '🌐 DELETE: $url',
      );

      final headers =
      await _headers();

      print(
        '📤 DELETE HEADERS: '
            '${_safeHeaders(headers)}',
      );

      final response =
      await http.delete(
        url,
        headers: headers,
      );

      print(
        '📡 DELETE STATUS: '
            '${response.statusCode}',
      );

      print(
        '📦 DELETE BODY: '
            '${response.body}',
      );

      return _handleResponse(
        response,
      );
    } catch (e) {
      print(
        '❌ DELETE ERROR: $e',
      );

      rethrow;
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
    try {
      if (files.isEmpty) {
        throw Exception(
          'No files selected for upload',
        );
      }

      final url =
      _buildUrl(endpoint);

      print(
        '🌐 MULTIPART POST: $url',
      );

      print(
        '📁 FILE COUNT: '
            '${files.length}',
      );

      print(
        '📁 FIELD NAME: '
            '$fieldName',
      );

      // ========================================================
      // GET TOKEN
      // ========================================================

      final token =
      await TokenStorage.getToken();

      if (token == null ||
          token.isEmpty) {
        print(
          '❌ UPLOAD TOKEN: '
              'NULL / EMPTY',
        );

        throw Exception(
          'Authentication token not found',
        );
      }

      print(
        '🔐 UPLOAD TOKEN: '
            '${token.length > 20 ? '${token.substring(0, 20)}...' : 'TOKEN_EXISTS'}',
      );

      // ========================================================
      // CREATE MULTIPART REQUEST
      // ========================================================

      final request =
      http.MultipartRequest(
        'POST',
        url,
      );

      // ========================================================
      // HEADERS
      // ========================================================

      request.headers['Accept'] =
      'application/json';

      request.headers['Authorization'] =
      'Bearer $token';

      print(
        '📤 MULTIPART HEADERS: '
            '${_safeHeaders(request.headers)}',
      );

      // ========================================================
      // ADD FILES
      // ========================================================

      for (final file in files) {
        if (!await file.exists()) {
          throw Exception(
            'File does not exist: '
                '${file.path}',
          );
        }

        print(
          '📎 ADDING FILE: '
              '${file.path}',
        );

        // ------------------------------------------------------
        // FORCE JPEG MIME TYPE
        // ------------------------------------------------------

        final multipartFile =
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType:
          MediaType(
            'image',
            'jpeg',
          ),
        );

        print(
          '🖼️ FILE MIME TYPE: '
              '${multipartFile.contentType}',
        );

        request.files.add(
          multipartFile,
        );
      }

      print(
        '📤 SENDING MULTIPART REQUEST...',
      );

      // ========================================================
      // SEND
      // ========================================================

      final streamedResponse =
      await request.send();

      final response =
      await http.Response.fromStream(
        streamedResponse,
      );

      // ========================================================
      // RESPONSE
      // ========================================================

      print(
        '📡 UPLOAD STATUS: '
            '${response.statusCode}',
      );

      print(
        '📦 UPLOAD BODY: '
            '${response.body}',
      );

      return _handleResponse(
        response,
      );
    } catch (e) {
      print(
        '❌ UPLOAD FILES ERROR: $e',
      );

      rethrow;
    }
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
    try {
      if (files.isEmpty) {
        throw Exception('No files selected for upload');
      }

      final url = _buildUrl(endpoint);

      print('🌐 MULTIPART POST: $url');
      print('📤 MULTIPART FIELDS: $fields');
      print('📁 MULTIPART FILE COUNT: ${files.length}');
      print('📁 MULTIPART FIELD NAME: $fieldName');

      final token = await TokenStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final request = http.MultipartRequest(
        'POST',
        url,
      );

      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $token';

      // ----------------------------------------------------------
      // FORM FIELDS
      // ----------------------------------------------------------

      request.fields.addAll(fields);

      // ----------------------------------------------------------
      // FILES
      // ----------------------------------------------------------

      for (final file in files) {
        if (!await file.exists()) {
          throw Exception(
            'File does not exist: ${file.path}',
          );
        }

        final extension = file.path.split('.').last.toLowerCase();

        MediaType? contentType;

        switch (extension) {
          case 'jpg':
          case 'jpeg':
            contentType = MediaType('image', 'jpeg');
            break;

          case 'png':
            contentType = MediaType('image', 'png');
            break;

          case 'webp':
            contentType = MediaType('image', 'webp');
            break;

          case 'pdf':
            contentType = MediaType('application', 'pdf');
            break;
        }

        final multipartFile =
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: contentType,
        );

        request.files.add(multipartFile);
      }

      print('📤 SENDING MULTIPART REQUEST...');

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      print(
        '📡 MULTIPART STATUS: ${response.statusCode}',
      );

      print(
        '📦 MULTIPART BODY: ${response.body}',
      );

      return _handleResponse(response);
    } catch (e) {
      print('❌ MULTIPART ERROR: $e');
      rethrow;
    }
  }

  // ============================================================
  // SAFE HEADERS FOR DEBUG
  // ============================================================

  Map<String, String> _safeHeaders(
      Map<String, String> headers,
      ) {
    final safeHeaders =
    Map<String, String>.from(
      headers,
    );

    final authorization =
    safeHeaders['Authorization'];

    if (authorization != null &&
        authorization.startsWith(
          'Bearer ',
        )) {
      final token =
      authorization.substring(7);

      if (token.length > 20) {
        safeHeaders['Authorization'] =
        'Bearer '
            '${token.substring(0, 20)}...';
      } else {
        safeHeaders['Authorization'] =
        'Bearer ***';
      }
    }

    return safeHeaders;
  }

  // ============================================================
  // RESPONSE HANDLER
  // ============================================================

  dynamic _handleResponse(
      http.Response response,
      ) {
    print(
      '🔎 Handling response...',
    );

    print(
      '➡️ Status Code: '
          '${response.statusCode}',
    );

    print(
      '➡️ Response Body: '
          '${response.body}',
    );

    dynamic data;

    try {
      data = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};
    } catch (e) {
      print(
        '❌ JSON DECODE ERROR: $e',
      );

      throw Exception(
        'Invalid server response: '
            '${response.statusCode}',
      );
    }

    // ==========================================================
    // SUCCESS
    // ==========================================================

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      print(
        '✅ API REQUEST SUCCESS',
      );

      return data;
    }

    // ==========================================================
    // EMAIL VERIFICATION REQUIRED
    // ==========================================================

    if (response.statusCode == 403 &&
        data is Map &&
        data['requiresVerification'] ==
            true) {
      print(
        '⚠️ EMAIL VERIFICATION REQUIRED',
      );

      return data;
    }

    // ==========================================================
    // ERROR MESSAGE
    // ==========================================================

    final message =
    data is Map
        ? data['message']?.toString()
        : null;

    print(
      '❌ API REQUEST FAILED',
    );

    print(
      '❌ Server Message: $message',
    );

    throw Exception(
      message ??
          'Request failed: '
              '${response.statusCode}',
    );
  }
}