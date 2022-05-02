import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Auth extends ChangeNotifier {
  String? _token;
  DateTime? _expiryTime;
  String? _userId;
  Timer? _authTimer;

  final pref_key = 'userInfo';

  final apiKey = "AIzaSyABMVtdVdTDyYHTcQB-wKcB1AHX_FYWxNY";

  bool get isLoggedIn {
    return token != null;
  }

  String? get token {
    try {
      if (_expiryTime != null &&
          _expiryTime!.isAfter(DateTime.now()) &&
          _token != null) {
        return _token;
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(String email, String password, String url) async {
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final data = json.decode(response.body);

      if (data['error'] != null) {
        throw HttpException(data['error']['message']);
      }
      _token = data['idToken'];
      _userId = data['localId'];
      _expiryTime = DateTime.now().add(
        Duration(
          seconds: double.parse(data['expiresIn']).round(),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userInfo = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryTime': _expiryTime!.toIso8601String(),
        },
      );
      prefs.setString(pref_key, userInfo);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signup(String email, String password) async {
    final signupUrl =
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey";
    return _authenticate(email, password, signupUrl);
  }

  Future<void> signin(String email, String password) async {
    final signinUrl =
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey";
    return _authenticate(email, password, signinUrl);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(pref_key)) {
      return false;
    }
    final extractedUserInfo = json.decode(prefs.getString(pref_key)!);
    final expiryTime = DateTime.parse(extractedUserInfo['expiryTime']!);
    if (expiryTime.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserInfo['token'];
    _userId = extractedUserInfo['userId'];
    _expiryTime = expiryTime;

    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> signout() async {
    _token = null;
    _expiryTime = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryTime!.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: timeToExpiry), signout);
  }
}
