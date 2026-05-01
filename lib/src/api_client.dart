import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

class ApiClient {
  static String baseUrl = const String.fromEnvironment(
    'LOCAL_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3001',
  );

  static String? _token;
  static String? get token => _token;
  static bool get isLoggedIn => _token != null;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> _setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    final http.Response res;
    switch (method) {
      case 'GET':
        res = await http.get(uri, headers: _headers);
        break;
      case 'POST':
        res = await http.post(uri, headers: _headers, body: jsonEncode(body));
        break;
      case 'PUT':
        res = await http.put(uri, headers: _headers, body: jsonEncode(body));
        break;
      case 'PATCH':
        res = await http.patch(uri, headers: _headers, body: jsonEncode(body));
        break;
      case 'DELETE':
        res = await http.delete(uri, headers: _headers);
        break;
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }

    if (res.statusCode == 401) {
      await clearToken();
      throw const ApiException(401, '登录已过期，请重新登录');
    }

    if (res.statusCode >= 400) {
      String msg = '请求失败';
      try {
        final data = jsonDecode(res.body);
        if (data is Map && data['error'] != null) {
          msg = data['error'].toString();
        }
      } catch (_) {}
      throw ApiException(res.statusCode, msg);
    }

    try {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<bool> healthCheck() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/health'));
      if (res.statusCode != 200) return false;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> sendSms(String phone, {String purpose = 'register'}) {
    return _request('POST', '/api/v1/auth/sms/send', body: {
      'phoneNumber': phone,
      'purpose': purpose,
    });
  }

  static Future<Map<String, dynamic>> login(String phone, String password) async {
    final data = await _request('POST', '/api/v1/auth/login', body: {
      'phoneNumber': phone,
      'password': password,
    });
    if (data['token'] != null) {
      await _setToken(data['token'] as String);
    }
    return data;
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String smsCode,
    required String password,
  }) async {
    final data = await _request('POST', '/api/v1/auth/register', body: {
      'name': name,
      'phoneNumber': phone,
      'smsCode': smsCode,
      'password': password,
    });
    if (data['token'] != null) {
      await _setToken(data['token'] as String);
    }
    return data;
  }

  static Future<Map<String, dynamic>> getMe() {
    return _request('GET', '/api/v1/auth/me');
  }

  static Future<Map<String, dynamic>> getBanner() {
    return _request('GET', '/api/v1/square/banner');
  }

  static Future<Map<String, dynamic>> getNotices() {
    return _request('GET', '/api/v1/square/notices');
  }

  static Future<Map<String, dynamic>> getSquareUsers({
    int page = 1,
    int pageSize = 20,
    String? gender,
    String? region,
    bool? onlineOnly,
    bool? verifiedOnly,
    String? search,
  }) {
    final params = <String, String>{
      'page': '$page',
      'pageSize': '$pageSize',
    };
    if (gender != null) params['gender'] = gender;
    if (region != null) params['region'] = region;
    if (onlineOnly == true) params['onlineOnly'] = 'true';
    if (verifiedOnly == true) params['verifiedOnly'] = 'true';
    if (search != null) params['search'] = search;
    return _request('GET', '/api/v1/square/users', queryParameters: params);
  }

  static Future<Map<String, dynamic>> saveFilters(Map<String, dynamic> filter) {
    return _request('POST', '/api/v1/square/filters', body: filter);
  }

  static Future<Map<String, dynamic>> getFilters() {
    return _request('GET', '/api/v1/square/filters');
  }

  static Future<Map<String, dynamic>> getCirclePosts({int page = 1, int pageSize = 20}) {
    return _request('GET', '/api/v1/circle/posts', queryParameters: {
      'page': '$page',
      'pageSize': '$pageSize',
    });
  }

  static Future<Map<String, dynamic>> getCirclePostDetail(String postId) {
    return _request('GET', '/api/v1/circle/posts/$postId');
  }

  static Future<Map<String, dynamic>> createCirclePost(Map<String, dynamic> body) {
    return _request('POST', '/api/v1/circle/posts', body: body);
  }

  static Future<Map<String, dynamic>> updateCirclePost(String postId, Map<String, dynamic> body) {
    return _request('PUT', '/api/v1/circle/posts/$postId', body: body);
  }

  static Future<Map<String, dynamic>> deleteCirclePost(String postId) {
    return _request('DELETE', '/api/v1/circle/posts/$postId');
  }

  static Future<Map<String, dynamic>> likeCirclePost(String postId) {
    return _request('POST', '/api/v1/circle/posts/$postId/like');
  }

  static Future<Map<String, dynamic>> unlikeCirclePost(String postId) {
    return _request('POST', '/api/v1/circle/posts/$postId/unlike');
  }

  static Future<Map<String, dynamic>> commentCirclePost(String postId, String content, {String? parentCommentId}) {
    return _request('POST', '/api/v1/circle/posts/$postId/comments', body: {
      'content': content,
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
    });
  }

  static Future<Map<String, dynamic>> reportCirclePost(String postId, String reason) {
    return _request('POST', '/api/v1/circle/posts/$postId/reports', body: {
      'reason': reason,
    });
  }

  static Future<Map<String, dynamic>> getProfileComplete() {
    return _request('GET', '/api/v1/users/me/complete');
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profile) {
    return _request('PUT', '/api/v1/users/me/profile', body: profile);
  }

  static Future<Map<String, dynamic>> getUser(String userId) {
    return _request('GET', '/api/v1/users/$userId');
  }

  static Future<Map<String, dynamic>> getSettings() {
    return _request('GET', '/api/v1/users/me/settings');
  }

  static Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> settings) {
    return _request('PUT', '/api/v1/users/me/settings', body: settings);
  }

  static Future<Map<String, dynamic>> getChatPrivacy() {
    return _request('GET', '/api/v1/chat/privacy');
  }

  static Future<Map<String, dynamic>> updateChatPrivacy(Map<String, dynamic> privacy) {
    return _request('PUT', '/api/v1/chat/privacy', body: privacy);
  }

  static Future<Map<String, dynamic>> getConversations() {
    return _request('GET', '/api/v1/chat/conversations');
  }

  static Future<Map<String, dynamic>> createConversation(Map<String, dynamic> body) {
    return _request('POST', '/api/v1/chat/conversations', body: body);
  }

  static Future<Map<String, dynamic>> getMessages(String conversationId, {int page = 1, int pageSize = 20}) {
    return _request('GET', '/api/v1/chat/messages/$conversationId', queryParameters: {
      'page': '$page',
      'pageSize': '$pageSize',
    });
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String text,
    String type = 'text',
  }) {
    return _request('POST', '/api/v1/chat/messages', body: {
      'conversationId': conversationId,
      'text': text,
      'type': type,
    });
  }

  static Future<Map<String, dynamic>> pinConversation(String conversationId) {
    return _request('PATCH', '/api/v1/chat/conversations/$conversationId/pin');
  }

  static Future<Map<String, dynamic>> readConversation(String conversationId) {
    return _request('POST', '/api/v1/chat/conversations/$conversationId/read');
  }

  static Future<Map<String, dynamic>> readAllConversations() {
    return _request('POST', '/api/v1/chat/conversations/read-all');
  }

  static Future<Map<String, dynamic>> deleteConversation(String conversationId) {
    return _request('DELETE', '/api/v1/chat/conversations/$conversationId');
  }

  static Future<Map<String, dynamic>> getNotifications({int page = 1, int pageSize = 20}) {
    return _request('GET', '/api/v1/notifications', queryParameters: {
      'page': '$page',
      'pageSize': '$pageSize',
    });
  }

  static Future<Map<String, dynamic>> markNotificationRead(String id) {
    return _request('PUT', '/api/v1/notifications/$id/read');
  }

  static Future<Map<String, dynamic>> markAllNotificationsRead() {
    return _request('PUT', '/api/v1/notifications/read-all');
  }

  static Future<Map<String, dynamic>> searchUsers(String query, {int page = 1, int pageSize = 20}) {
    return _request('GET', '/api/v1/search/users', queryParameters: {
      'q': query,
      'page': '$page',
      'pageSize': '$pageSize',
    });
  }

  static Future<Map<String, dynamic>> getReviewSummary() {
    return _request('GET', '/api/v1/reviews/summary');
  }

  static Future<Map<String, dynamic>> submitIdentityReview(String legalName, String idNumber) {
    return _request('POST', '/api/v1/reviews/identity', body: {
      'legalName': legalName,
      'idNumber': idNumber,
    });
  }

  static Future<Map<String, dynamic>> submitFaceReview() {
    return _request('POST', '/api/v1/reviews/face');
  }

  static Future<Map<String, dynamic>> uploadFile(String field, String filePath) async {
    final uri = Uri.parse('$baseUrl/api/v1/upload/single');
    final request = http.MultipartRequest('POST', uri);
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    request.files.add(await http.MultipartFile.fromPath(field, filePath));
    final streamRes = await request.send();
    final res = await http.Response.fromStream(streamRes);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> cancelAccount() {
    return _request('POST', '/api/v1/users/me/cancel');
  }

  static Future<Map<String, dynamic>> getDevices() {
    return _request('GET', '/api/v1/users/me/devices');
  }

  static Future<Map<String, dynamic>> revokeDevice(String deviceId) {
    return _request('POST', '/api/v1/users/me/devices/$deviceId/revoke');
  }

  static Future<Map<String, dynamic>> getBlacklist() {
    return _request('GET', '/api/v1/users/me/blacklist');
  }

  static Future<Map<String, dynamic>> addToBlacklist(String targetUserId) {
    return _request('POST', '/api/v1/users/me/blacklist', body: {
      'targetUserId': targetUserId,
    });
  }

  static Future<Map<String, dynamic>> removeFromBlacklist(String targetUserId) {
    return _request('DELETE', '/api/v1/users/me/blacklist/$targetUserId');
  }

  static Future<Map<String, dynamic>> requestPasswordReset(String phone) {
    return _request('POST', '/api/v1/auth/password-reset/request', body: {
      'phoneNumber': phone,
    });
  }

  static Future<Map<String, dynamic>> confirmPasswordReset({
    required String phone,
    required String smsCode,
    required String newPassword,
  }) {
    return _request('POST', '/api/v1/auth/password-reset/confirm', body: {
      'phoneNumber': phone,
      'code': smsCode,
      'newPassword': newPassword,
    });
  }
}
