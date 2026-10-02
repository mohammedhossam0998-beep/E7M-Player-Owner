import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/features/auth/presentation/controllers/auth_controller.dart';
import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/features/auth/presentation/screens/success/success_screen.dart';
import 'package:e7m/features/auth/presentation/screens/approval/pending_approval_screen.dart';

class SetPasswordScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String city;

  // ✨ مضافة: تحدد نوجه بعد النجاح فين
  // false (default) => Player => SuccessScreen
  // true             => Owner  => PendingApprovalScreen
  final bool isOwner;

  const SetPasswordScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
    this.isOwner = false,
  });

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> _register() async {
    final password = passwordController.text.trim();
    final confirmPassword =
    confirmPasswordController.text.trim();
    final auth = context.read<AuthController>();

    // ============================================================
    // VALIDATION
    // ============================================================
    final passwordError =
    auth.validatePassword(password);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(passwordError),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmError =
    auth.validateConfirmPassword(
      password,
      confirmPassword,
    );
    if (confirmError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(confirmError),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (isLoading) return;

    // ============================================================
    // CHECK OTP / REGISTRATION
    // ============================================================
    final registrationToken = auth.registrationToken;

    if (registrationToken == null || registrationToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registration session expired. Please verify your email again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!auth.otpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please verify your email before setting the password.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // ============================================================
    // SET PASSWORD
    // ============================================================
    setState(() {
      isLoading = true;
    });

    final success = await auth.setPassword(
      registrationToken: registrationToken,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (!mounted) return;

    // ============================================================
    // ERROR
    // ============================================================
    if (!success) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.errorMessage ??
                'فشل إنشاء الحساب',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // ============================================================
    // SUCCESS
    //
    // ملحوظة: هنا مش بنعمل setState(isLoading = false) لأن الشاشة
    // دي رايحة تتشال (navigate away) على طول، وأي setState زيادة
    // هنا كان هو سبب كراش "_dependents.isEmpty is not true".
    //
    // كمان بنأجل الـ Navigation بـ addPostFrameCallback عشان
    // نضمن إن الفريم الحالي (اللي فيه notifyListeners بتاع
    // AuthController.setPassword) يخلص تمامًا الأول.
    //
    // ✨ إضافة: دلوقتي بنفرق الوجهة حسب isOwner
    // ============================================================

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم إنشاء الحساب بنجاح',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => widget.isOwner
              ? const PendingApprovalScreen()
              : const SuccessScreen(),
        ),
            (route) => false,
      );
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    final isRtl =
        Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),

      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          onPressed: isLoading
              ? null
              : () {
            Navigator.pop(context);
          },
          icon: Icon(
            isRtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
            size: 20,
            color: const Color(0xff1E1446),
          ),
        ),

        title: Text(
          t('set_password'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 25),

              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: Color(0xffEEF5E5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 55,
                  color: Color(0xff7CC000),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                t('create_password'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1E1446),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 35),

              Align(
                alignment: isRtl
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  t('password'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1E1446),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.next,

                decoration: InputDecoration(
                  hintText: t('password'),

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xff7CC000),
                  ),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                        !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xff7CC000),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Align(
                alignment: isRtl
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  t('confirm_password'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1E1446),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                textInputAction: TextInputAction.done,

                onSubmitted: (_) {
                  if (!isLoading) {
                    _register();
                  }
                },

                decoration: InputDecoration(
                  hintText: t('confirm_password'),

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xff7CC000),
                  ),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword =
                        !obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xff7CC000),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Align(
                alignment: isRtl
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton(
                  onPressed:
                  isLoading ? null : _register,

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xff7CC000),

                    disabledBackgroundColor:
                    const Color(0xffB8D98A),

                    elevation: 0,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),

                  child: isLoading
                      ? const SizedBox(
                    width: 25,
                    height: 25,
                    child:
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    t('create_account'),
                    style:
                    const TextStyle(
                      fontSize: 20,
                      fontWeight:
                      FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}