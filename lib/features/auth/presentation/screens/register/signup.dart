import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/features/auth/presentation/screens/verification/verification_method_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String? selectedCity;

  // المدن المستخدمة في التسجيل
  // نخزن الـ key وليس النص المترجم
  final List<String> citiesKeys = const [
    'cairo',
    'alexandria',
    'giza',
    'mansoura',
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final fullName = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final phone = phoneController.text.trim();
    final city = selectedCity!;

    FocusScope.of(context).unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationMethodScreen(
          fullName: fullName,
          email: email,
          phone: phone,
          city: city,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    final isRtl =
        Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // =========================================================
          // TOP GREEN SHAPE
          // =========================================================

          Positioned(
            top: -120,
            right: -120,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: const Color(0xffA6D84B),
                borderRadius: BorderRadius.circular(300),
                border: Border.all(
                  color: const Color(0xff7FB52D),
                  width: 2,
                ),
              ),
            ),
          ),

          // =========================================================
          // BOTTOM BLUE SHAPE
          // =========================================================

          Positioned(
            bottom: -130,
            left: -130,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: const Color(0xff0057A3),
                borderRadius: BorderRadius.circular(300),
                border: Border.all(
                  color: const Color(0xff3E8BFF),
                  width: 2,
                ),
              ),
            ),
          ),

          // =========================================================
          // CONTENT
          // =========================================================

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    maxWidth: 430,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // =================================================
                        // HEADER
                        // =================================================

                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                isRtl
                                    ? Icons.arrow_forward_ios
                                    : Icons.arrow_back_ios,
                                size: 18,
                                color: const Color(0xff1E1446),
                              ),
                              padding: EdgeInsets.zero,
                              constraints:
                              const BoxConstraints(),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              t('create_account'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff1E1446),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(
                          t('join_e7gzly'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 45),

                        // =================================================
                        // FULL NAME
                        // =================================================

                        Text(
                          t('full_name'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1E1446),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          controller: nameController,
                          textInputAction:
                          TextInputAction.next,
                          validator: (value) {
                            final name =
                                value?.trim() ?? '';

                            if (name.isEmpty) {
                              return t('enter_name');
                            }

                            if (name.length < 3) {
                              return t('enter_name');
                            }

                            return null;
                          },
                          decoration: inputDecoration(
                            t('enter_your_name'),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // =================================================
                        // EMAIL
                        // =================================================

                        Text(
                          t('email_address'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1E1446),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          controller: emailController,
                          keyboardType:
                          TextInputType.emailAddress,
                          textInputAction:
                          TextInputAction.next,
                          autocorrect: false,
                          validator: (value) {
                            final email =
                                value?.trim() ?? '';

                            if (email.isEmpty) {
                              return t('enter_email');
                            }

                            final emailRegex = RegExp(
                              r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$',
                            );

                            if (!emailRegex
                                .hasMatch(email)) {
                              return t('invalid_email');
                            }

                            return null;
                          },
                          decoration: inputDecoration(
                            t('enter_your_email'),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // =================================================
                        // PHONE
                        // =================================================

                        Text(
                          t('phone_number'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1E1446),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          controller: phoneController,
                          keyboardType:
                          TextInputType.phone,
                          textInputAction:
                          TextInputAction.next,
                          validator: (value) {
                            final phone =
                                value?.trim() ?? '';

                            if (phone.isEmpty) {
                              return t('enter_phone');
                            }

                            final digitsOnly =
                            phone.replaceAll(
                              RegExp(r'\D'),
                              '',
                            );

                            if (digitsOnly.length <
                                10) {
                              return t('invalid_number');
                            }

                            return null;
                          },
                          decoration:
                          inputDecoration(
                            t('enter_your_number'),
                          ).copyWith(
                            prefixText: '+20  ',
                          ),
                        ),

                        const SizedBox(height: 25),

                        // =================================================
                        // CITY
                        // =================================================

                        Text(
                          t('governorate_city'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1E1446),
                          ),
                        ),

                        const SizedBox(height: 10),

                        DropdownButtonFormField<String>(
                          value: selectedCity,
                          isExpanded: true,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return t('select_city');
                            }

                            return null;
                          },
                          decoration: inputDecoration(
                            t('select_your_city'),
                          ),
                          items: citiesKeys.map(
                                (cityKey) {
                              return DropdownMenuItem<
                                  String>(
                                value: cityKey,
                                child: Text(
                                  t(cityKey),
                                ),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCity = value;
                            });
                          },
                        ),

                        const SizedBox(height: 35),

                        // =================================================
                        // STEP INDICATOR
                        // =================================================

                        Text(
                          t('step_1_of_3'),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const LinearProgressIndicator(
                          value: 0.33,
                          backgroundColor:
                          Color(0xffE0E0E0),
                          color: Color(0xff7CC000),
                        ),

                        const SizedBox(height: 20),

                        // =================================================
                        // CONTINUE
                        // =================================================

                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xff7CC000),
                              elevation: 0,
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                  14,
                                ),
                              ),
                            ),
                            onPressed: _continue,
                            child: Text(
                              t('next'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight:
                                FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder:
      const OutlineInputBorder(
        borderRadius:
        BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Color(0xff7CC000),
          width: 2,
        ),
      ),
      errorBorder:
      const OutlineInputBorder(
        borderRadius:
        BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder:
      const OutlineInputBorder(
        borderRadius:
        BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }
}