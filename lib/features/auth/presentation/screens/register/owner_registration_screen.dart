import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/features/auth/presentation/controllers/auth_controller.dart';
import '../verification/owner_otp_screen.dart';

class OwnerRegistrationScreen extends StatefulWidget {
  const OwnerRegistrationScreen({super.key});

  @override
  State<OwnerRegistrationScreen> createState() =>
      _OwnerRegistrationScreenState();
}

class _OwnerRegistrationScreenState
    extends State<OwnerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String? selectedCity;

  final List<String> cities = [
    'Alexandria',
    'Cairo',
    'Giza',
    'Mansoura',
    'Tanta',
    'Zagazig',
    'Port Said',
    'Ismailia',
  ];

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xff7CC000),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }

  // ============================================================
  // OWNER REGISTER
  // ============================================================

  Future<void> _registerOwner(
      AuthController authController,
      ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final city = selectedCity!.trim();

    // ==========================================================
    // REGISTER OWNER
    // ==========================================================

    final success = await authController.register(
      name: fullName,
      email: email,
      phone: phone,
      city: city,

      // IMPORTANT:
      // This registration belongs to an Owner.
      role: 'owner',

      // Owner will verify through email OTP.
      verificationChannel: 'email',
    );

    if (!mounted) {
      return;
    }

    // ==========================================================
    // REGISTER FAILED
    // ==========================================================

    if (!success) {
      final message =
          authController.errorMessage ??
              'Registration failed. Please try again.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ==========================================================
    // REGISTRATION SUCCESS
    // ==========================================================

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: authController,
          child: OwnerOtpScreen(
            fullName: fullName,
            email: email,
            phone: phone,
            city: city,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final authController =
    context.watch<AuthController>();

    final isLoading =
        authController.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),

                Image.asset(
                  'assets/images/logo.png',
                  width: 90,
                ),

                const SizedBox(height: 25),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff7CC000)
                        .withValues(alpha: .1),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Step 1 of 5',
                    style: TextStyle(
                      color: Color(0xff7CC000),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Register as Stadium Owner',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1E1446),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Create your owner account to start managing your stadium bookings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 35),

                TextFormField(
                  controller:
                  fullNameController,
                  textInputAction:
                  TextInputAction.next,
                  decoration: inputDecoration(
                    hint: 'Full Name',
                    icon:
                    Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().length < 3) {
                      return 'Enter valid full name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller:
                  emailController,
                  keyboardType:
                  TextInputType.emailAddress,
                  textInputAction:
                  TextInputAction.next,
                  decoration: inputDecoration(
                    hint: 'Email Address',
                    icon:
                    Icons.email_outlined,
                  ),
                  validator: (value) {
                    final email =
                        value?.trim() ?? '';

                    if (email.isEmpty ||
                        !email.contains('@') ||
                        !email.contains('.')) {
                      return 'Enter valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller:
                  phoneController,
                  keyboardType:
                  TextInputType.phone,
                  textInputAction:
                  TextInputAction.next,
                  decoration: inputDecoration(
                    hint: 'Phone Number',
                    icon:
                    Icons.phone_outlined,
                  ),
                  validator: (value) {
                    final phone =
                        value?.trim() ?? '';

                    if (phone.length < 11) {
                      return 'Enter valid phone';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                DropdownButtonFormField<String>(
                  value: selectedCity,

                  decoration:
                  inputDecoration(
                    hint: 'Select City',
                    icon: Icons
                        .location_city_outlined,
                  ),

                  items: cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),

                  onChanged: isLoading
                      ? null
                      : (value) {
                    setState(() {
                      selectedCity =
                          value;
                    });
                  },

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Please select city';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 56,

                  child: ElevatedButton(
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xff7CC000),
                      disabledBackgroundColor:
                      Colors.grey.shade400,
                      elevation: 0,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),

                    onPressed: isLoading
                        ? null
                        : () {
                      _registerOwner(
                        authController,
                      );
                    },

                    child: isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color:
                        Colors.white,
                      ),
                    )
                        : const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}