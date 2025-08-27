// pubspec.yaml dependencies (add these to your pubspec.yaml)

// auth_provider.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// Models
class User {
  final String username;
  final String role;

  User({required this.username, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(username: json['username'] ?? '', role: json['role'] ?? 'user');
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'role': role};
  }
}

class AuthResult {
  final bool success;
  final String? error;
  final User? user;

  AuthResult({required this.success, this.error, this.user});
}

// Custom exceptions
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message';
}

class NetworkException extends AuthException {
  NetworkException(super.message) : super(code: 'NETWORK_ERROR');
}

class ValidationException extends AuthException {
  ValidationException(super.message) : super(code: 'VALIDATION_ERROR');
}

// Security utilities
class SecurityUtils {
  // Generate secure random string for CSRF protection
  static String generateSecureToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }


  // Validate input against common injection patterns
  static bool isInputSafe(String input) {
    // Define potentially dangerous patterns
    final dangerousPatterns = [
      // RegExp(r'[<>"\']'),
      RegExp(
        r'\b(union|select|insert|update|delete|drop|create|alter)\b',
        caseSensitive: false,
      ), // SQL injection keywords
      RegExp(r'\.\./'), // Directory traversal
      RegExp(r'javascript:', caseSensitive: false), // JS injection
    ];

    // If any dangerous pattern matches, input is unsafe
    return !dangerousPatterns.any((pattern) => pattern.hasMatch(input));
  }
}

// Network client with security configurations
class SecureHttpClient {
  late final http.Client _client;
  final Duration _timeout;

  SecureHttpClient({Duration timeout = const Duration(seconds: 30)})
    : _timeout = timeout {
    _client = http.Client();
  }

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final secureHeaders = {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'User-Agent': 'SystemMonitorApp/1.0',
      // Add CSRF token if available
      ...?headers,
    };

    try {
      final response = await _client
          .post(url, headers: secureHeaders, body: body, encoding: encoding)
          .timeout(_timeout);

      dev.log('POST ${url.path} - Status: ${response.statusCode}');
      return response;
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HandshakeException {
      throw NetworkException('SSL/TLS handshake failed');
    } catch (e) {
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final secureHeaders = {
      'Accept': 'application/json',
      'User-Agent': 'SystemMonitorApp/1.0',
      ...?headers,
    };

    try {
      final response = await _client
          .get(url, headers: secureHeaders)
          .timeout(_timeout);
      dev.log('GET ${url.path} - Status: ${response.statusCode}');
      return response;
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HandshakeException {
      throw NetworkException('SSL/TLS handshake failed');
    } catch (e) {
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}

// Main Authentication Provider
class AuthProvider with ChangeNotifier {  
  // static final _logger = Logger('AuthProvider');

  // OWASP Mobile Security - Secure storage configuration
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm:
          KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'SystemMonitorApp',
    ),
  );

  // Storage keys
  static const _tokenKey = 'auth_token';
  // static const _refreshTokenKey = 'refresh_token';
  static const _userDataKey = 'user_data';
  static const _tokenExpiryKey = 'token_expiry';
  static const _lastActivityKey = 'last_activity';

  // State variables
  bool _isAuthenticated = false;
  bool _isLoading = false;
  User? _user;
  Timer? _tokenRefreshTimer;
  Timer? _inactivityTimer;
  final SecureHttpClient _httpClient;

  // Configuration
  String _baseUrl="";
  String get baseUrl => _baseUrl;
  set baseUrl(String url){
    _baseUrl= url;
    notifyListeners();
  }

  final Duration _sessionTimeout=const Duration(minutes: 30);
  final Duration _tokenRefreshBuffer =  const Duration(minutes: 5);

  AuthProvider() :_httpClient = SecureHttpClient() {
    initializeAuth();
  }

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  User? get user => _user;

  // Initialize authentication state
  Future<void> initializeAuth() async {
    try {
      _setLoading(true);

      // Check for existing valid session
      final token = await _getStoredToken();
      final userData = await _getStoredUserData();
      final lastActivity = await _getLastActivity();

      if (token != null && userData != null) {
        // Check if session is still valid
        if (_isSessionValid(lastActivity)) {
          _user = userData;
          _isAuthenticated = true;
          await _updateLastActivity();
          _startTokenRefreshTimer();
          _startInactivityTimer();
          dev.log('Session restored for user');
        } else {
          // Session expired, clear stored data
          await _clearStoredAuth();
          dev.log('Session expired, cleared stored authentication');
        }
      }
    } catch (e) {
      // _logger.severe('Error initializing auth: $e');
      await _clearStoredAuth();
    } finally {
      _setLoading(false);
    }
  }

  // Login method with input validation and security checks
  Future<AuthResult> login(String username, String password) async {
    try {
      // Input validation
      if (username.isEmpty || password.isEmpty) {
        throw ValidationException('Username and password are required');
      }

      if (username.length < 3 || username.length > 50) {
        throw ValidationException(
          'Username must be between 3 and 50 characters',
        );
      }

      if (password.length < 8 || password.length > 128) {
        throw ValidationException(
          'Password must be between 8 and 128 characters',
        );
      }

      // Security validation
      if (!SecurityUtils.isInputSafe(username)) {
        throw ValidationException('Username contains invalid characters');
      }

      _setLoading(true);

      final url = Uri.parse('$baseUrl/auth/login');
      final body = jsonEncode({
        'username': username.trim().toLowerCase(),
        'password': password,
      });

      dev.log('Attempting login for user');

      final response = await _httpClient.post(url, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Validate response structure
        if (!data.containsKey('token') || !data.containsKey('user')) {
          throw AuthException('Invalid server response format');
        }

        final token = data['token'] as String;
        final userData = User.fromJson(data['user']);
        final expiresIn =
            data['expiresIn'] as int? ?? 1800; // Default 30 minutes

        // Store authentication data securely
        await _storeAuthData(token, userData, expiresIn);

        _user = userData;
        _isAuthenticated = true;
        await _updateLastActivity();

        // Start timers
        _startTokenRefreshTimer();
        _startInactivityTimer();

        dev.log("Login successful for user");
        notifyListeners();
        return AuthResult(success: true, user: userData);
      } else if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        final error = data['error'] ?? 'Invalid credentials';
        // _logger.warning('Login failed: $error');
        return AuthResult(success: false, error: error);
      } else if (response.statusCode == 429) {
        throw AuthException('Too many login attempts. Please try again later.');
      } else {
        throw AuthException('Login failed with status: ${response.statusCode}');
      }
    } on ValidationException {
      rethrow;
    } on AuthException {
      rethrow;
    } catch (e) {
      // _logger.severe('Login error: $e');
      throw AuthException('Login failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Token refresh method
  Future<bool> refreshToken() async {
    try {
      final currentToken = await _getStoredToken();
      if (currentToken == null) {
        return false;
      }

      final url = Uri.parse('$baseUrl/auth/refresh');
      final response = await _httpClient.post(
        url,
        headers: {'Authorization': 'Bearer $currentToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['token'] as String;
        final expiresIn = data['expiresIn'] as int? ?? 1800;

        // Update stored token
        await _secureStorage.write(key: _tokenKey, value: newToken);
        await _storeTokenExpiry(expiresIn);
        await _updateLastActivity();

        _startTokenRefreshTimer();
        // _logger.info('Token refreshed successfully');
        return true;
      } else {
        // _logger.warning('Token refresh failed with status: ${response.statusCode}');
        await logout();
        return false;
      }
    } catch (e) {
      // _logger.severe('Token refresh error: $e');
      await logout();
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      _setLoading(true);

      // Cancel timers
      _tokenRefreshTimer?.cancel();
      _inactivityTimer?.cancel();

      // Clear stored data
      await _clearStoredAuth();

      // Reset state
      _isAuthenticated = false;
      _user = null;

      // _logger.info('User logged out successfully');

      notifyListeners();
    } catch (e) {
      // _logger.severe('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update activity for session management
  Future<void> updateActivity() async {
    if (_isAuthenticated) {
      await _updateLastActivity();
      _resetInactivityTimer();
    }
  }

  // Get stored token for API calls
  Future<String?> getAuthToken() async {
    if (!_isAuthenticated) return null;
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      dev.log('Error reading auth token: ',error: e);
      return null;
    }
  }

  // Private helper methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _storeAuthData(String token, User user, int expiresIn) async {
    try {
      await Future.wait([
        _secureStorage.write(key: _tokenKey, value: token),
        _secureStorage.write(
          key: _userDataKey,
          value: jsonEncode(user.toJson()),
        ),
        _storeTokenExpiry(expiresIn),
        _updateLastActivity(),
      ]);
    } catch (e) {
      // _logger.severe('Error storing auth data: $e');
      throw AuthException('Failed to store authentication data');
    }
  }

  Future<void> _storeTokenExpiry(int expiresIn) async {
    final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
    await _secureStorage.write(
      key: _tokenExpiryKey,
      value: expiryTime.millisecondsSinceEpoch.toString(),
    );
  }

  Future<String?> _getStoredToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      dev.log('Error reading stored token:',error: e);
      return null;
    }
  }

  Future<User?> _getStoredUserData() async {
    try {
      final userJson = await _secureStorage.read(key: _userDataKey);
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      dev.log('Error reading stored user data:',error: e);
      return null;
    }
  }

  Future<DateTime?> _getLastActivity() async {
    try {
      final activityStr = await _secureStorage.read(key: _lastActivityKey);
      if (activityStr != null) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(activityStr));
      }
      return null;
    } catch (e) {
      dev.log('Error reading last activity : ', error: e);
      return null;
    }
  }

  Future<void> _updateLastActivity() async {
    try {
      await _secureStorage.write(
        key: _lastActivityKey,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      // _logger.severe('Error updating last activity: $e');
    }
  }

  bool _isSessionValid(DateTime? lastActivity) {
    if (lastActivity == null) return false;

    final now = DateTime.now();
    final timeSinceActivity = now.difference(lastActivity);

    return timeSinceActivity < _sessionTimeout;
  }

  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();

    // Refresh token 5 minutes before expiry
    final refreshTime = Duration(seconds: 1800) - _tokenRefreshBuffer;

    _tokenRefreshTimer = Timer(refreshTime, () async {
      if (_isAuthenticated) {
        await refreshToken();
      }
    });
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();

    _inactivityTimer = Timer(_sessionTimeout, () async {
      if (_isAuthenticated) {
        dev.log('Session expired due to inactivity');
        await logout();
      }
    });
  }

  void _resetInactivityTimer() {
    if (_isAuthenticated) {
      _startInactivityTimer();
    }
  }

  Future<void> _clearStoredAuth() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _tokenKey),
        _secureStorage.delete(key: _userDataKey),
        _secureStorage.delete(key: _tokenExpiryKey),
        _secureStorage.delete(key: _lastActivityKey),
      ]);
    } catch (e) {
      dev.log('Error clearing stored auth: $e');
    }
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    _inactivityTimer?.cancel();
    _httpClient.dispose();
    super.dispose();
  }
}

// Usage example in main.dart:
/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';

void main() {
  // Configure logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            baseUrl: 'http://your-server-url:3000',
          ),
        ),
      ],
      child: MaterialApp(
        title: 'System Monitor',
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isLoading) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            return auth.isAuthenticated 
                ? DashboardScreen() 
                : LoginScreen();
          },
        ),
      ),
    );
  }
}
*/
