import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:diod/config/app_config.dart';
import 'package:diod/app/models/user.dart';

class Api {
  Api(AppConfig config) :
    apiBaseUrl = config.apiBaseUrl,
    clientId = config.clientId;

  final String apiBaseUrl;
  final String clientId;
  final JsonDecoder _decoder = JsonDecoder();
  final JsonEncoder _encoder = JsonEncoder();
  String _token;
  User _loggedUser;

  User loggedUser() {
    _loggedUser = _loggedUser ?? User.currentUser();
    return _loggedUser;
  }

  bool isLogged() {
    return loggedUser() != null;
  }

  Future<dynamic> get(String method) async {
    try {
      return parseResponse(await _get(method));
    } on AuthException {
      if (loggedUser() != null) {
        await relogin();
        return parseResponse(await _get(method));
      }
    }
  }

  Future<dynamic> post(String method, {body}) async {
    try {
      return parseResponse(await _post(method, body));
    } on AuthException {
      if (loggedUser() != null) {
        await relogin();
        return parseResponse(await _post(method, body));
      }
    }
  }

  Future<http.Response> _get(String method) async {
    return await http.get(
      this.apiBaseUrl + method,
      headers: {
        'Authorization': 'RApi client_id=$clientId,token=$_token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    );
  }

  Future<http.Response> _post(String method, body) async {
    return await http.post(
      this.apiBaseUrl + method,
      body: _encoder.convert(body),
      headers: {
        'Authorization': 'RApi client_id=$clientId,token=$_token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    );
  }

  Future<void> login(String username, String password) async {
    await _authenticate(username, password);
    _loggedUser = User.create({'username': username, 'password': password});
  }

  Future<void> logout() async {
    _loggedUser.delete();
    _loggedUser = null;
    _token = null;
  }

  Future<void> relogin() async {
    await _authenticate(loggedUser().username, loggedUser().password);
  }

  Future<void> _authenticate(String username, String password) async {
    http.Response response = await http.post(
      this.apiBaseUrl + 'v1/authenticate',
      headers: {
        'Authorization': 'RApi client_id=$clientId,login=$username,password=$password'
      }
    );

    _token = parseResponse(response)['token'];
  }

  dynamic parseResponse(http.Response response) {
      final int statusCode = response.statusCode;
      final String body = response.body;
      dynamic parsedResp;

      if (statusCode < 200) {
        throw new ApiException('Ошибка при получении данных', statusCode);
      } else {
        parsedResp = _decoder.convert(body);
      }

      if (statusCode == 401) {
        throw new AuthException(parsedResp['error']);
      }
      if (statusCode >= 400) {
        throw new ApiException(parsedResp['error'], statusCode);
      }

      return _decoder.convert(body);
  }
}

class ApiException implements Exception {
  String errorMsg;
  int statusCode;

  ApiException(this.errorMsg, this.statusCode);
}

class AuthException extends ApiException {
  AuthException(errorMsg) : super(errorMsg, 401);
}
