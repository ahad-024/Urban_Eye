
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../storage/token_storage.dart';
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static Uri _uri(String endpoint) {
    return Uri.parse('${ApiConfig.baseUrl}$endpoint');
  }

  static Map<String, String> _jsonHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<String> _requireAccessToken() async {
    final token = await TokenStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      throw ApiException('You are not logged in.');
    }

    return token;
  }

  static Map<String, dynamic> _decodeResponse(
    http.Response response,
  ) {
    if (response.body.trim().isEmpty) return {};

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {'data': decoded};
    } catch (_) {
      return {'message': response.body};
    }
  }

  static String _extractErrorMessage(
    Map<String, dynamic> data,
  ) {
    for (final key in ['detail', 'message', 'error']) {
      if (data[key] != null) {
        return data[key].toString();
      }
    }

    final messages = <String>[];

    data.forEach((key, value) {
      if (value is List) {
        messages.add('$key: ${value.join(', ')}');
      } else if (value is Map) {
        messages.add('$key: ${value.values.join(', ')}');
      } else {
        messages.add('$key: $value');
      }
    });

    return messages.isNotEmpty
        ? messages.join('\n')
        : 'Something went wrong. Please try again.';
  }

  static void _checkSuccess(
    http.Response response,
    Map<String, dynamic> data,
  ) {
    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw ApiException(
        _extractErrorMessage(data),
        statusCode: response.statusCode,
      );
    }
  }

  static List<Map<String, dynamic>> _decodeList(
    http.Response response,
    String resourceName,
  ) {
    if (response.body.trim().isEmpty) return [];

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw ApiException(
        'The $resourceName API returned invalid JSON.',
        statusCode: response.statusCode,
      );
    }

    final dynamic items = decoded is List
        ? decoded
        : decoded is Map
            ? decoded['results'] ?? decoded['data']
            : null;

    if (items is! List) {
      throw ApiException(
        'Unexpected $resourceName response format.',
        statusCode: response.statusCode,
      );
    }

    return items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // LOGIN

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      _uri(ApiConfig.login),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = _decodeResponse(response);
    _checkSuccess(response, data);

    final access = data['access'];
    final refresh = data['refresh'];

    if (access == null || refresh == null) {
      throw ApiException(
        'Login succeeded but tokens were not returned.',
        statusCode: response.statusCode,
      );
    }

    await TokenStorage.saveTokens(
      accessToken: access.toString(),
      refreshToken: refresh.toString(),
    );

    return data;
  }

  // REGISTER

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      _uri(ApiConfig.register),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    final data = _decodeResponse(response);
    _checkSuccess(response, data);

    return data;
  }

  // GET PROFILE

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await _requireAccessToken();

    final response = await http.get(
      _uri(ApiConfig.profile),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _decodeResponse(response);
    _checkSuccess(response, data);

    return data;
  }

  // GET ALL REPORTS FOR LOGGED-IN USER

  static Future<List<Map<String, dynamic>>> getReports() async {
    final token = await _requireAccessToken();

    final response = await http.get(
      _uri('/api/reports/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkSuccess(response, _decodeResponse(response));

    return _decodeList(response, 'reports');
  }

  // GET ONE REPORT

  static Future<Map<String, dynamic>> getReport(
    Object reportId,
  ) async {
    final token = await _requireAccessToken();

    final response = await http.get(
      _uri('/api/reports/$reportId/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _decodeResponse(response);
    _checkSuccess(response, data);

    return data;
  }

  // CREATE REPORT WITH IMAGE.
  // This saves a report using supplied demo values.
  // It does not require YOLO in the current Django view.

  static Future<Map<String, dynamic>> createReport({
    required XFile image,
    required String issueType,
    required String severity,
    required int confidence,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    final token = await _requireAccessToken();

    final request = http.MultipartRequest(
      'POST',
      _uri('/api/reports/analyze-and-create/'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields.addAll({
      'issue_type': issueType
          .trim()
          .toLowerCase()
          .replaceAll(' ', '_'),
      'severity': severity.trim().toLowerCase(),
      'confidence': confidence.toString(),
      'description': description.trim(),
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    });

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        await image.readAsBytes(),
        filename: image.name.isNotEmpty
            ? image.name
            : 'urbaneye-report.jpg',
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(
      streamedResponse,
    );

    final data = _decodeResponse(response);
    _checkSuccess(response, data);

    if (data['id'] == null) {
      throw ApiException(
        'The report was submitted, but Django did not return a report ID.',
        statusCode: response.statusCode,
      );
    }

    return data;
  }

  // GET ALL COMPLAINTS FOR LOGGED-IN USER

  static Future<List<Map<String, dynamic>>> getComplaints() async {
    final token = await _requireAccessToken();

    final response = await http.get(
      _uri('/api/complaints/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    _checkSuccess(response, _decodeResponse(response));

    return _decodeList(response, 'complaints');
  }

  // GET ONE COMPLAINT

  static Future<Map<String, dynamic>> getComplaint(
    Object complaintId,
  ) async {
    final token = await _requireAccessToken();

    final response = await http.get(
      _uri('/api/complaints/$complaintId/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _decodeResponse(response);
    _checkSuccess(response, data);

    return data;
  }

  // CREATE COMPLAINT
  // Django requires report, title and description.

  static Future<Map<String, dynamic>> createComplaint({
    required Object reportId,
    required String title,
    required String description,
  }) async {
    final token = await _requireAccessToken();

    final response = await http.post(
      _uri('/api/complaints/'),
      headers: {
        ..._jsonHeaders(),
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'report': reportId,
        'title': title.trim(),
        'description': description.trim(),
      }),
    );

    final data = _decodeResponse(response);
    _checkSuccess(response, data);

    return data;
  }

  // UPDATE PROFILE

  static Future<Map<String, dynamic>> updateProfile({
    required String username,
    required String email,
  }) async {
    final token = await _requireAccessToken();

    final response = await http.patch(
      _uri(ApiConfig.profile),
      headers: {
        ..._jsonHeaders(),
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'username': username.trim(),
        'email': email.trim(),
      }),
    );

    final data = _decodeResponse(response);
    _checkSuccess(response, data);

    return data;
  }

  // REFRESH ACCESS TOKEN

  static Future<String> refreshAccessToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw ApiException('Refresh token not found.');
    }

    final response = await http.post(
      _uri(ApiConfig.refresh),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'refresh': refreshToken,
      }),
    );

    final data = _decodeResponse(response);
    _checkSuccess(response, data);

    final newAccessToken = data['access'];

    if (newAccessToken == null) {
      throw ApiException(
        'New access token was not returned.',
      );
    }

    await TokenStorage.saveTokens(
      accessToken: newAccessToken.toString(),
      refreshToken: data['refresh']?.toString() ??
          refreshToken,
    );

    return newAccessToken.toString();
  }

  // LOGOUT
  // Clears local tokens. Server-side blacklist is not called here.

  static Future<void> logout() async {
    await TokenStorage.clearTokens();
  }
}
