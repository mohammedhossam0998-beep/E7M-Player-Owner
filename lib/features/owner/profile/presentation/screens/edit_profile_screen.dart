
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:e7m/core/network/api_client.dart';
import 'package:e7m/features/owner/profile/providers/owner_profile_provider.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color accent = Color(0xFF7CC000);
  static const Color navy = Color(0xFF1E1446);
  static const Color background = Color(0xFFF7F8FA);
  static const Color border = Color(0xFFE8EAF0);

  static const int maxImageBytes = 5 * 1024 * 1024;

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _api = ApiClient();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final businessNameController = TextEditingController();
  final businessPhoneController = TextEditingController();
  final businessEmailController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _uploadedImagePath;

  bool _initialized = false;
  bool _selectingImage = false;
  bool _saving = false;

  bool get _busy => _selectingImage || _saving;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadProfile();
      }
    });
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    final provider = context.read<OwnerProfileProvider>();

    if (!provider.hasProfile) {
      await provider.loadProfile();
    }

    if (!mounted || _initialized || provider.profile == null) {
      return;
    }

    final profile = provider.profile!;

    fullNameController.text = profile.fullName ?? '';
    emailController.text = profile.email ?? '';
    phoneController.text = profile.phone ?? '';

    businessNameController.text = profile.businessName ?? '';
    businessPhoneController.text = profile.businessPhone ?? '';
    businessEmailController.text = profile.businessEmail ?? '';

    setState(() {
      _initialized = true;
    });
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _message(
      String message, {
        bool error = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: error
              ? Colors.red.shade700
              : accent,
          behavior: SnackBarBehavior.floating,
          content: Text(message),
        ),
      );
  }

  // ============================================================
  // PICK PROFILE PHOTO - WEB + MOBILE
  // ============================================================

  Future<void> _pickImage() async {
    if (_busy) return;

    setState(() {
      _selectingImage = true;
    });

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked == null || !mounted) {
        return;
      }

      // XFile bytes work on Chrome and mobile.
      final original = await picked.readAsBytes();

      final decoded = img.decodeImage(original);

      if (decoded == null) {
        throw Exception(
          'اختار صورة JPG أو PNG أو WEBP صالحة.',
        );
      }

      // ========================================================
      // RESIZE LARGE IMAGE
      // ========================================================

      img.Image resized = decoded;

      if (decoded.width > 1400 || decoded.height > 1400) {
        resized = decoded.width >= decoded.height
            ? img.copyResize(
          decoded,
          width: 1400,
        )
            : img.copyResize(
          decoded,
          height: 1400,
        );
      }

      // ========================================================
      // CONVERT IMAGE TO JPEG
      // ========================================================

      var jpeg = img.encodeJpg(
        resized,
        quality: 85,
      );

      if (jpeg.length > maxImageBytes) {
        jpeg = img.encodeJpg(
          resized,
          quality: 60,
        );
      }

      if (jpeg.isEmpty || jpeg.length > maxImageBytes) {
        throw Exception(
          'حجم الصورة أكبر من 5 ميجابايت.',
        );
      }

      if (!mounted) return;

      // Preview the selected image.
      setState(() {
        _selectedImageBytes = Uint8List.fromList(jpeg);
        _uploadedImagePath = null;
      });
    } catch (error) {
      _message(
        error.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _selectingImage = false;
        });
      }
    }
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _save() async {
    if (_busy) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final language = context.read<LanguageProvider>();
    final provider = context.read<OwnerProfileProvider>();

    setState(() {
      _saving = true;
    });

    try {
      String? imagePath =
          _uploadedImagePath ?? provider.profile?.profileImage;

      // ========================================================
      // UPLOAD NEW PHOTO IF SELECTED
      // ========================================================

      if (_selectedImageBytes != null &&
          _uploadedImagePath == null) {
        final response = await _api.uploadBytes(
          '/owner/profile/image',
          bytes: _selectedImageBytes!,
          filename:
          'owner_${DateTime.now().millisecondsSinceEpoch}.jpg',
          fieldName: 'image',
        );

        if (response is! Map<String, dynamic> ||
            response['success'] != true) {
          throw Exception(
            'فشل رفع صورة البروفايل.',
          );
        }

        final returnedPath =
            response['profile_image']?.toString().trim() ?? '';

        if (returnedPath.isEmpty) {
          throw Exception(
            'السيرفر لم يرجع رابط الصورة.',
          );
        }

        // Save the returned path, so retrying
        // will not upload the same image twice.
        _uploadedImagePath = returnedPath;
        imagePath = returnedPath;
      }

      if (!mounted) return;

      // ========================================================
      // UPDATE PROFILE DETAILS
      // ========================================================

      final saved = await provider.updateProfile(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        profileImage: imagePath,
        businessName: businessNameController.text.trim(),
        businessPhone: businessPhoneController.text.trim(),
        businessEmail: businessEmailController.text.trim(),
      );

      if (!mounted) return;

      if (saved) {
        _message(
          language.translate(
            'profile_updated_successfully',
          ),
        );

        Navigator.of(context).pop(true);
      } else {
        _message(
          provider.errorMessage ??
              language.translate('something_went_wrong'),
          error: true,
        );
      }
    } catch (error) {
      _message(
        error.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    businessNameController.dispose();
    businessPhoneController.dispose();
    businessEmailController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        surfaceTintColor: Colors.white,

        title: Text(
          language.translate('edit_profile'),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
          onPressed: _busy
              ? null
              : () => Navigator.of(context).pop(),
        ),
      ),

      body: Consumer<OwnerProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasProfile) {
            return const Center(
              child: CircularProgressIndicator(
                color: accent,
              ),
            );
          }

          if (!provider.hasProfile) {
            return _buildError(
              provider,
              language,
            );
          }

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 760,
                ),

                child: Form(
                  key: _formKey,

                  child: ListView(
                    physics:
                    const BouncingScrollPhysics(),

                    padding: const EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      32,
                    ),

                    children: [
                      // ========================================
                      // PROFILE PHOTO
                      // ========================================

                      _buildProfileHeader(provider),

                      const SizedBox(height: 24),

                      // ========================================
                      // PERSONAL INFORMATION
                      // ========================================

                      _section(
                        icon: Icons.person_outline_rounded,
                        title: language.translate(
                          'personal_information',
                        ),
                        color: accent,

                        children: [
                          _field(
                            controller: fullNameController,
                            label: language.translate('full_name'),
                            icon: Icons.person_outline_rounded,

                            validator: (value) {
                              if (value?.trim().isEmpty ?? true) {
                                return language.translate(
                                  'full_name_required',
                                );
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          _field(
                            controller: emailController,
                            label: language.translate('email'),
                            icon: Icons.email_outlined,
                            keyboardType:
                            TextInputType.emailAddress,

                            validator: (value) {
                              final email = value?.trim() ?? '';

                              if (email.isEmpty) {
                                return language.translate(
                                  'email_required',
                                );
                              }

                              if (!_validEmail(email)) {
                                return language.translate(
                                  'invalid_email',
                                );
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          _field(
                            controller: phoneController,
                            label: language.translate('phone_number'),
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ========================================
                      // BUSINESS INFORMATION
                      // ========================================

                      _section(
                        icon: Icons.storefront_outlined,
                        title: language.translate(
                          'business_information',
                        ),
                        color: navy,

                        children: [
                          _field(
                            controller: businessNameController,
                            label: language.translate('business_name'),
                            icon: Icons.business_outlined,
                          ),

                          const SizedBox(height: 14),

                          _field(
                            controller: businessPhoneController,
                            label: language.translate('business_phone'),
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 14),

                          _field(
                            controller: businessEmailController,
                            label: language.translate('business_email'),
                            icon: Icons.alternate_email_rounded,
                            keyboardType:
                            TextInputType.emailAddress,

                            validator: (value) {
                              final email = value?.trim() ?? '';

                              if (email.isEmpty || _validEmail(email)) {
                                return null;
                              }

                              return language.translate(
                                'invalid_email',
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ========================================
                      // SAVE BUTTON
                      // ========================================

                      SizedBox(
                        height: 54,

                        child: ElevatedButton(
                          onPressed: _busy || provider.isUpdating
                              ? null
                              : _save,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,

                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(15),
                            ),
                          ),

                          child: _busy || provider.isUpdating
                              ? const SizedBox(
                            width: 22,
                            height: 22,

                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            language.translate(
                              'save_changes',
                            ),

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => Navigator.pop(context),

                        child: Text(
                          language.translate('cancel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // VALIDATE EMAIL
  // ============================================================

  bool _validEmail(String value) {
    return RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    ).hasMatch(value);
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader(
      OwnerProfileProvider provider,
      ) {
    final profile = provider.profile;

    final url = ApiClient.resolveMediaUrl(
      profile?.profileImage,
    );

    ImageProvider? photo;

    if (_selectedImageBytes != null) {
      photo = MemoryImage(
        _selectedImageBytes!,
      );
    } else if (url.isNotEmpty) {
      photo = NetworkImage(url);
    }

    final name = _initialized
        ? fullNameController.text.trim()
        : (profile?.fullName?.trim() ?? '');

    final email = _initialized
        ? emailController.text.trim()
        : (profile?.email ?? '');

    final initial = name.isEmpty
        ? 'O'
        : name.characters.first.toUpperCase();

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,

          children: [
            Container(
              width: 108,
              height: 108,
              padding: const EdgeInsets.all(4),

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,

                border: Border.all(
                  color: accent.withValues(alpha: .25),
                  width: 2,
                ),
              ),

              child: CircleAvatar(
                backgroundColor: const Color(0xFFEEF8E1),
                backgroundImage: photo,

                child: photo == null
                    ? Text(
                  initial,
                  style: const TextStyle(
                    color: accent,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                )
                    : null,
              ),
            ),

            Positioned(
              right: -2,
              bottom: 2,

              child: Material(
                color: accent,
                shape: const CircleBorder(),

                child: InkWell(
                  onTap: _busy || provider.isUpdating
                      ? null
                      : _pickImage,

                  customBorder: const CircleBorder(),

                  child: Padding(
                    padding: const EdgeInsets.all(10),

                    child: _selectingImage
                        ? const SizedBox(
                      width: 18,
                      height: 18,

                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          name.isEmpty ? 'Owner' : name,

          textAlign: TextAlign.center,

          style: const TextStyle(
            color: navy,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _section({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        18,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,

                decoration: BoxDecoration(
                  color: color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(11),
                ),

                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  title,

                  style: const TextStyle(
                    color: navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      validator: validator,
      enabled: !_saving,

      onChanged: (_) {
        // Update header while editing name or email.
        if (identical(controller, fullNameController) ||
            identical(controller, emailController)) {
          setState(() {});
        }
      },

      style: const TextStyle(
        color: navy,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),

      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: accent,
          size: 21,
        ),

        filled: true,
        fillColor: const Color(0xFFFAFBFC),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),

        border: _outline(border),
        enabledBorder: _outline(border),
        focusedBorder: _outline(accent, 1.5),
        errorBorder: _outline(Colors.red),
        focusedErrorBorder: _outline(Colors.red, 1.5),
      ),
    );
  }

  // ============================================================
  // INPUT BORDER
  // ============================================================

  OutlineInputBorder _outline(
      Color color, [
        double width = 1,
      ]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),

      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildError(
      OwnerProfileProvider provider,
      LanguageProvider language,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.grey,
              size: 54,
            ),

            const SizedBox(height: 16),

            Text(
              provider.errorMessage ??
                  language.translate(
                    'something_went_wrong',
                  ),

              textAlign: TextAlign.center,

              style: const TextStyle(
                color: navy,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 16),

            TextButton.icon(
              onPressed: _loadProfile,

              icon: const Icon(
                Icons.refresh_rounded,
                color: accent,
              ),

              label: Text(
                language.translate('retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
