import 'package:flutter/material.dart';
import 'package:e7m/core/network/api_client.dart';
import 'package:e7m/core/services/token_storage.dart';

class AuthController extends ChangeNotifier {
  final ApiClient apiClient = ApiClient();

  // ============================================================
  // GENERAL STATE
  // ============================================================

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  String? _token;

  String? get token => _token;

  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  // ============================================================
  // VERIFICATION STATE
  // ============================================================

  bool _requiresVerification = false;

  bool get requiresVerification => _requiresVerification;

  String? _verificationEmail;

  String? get verificationEmail => _verificationEmail;

  int? _registrationId;

  int? get registrationId => _registrationId;

  bool _otpVerified = false;

  bool get otpVerified => _otpVerified;

  // ============================================================
  // USER INFO
  // ============================================================

  String? get role => _user?['role']?.toString();

  int? get userId {
    final id = _user?['id'];

    if (id is int) {
      return id;
    }

    return int.tryParse(id?.toString() ?? '');
  }

  // ============================================================
  // STATE HELPERS
  // ============================================================

  void _setLoading(bool value) {
    if (_isLoading == value) return;

    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearVerificationState() {
    _requiresVerification = false;
    _verificationEmail = null;
    _registrationId = null;
    _otpVerified = false;

    notifyListeners();
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  String? validateEmail(String email) {
    if (email.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    final emailRegex = RegExp(
      r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$',
    );

    if (!emailRegex.hasMatch(email.trim())) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }

    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (password.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    return null;
  }

  String? validateName(String name) {
    if (name.trim().isEmpty) {
      return 'الاسم مطلوب';
    }

    if (name.trim().length < 3) {
      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    }

    return null;
  }

  String? validatePhone(String phone) {
    if (phone.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    final cleanPhone = phone.trim().replaceAll(
      RegExp(r'[\s\-()]'),
      '',
    );

    if (cleanPhone.length < 8) {
      return 'رقم الهاتف غير صحيح';
    }

    return null;
  }

  String? validateCity(String city) {
    if (city.trim().isEmpty) {
      return 'المدينة مطلوبة';
    }

    return null;
  }

  String? validateConfirmPassword(
      String password,
      String confirmPassword,
      ) {
    if (confirmPassword.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }

    if (password != confirmPassword) {
      return 'كلمتا المرور غير متطابقتين';
    }

    return null;
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);

    if (emailError != null) {
      _setError(emailError);
      return false;
    }

    if (passwordError != null) {
      _setError(passwordError);
      return false;
    }

    _requiresVerification = false;
    _verificationEmail = null;

    _setError(null);
    _setLoading(true);

    try {
      final response = await apiClient.post(
        '/auth/login',
        {
          'email': email.trim(),
          'password': password,
        },
      );

      // ========================================================
      // EMAIL VERIFICATION REQUIRED
      // ========================================================

      if (response is Map &&
          response['requiresVerification'] == true) {
        _requiresVerification = true;

        _verificationEmail =
            response['email']?.toString() ?? email.trim();

        _errorMessage = null;

        notifyListeners();

        return false;
      }

      // ========================================================
      // LOGIN SUCCESS
      // ========================================================

      if (response is Map &&
          response['token'] != null &&
          response['user'] != null) {
        _token = response['token']?.toString();

        _user = Map<String, dynamic>.from(
          response['user'],
        );

        if (_token != null && _token!.isNotEmpty) {
          await TokenStorage.saveToken(_token!);
        }

        _requiresVerification = false;
        _verificationEmail = null;
        _errorMessage = null;

        notifyListeners();

        debugPrint('✅ LOGIN SUCCESS');
        debugPrint('👤 ROLE: $role');

        return true;
      }

      _setError(
        response is Map
            ? response['message']?.toString() ??
            'بيانات الدخول غير صحيحة'
            : 'بيانات الدخول غير صحيحة',
      );

      return false;
    } catch (e) {
      debugPrint('❌ LOGIN ERROR: $e');

      _setError(
        _extractErrorMessage(
          e,
          'فشل الاتصال بالخادم',
        ),
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // REGISTER
  //
  // IMPORTANT:
  // This method supports BOTH:
  //
  // Player -> role: 'player'
  // Owner  -> role: 'owner'
  //
  // The screen decides the role.
  // ============================================================

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String city,
    required String role,
    String verificationChannel = 'email',
  }) async {
    final nameError = validateName(name);
    final emailError = validateEmail(email);
    final phoneError = validatePhone(phone);
    final cityError = validateCity(city);

    if (nameError != null) {
      _setError(nameError);
      return false;
    }

    if (emailError != null) {
      _setError(emailError);
      return false;
    }

    if (phoneError != null) {
      _setError(phoneError);
      return false;
    }

    if (cityError != null) {
      _setError(cityError);
      return false;
    }

    // ==========================================================
    // VALIDATE ROLE
    // ==========================================================

    if (role != 'player' && role != 'owner') {
      _setError('نوع الحساب غير صحيح');
      return false;
    }

    _setError(null);
    _setLoading(true);

    try {
      // ========================================================
      // REGISTER REQUEST
      // ========================================================

      final response = await apiClient.post(
        '/auth/register',
        {
          'full_name': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(),

          // IMPORTANT:
          // Do NOT hardcode player here.
          // The screen sends the correct role.
          'role': role,

          'verification_channel': verificationChannel,
        },
      );

      // ========================================================
      // REGISTRATION STARTED
      // ========================================================

      if (response is Map &&
          response['success'] == true &&
          response['requiresVerification'] == true) {
        final registration = response['registration'];

        // ------------------------------------------------------
        // SAVE REGISTRATION ID
        // ------------------------------------------------------

        if (registration is Map &&
            registration['id'] != null) {
          _registrationId = int.tryParse(
            registration['id'].toString(),
          );
        }

        // ------------------------------------------------------
        // SAVE VERIFICATION DATA
        // ------------------------------------------------------

        _requiresVerification = true;

        _verificationEmail =
        registration is Map
            ? registration['email']?.toString() ??
            email.trim()
            : email.trim();

        _otpVerified = false;

        _errorMessage = null;

        notifyListeners();

        debugPrint('✅ REGISTRATION STARTED');
        debugPrint('👤 ROLE: $role');
        debugPrint('🆔 REGISTRATION ID: $_registrationId');
        debugPrint('📧 EMAIL: $_verificationEmail');

        return true;
      }

      // ========================================================
      // API RETURNED ERROR
      // ========================================================

      _setError(
        response is Map
            ? response['message']?.toString() ??
            'حدث خطأ أثناء إنشاء الحساب'
            : 'حدث خطأ أثناء إنشاء الحساب',
      );

      return false;
    } catch (e) {
      debugPrint('❌ REGISTER ERROR: $e');

      _setError(
        _extractErrorMessage(
          e,
          'حدث خطأ أثناء إنشاء الحساب',
        ),
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // SEND OTP
  // ============================================================

  Future<bool> sendOtp({
    required String email,
  }) async {
    final emailError = validateEmail(email);

    if (emailError != null) {
      _setError(emailError);
      return false;
    }

    _setError(null);
    _setLoading(true);

    try {
      final response = await apiClient.post(
        '/auth/send-otp',
        {
          'email': email.trim(),
        },
      );

      if (response is Map &&
          response['success'] == true) {
        debugPrint('✅ OTP SENT SUCCESSFULLY');

        return true;
      }

      _setError(
        response is Map
            ? response['message']?.toString() ??
            'فشل إرسال كود التحقق'
            : 'فشل إرسال كود التحقق',
      );

      return false;
    } catch (e) {
      debugPrint('❌ SEND OTP ERROR: $e');

      _setError(
        _extractErrorMessage(
          e,
          'فشل إرسال كود التحقق',
        ),
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    if (otp.trim().length != 6) {
      _setError(
        'الرجاء إدخال كود مكون من 6 أرقام',
      );

      return false;
    }

    _setError(null);
    _setLoading(true);

    try {
      final response = await apiClient.post(
        '/auth/verify-otp',
        {
          'email': email.trim(),
          'otp': otp.trim(),
        },
      );

      if (response is Map &&
          response['success'] == true) {
        final registration = response['registration'];

        if (registration is Map &&
            registration['id'] != null) {
          _registrationId = int.tryParse(
            registration['id'].toString(),
          );
        }

        _otpVerified = true;

        _requiresVerification = false;

        _verificationEmail = email.trim();

        // No JWT yet.
        // JWT is created after set-password.

        _token = null;
        _user = null;

        _errorMessage = null;

        notifyListeners();

        debugPrint('✅ OTP VERIFIED');
        debugPrint('🆔 REGISTRATION ID: $_registrationId');
        debugPrint('➡️ NEXT STEP: SET PASSWORD');

        return true;
      }

      _setError(
        response is Map
            ? response['message']?.toString() ??
            'كود التحقق غير صحيح'
            : 'كود التحقق غير صحيح',
      );

      return false;
    } catch (e) {
      debugPrint('❌ VERIFY OTP ERROR: $e');

      _setError(
        _extractErrorMessage(
          e,
          'كود التحقق غير صحيح أو منتهي',
        ),
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // RESEND OTP
  // ============================================================

  Future<bool> resendOtp({
    required String email,
  }) async {
    final emailError = validateEmail(email);

    if (emailError != null) {
      _setError(emailError);
      return false;
    }

    _setError(null);
    _setLoading(true);

    try {
      final response = await apiClient.post(
        '/auth/resend-otp',
        {
          'email': email.trim(),
        },
      );

      if (response is Map &&
          response['success'] == true) {
        debugPrint('✅ OTP RESENT');

        return true;
      }

      _setError(
        response is Map
            ? response['message']?.toString() ??
            'فشل إعادة إرسال كود التحقق'
            : 'فشل إعادة إرسال كود التحقق',
      );

      return false;
    } catch (e) {
      debugPrint('❌ RESEND OTP ERROR: $e');

      _setError(
        _extractErrorMessage(
          e,
          'فشل إعادة إرسال كود التحقق',
        ),
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // SET PASSWORD
  // ============================================================

  Future<bool> setPassword({
    required int registrationId,
    required String password,
    required String confirmPassword,
  }) async {
    final passwordError =
    validatePassword(password);

    final confirmError =
    validateConfirmPassword(
      password,
      confirmPassword,
    );

    if (passwordError != null) {
      _setError(passwordError);
      return false;
    }

    if (confirmError != null) {
      _setError(confirmError);
      return false;
    }

    _errorMessage = null;
    _isLoading = true;

    notifyListeners();

    var didSucceed = false;

    try {
      final response = await apiClient.post(
        '/auth/set-password',
        {
          'registration_id': registrationId,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      if (response is Map &&
          response['success'] == true &&
          response['token'] != null &&
          response['user'] != null) {
        _token = response['token'].toString();

        _user = Map<String, dynamic>.from(
          response['user'],
        );

        await TokenStorage.saveToken(
          _token!,
        );

        _registrationId = null;
        _otpVerified = false;
        _requiresVerification = false;
        _verificationEmail = null;
        _errorMessage = null;
        _isLoading = false;

        didSucceed = true;

        debugPrint('✅ ACCOUNT CREATED');
        debugPrint('🔐 TOKEN SAVED');
        debugPrint('👤 ROLE: $role');
      } else {
        _errorMessage = response is Map
            ? response['message']?.toString() ??
            'فشل إنشاء كلمة المرور'
            : 'فشل إنشاء كلمة المرور';

        _isLoading = false;
      }
    } catch (e) {
      debugPrint('❌ SET PASSWORD ERROR: $e');

      _errorMessage = _extractErrorMessage(
        e,
        'فشل إنشاء كلمة المرور',
      );

      _isLoading = false;
    }

    notifyListeners();

    return didSucceed;
  }

  // ============================================================
  // PHONE OTP
  // ============================================================

  Future<bool> sendPhoneOtp({
    required String phone,
  }) async {
    final phoneError = validatePhone(phone);

    if (phoneError != null) {
      _setError(phoneError);
      return false;
    }

    _setError(
      'التحقق عن طريق الهاتف غير متاح حاليًا',
    );

    return false;
  }

  Future<bool> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    _setError(
      'التحقق عن طريق الهاتف غير متاح حاليًا',
    );

    return false;
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<bool> forgotPassword({
    required String email,
  }) async {
    final emailError = validateEmail(email);

    if (emailError != null) {
      _setError(emailError);
      return false;
    }

    _setError(null);
    _setLoading(true);

    try {
      final response = await apiClient.post(
        '/auth/forgot-password',
        {
          'email': email.trim(),
        },
      );

      if (response is Map &&
          response['success'] == true) {
        return true;
      }

      _setError(
        response is Map
            ? response['message']?.toString() ??
            'فشل إرسال طلب استعادة كلمة المرور'
            : 'فشل إرسال طلب استعادة كلمة المرور',
      );

      return false;
    } catch (e) {
      _setError(
        _extractErrorMessage(
          e,
          'فشل إرسال طلب استعادة كلمة المرور',
        ),
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // VERIFY RESET OTP
  // ============================================================

  Future<bool> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    if (otp.trim().length != 6) {
      _setError(
        'الرجاء إدخال كود مكون من 6 أرقام',
      );

      return false;
    }

    _setError(null);
    _setLoading(true);

    try {
      final response = await apiClient.post(
        '/auth/verify-reset-otp',
        {
          'email': email.trim(),
          'otp': otp.trim(),
        },
      );

      if (response is Map &&
          response['success'] == true) {
        debugPrint('✅ RESET OTP VERIFIED');

        return true;
      }

      _setError(
        response is Map
            ? response['message']?.toString() ??
            'كود التحقق غير صحيح أو منتهي'
            : 'كود التحقق غير صحيح أو منتهي',
      );

      return false;
    } catch (e) {
      debugPrint('❌ VERIFY RESET OTP ERROR: $e');

      _setError(
        _extractErrorMessage(
          e,
          'كود التحقق غير صحيح أو منتهي',
        ),
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  Future<bool> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    final passwordError =
    validatePassword(password);

    final confirmError =
    validateConfirmPassword(
      password,
      confirmPassword,
    );

    if (passwordError != null) {
      _setError(passwordError);
      return false;
    }

    if (confirmError != null) {
      _setError(confirmError);
      return false;
    }

    _setError(null);
    _setLoading(true);

    try {
      final response = await apiClient.post(
        '/auth/reset-password',
        {
          'token': token,
          'new_password': password,
        },
      );

      if (response is Map &&
          response['success'] == true) {
        return true;
      }

      _setError(
        response is Map
            ? response['message']?.toString() ??
            'فشل تغيير كلمة المرور'
            : 'فشل تغيير كلمة المرور',
      );

      return false;
    } catch (e) {
      _setError(
        _extractErrorMessage(
          e,
          'فشل تغيير كلمة المرور',
        ),
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // RESET PASSWORD WITH OTP
  // ============================================================

  Future<bool> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    final passwordError =
    validatePassword(password);

    final confirmError =
    validateConfirmPassword(
      password,
      confirmPassword,
    );

    if (passwordError != null) {
      _setError(passwordError);
      return false;
    }

    if (confirmError != null) {
      _setError(confirmError);
      return false;
    }

    _errorMessage = null;
    _isLoading = true;

    notifyListeners();

    var didSucceed = false;

    try {
      final response = await apiClient.post(
        '/auth/reset-password',
        {
          'email': email.trim(),
          'otp': otp.trim(),
          'new_password': password,
        },
      );

      if (response is Map &&
          response['success'] == true) {
        didSucceed = true;

        debugPrint('✅ PASSWORD RESET SUCCESS');
      } else {
        _errorMessage = response is Map
            ? response['message']?.toString() ??
            'فشل تغيير كلمة المرور'
            : 'فشل تغيير كلمة المرور';
      }
    } catch (e) {
      debugPrint('❌ RESET PASSWORD ERROR: $e');

      _errorMessage = _extractErrorMessage(
        e,
        'فشل تغيير كلمة المرور',
      );
    }

    _isLoading = false;

    notifyListeners();

    return didSucceed;
  }

  // ============================================================
  // GET CURRENT USER
  // ============================================================

  Future<bool> getMe() async {
    if (_token == null || _token!.isEmpty) {
      return false;
    }

    _setLoading(true);

    try {
      final response =
      await apiClient.get('/auth/me');

      if (response is Map) {
        if (response['user'] is Map) {
          _user = Map<String, dynamic>.from(
            response['user'],
          );
        } else if (response['data'] is Map) {
          _user = Map<String, dynamic>.from(
            response['data'],
          );
        }

        notifyListeners();

        return true;
      }

      return false;
    } catch (e) {
      _setError(
        _extractErrorMessage(
          e,
          'فشل تحميل بيانات المستخدم',
        ),
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // LOAD SAVED TOKEN
  // ============================================================

  Future<bool> loadSavedToken() async {
    try {
      final savedToken =
      await TokenStorage.getToken();

      if (savedToken == null ||
          savedToken.isEmpty) {
        return false;
      }

      _token = savedToken;

      notifyListeners();

      return true;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    _token = null;
    _user = null;
    _errorMessage = null;

    _requiresVerification = false;
    _verificationEmail = null;
    _registrationId = null;
    _otpVerified = false;

    await TokenStorage.clearToken();

    notifyListeners();
  }

  // ============================================================
  // ERROR PARSER
  // ============================================================

  String _extractErrorMessage(
      Object error,
      String fallback,
      ) {
    final message = error.toString();

    if (message.contains('Invalid credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }

    if (message.contains('already exists') ||
        message.contains('Email already exists')) {
      return 'هذا البريد الإلكتروني مستخدم بالفعل';
    }

    if (message.contains('wait')) {
      return message.replaceFirst(
        'Exception: ',
        '',
      );
    }

    if (message.contains('expired')) {
      return 'كود التحقق منتهي الصلاحية';
    }

    if (message.contains(
      'Invalid verification code',
    )) {
      return 'كود التحقق غير صحيح';
    }

    if (message.contains('Passwords do not match')) {
      return 'كلمتا المرور غير متطابقتين';
    }

    if (message.contains('password')) {
      return 'حدث خطأ في كلمة المرور';
    }

    if (message.contains('email')) {
      return 'حدث خطأ متعلق بالبريد الإلكتروني';
    }

    if (message.contains('phone')) {
      return 'حدث خطأ متعلق برقم الهاتف';
    }

    return fallback;
  }
}