import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AppState extends ChangeNotifier {
  final String baseUrl = 'https://your-api-domain.com/api'; // UPDATE THIS LATER
  final String wsUrl = 'wss://your-api-domain.com/ws';

  String? token;
  Map<String, dynamic>? user;
  int unreadMessages = 0;
  
  WebSocketChannel? liveWs;
  WebSocketChannel? msgWs;

  AppState() {
    _loadAuth();
  }

  Future<void> _loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('ashes_token');
    final userStr = prefs.getString('ashes_user');
    if (userStr != null) {
      user = jsonDecode(userStr);
    }
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final res = await api('POST', '/auth/login', {'username': username, 'password': password});
    if (res != null) {
      token = res['token'];
      user = {
        'user_id': res['user_id'],
        'username': res['username'],
        'role': res['role'],
        'team_id': res['team_id'],
      };
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ashes_token', token!);
      await prefs.setString('ashes_user', jsonEncode(user));
      notifyListeners();
    }
  }

  Future<void> logout() async {
    token = null;
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ashes_token');
    await prefs.remove('ashes_user');
    notifyListeners();
  }

  Future<dynamic> api(String method, String path, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    try {
      http.Response response;
      if (method == 'POST') {
        response = await http.post(uri, headers: headers, body: jsonEncode(body));
      } else if (method == 'PUT') {
        response = await http.put(uri, headers: headers, body: jsonEncode(body));
      } else if (method == 'PATCH') {
        response = await http.patch(uri, headers: headers, body: jsonEncode(body));
      } else {
        response = await http.get(uri, headers: headers);
      }

      if (response.statusCode == 401) {
        await logout();
        return null;
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        print('API Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error: $e');
      return null;
    }
  }

  bool hasRole(List<String> roles) {
    if (user == null) return false;
    return roles.contains(user!['role']);
  }
}
