import 'dart:async';

/// Stub simples de autenticação para simular a API.
/// Trocar por integração real depois.
class AuthService {
  static final AuthService I = AuthService._();
  AuthService._();

  String? _token;
  String? get token => _token;
  bool get isLogged => _token != null;

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final ok = email.contains('@') && password.length >= 4;
    if (ok) _token = 'fake-token-${DateTime.now().millisecondsSinceEpoch}';
    return ok;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return name.trim().isNotEmpty && email.contains('@') && password.length >= 6;
  }

  void logout() => _token = null;
}
