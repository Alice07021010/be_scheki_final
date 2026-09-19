import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/page_result.dart';

class ApiException implements Exception {
  final int status;
  final String message;
  final Map<String, dynamic> data;

  const ApiException(this.status, this.message, [this.data = const {}]);

  @override
  String toString() => message;
}

class ApiClient {
  final String baseUrl;
  String? token;

  ApiClient(this.baseUrl);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null && token!.isNotEmpty) 'Authorization': token!,
      };

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: query);
  }

  Future<Map<String, dynamic>> login(String identity, String password) async {
    final response = await http.post(
      _uri('/api/collections/users/auth-with-password'),
      headers: _headers,
      body: jsonEncode({'identity': identity, 'password': password}),
    );
    return _map(response);
  }

  Future<Map<String, dynamic>> refresh() async {
    final response = await http.post(
      _uri('/api/collections/users/auth-refresh'),
      headers: _headers,
    );
    return _map(response);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      _uri('/api/collections/users/records'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'emailVisibility': true,
        'password': password,
        'passwordConfirm': password,
        'role': 'buyer',
      }),
    );
    return _map(response);
  }

  Future<PageResult> list(
    String collection, {
    int page = 1,
    int perPage = 10,
    String? filter,
    String? sort,
    String? expand,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'perPage': '$perPage',
      if (filter != null && filter.isNotEmpty) 'filter': filter,
      if (sort != null && sort.isNotEmpty) 'sort': sort,
      if (expand != null && expand.isNotEmpty) 'expand': expand,
    };
    final response = await http.get(
      _uri('/api/collections/$collection/records', query),
      headers: _headers,
    );
    return PageResult.fromJson(_map(response));
  }

  Future<Map<String, dynamic>> getOne(String collection, String id, {String? expand}) async {
    final response = await http.get(
      _uri(
        '/api/collections/$collection/records/$id',
        expand == null ? null : {'expand': expand},
      ),
      headers: _headers,
    );
    return _map(response);
  }

  Future<Map<String, dynamic>> create(String collection, Map<String, dynamic> data) async {
    final response = await http.post(
      _uri('/api/collections/$collection/records'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _map(response);
  }

  Future<Map<String, dynamic>> update(String collection, String id, Map<String, dynamic> data) async {
    final response = await http.patch(
      _uri('/api/collections/$collection/records/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _map(response);
  }

  Future<void> delete(String collection, String id) async {
    final response = await http.delete(
      _uri('/api/collections/$collection/records/$id'),
      headers: _headers,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _map(response);
    }
  }

  Map<String, dynamic> _map(http.Response response) {
    Map<String, dynamic> body = {};
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) body = Map<String, dynamic>.from(decoded);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body['message']?.toString() ?? 'Ошибка сервера';
      final data = body['data'] is Map ? Map<String, dynamic>.from(body['data'] as Map) : <String, dynamic>{};
      throw ApiException(response.statusCode, message, data);
    }
    return body;
  }
}
