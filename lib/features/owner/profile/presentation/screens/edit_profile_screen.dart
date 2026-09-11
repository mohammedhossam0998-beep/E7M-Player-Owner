import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/shared/utils/image_url_helper.dart'; // <-- إضافة
import 'package:e7m/features/owner/profile/providers/owner_profile_provider.dart';
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color accent = Color(0xff7CC000);
  static const Color navy = Color(0xff1E1446);
  static const Color background = Color(0xffF7F8FA);
  static const Color border = Color(0xffE8EAF0);

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final businessNameController = TextEditingController();
  final businessPhoneController = TextEditingController();
  final businessEmailController = TextEditingController();

  File? profileImage;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final provider = context.read<OwnerProfileProvider>();

    if (!provider.hasProfile) {
      await provider.loadProfile();
    }

    if (!mounted) return;

    final profile = provider.profile;

    if (profile != null && !_initialized) {
      fullNameController.text = profile.fullName ?? '';
      emailController.text = profile.email ?? '';
      phoneController.text = profile.phone ?? '';

      businessNameController.text = profile.businessName ?? '';
      businessPhoneController.text = profile.businessPhone ?? '';
      businessEmailController.text = profile.businessEmail ?? '';

      _initialized = true;

      setState(() {});
    }
  }

  // تم استبدال المنطق المحلي بالدالة الموحدة ImageUrlHelper.build
  // (كانت هنا مشكلة السلاش المزدوج //)
  String _buildImageUrl(String? imagePath) {
    return ImageUrlHelper.build(imagePath);
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null || !mounted) return;

    setState(() {
      profileImage = File(image.path);
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final languageProvider = context.read<LanguageProvider>();
    final provider = context.read<OwnerProfileProvider>();

    // ============================================================
    // UPLOAD NEW PROFILE IMAGE FIRST
    // ============================================================

    if (profileImage != null) {
      final imageSuccess =
      await provider.uploadProfileImage(profileImage!);

      if (!mounted) return;

      if (!imageSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: Text(
              provider.errorMessage ??
                  languageProvider.translate(
                    'something_went_wrong',
                  ),
            ),
          ),
        );
        return;
      }
    }

    // ============================================================
    // UPDATE PROFILE DATA
    // ============================================================

    final success = await provider.updateProfile(
      fullName: fullNameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      profileImage: provider.profile?.profileImage,
      businessName: businessNameController.text.trim(),
      businessPhone: businessPhoneController.text.trim(),
      businessEmail: businessEmailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: accent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            languageProvider.translate(
              'profile_updated_successfully',
            ),
          ),
        ),
      );

      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Text(
          provider.errorMessage ??
              languageProvider.translate(
                'something_went_wrong',
              ),
        ),
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: navy,
          ),
          onPressed: () {
            if (!context.read<OwnerProfileProvider>().isUpdating) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          languageProvider.translate('edit_profile'),
          style: const TextStyle(
            color: navy,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
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
              languageProvider,
            );
          }

          return SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  32,
                ),
                child: Column(
                  children: [
                    _buildProfileHeader(provider),

                    const SizedBox(height: 24),

                    _buildSection(
                      icon: Icons.person_outline_rounded,
                      title: languageProvider.translate(
                        'personal_information',
                      ),
                      color: accent,
                      children: [
                        _buildField(
                          controller: fullNameController,
                          label: languageProvider.translate(
                            'full_name',
                          ),
                          icon: Icons.person_outline_rounded,
                          textInputAction:
                          TextInputAction.next,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return languageProvider.translate(
                                'full_name_required',
                              );
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        _buildField(
                          controller: emailController,
                          label: languageProvider.translate(
                            'email',
                          ),
                          icon: Icons.email_outlined,
                          keyboardType:
                          TextInputType.emailAddress,
                          textInputAction:
                          TextInputAction.next,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return languageProvider.translate(
                                'email_required',
                              );
                            }

                            final regex = RegExp(
                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                            );

                            if (!regex.hasMatch(
                              value.trim(),
                            )) {
                              return languageProvider.translate(
                                'invalid_email',
                              );
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        _buildField(
                          controller: phoneController,
                          label: languageProvider.translate(
                            'phone_number',
                          ),
                          icon: Icons.phone_outlined,
                          keyboardType:
                          TextInputType.phone,
                          textInputAction:
                          TextInputAction.next,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildSection(
                      icon: Icons.storefront_outlined,
                      title: languageProvider.translate(
                        'business_information',
                      ),
                      color: navy,
                      children: [
                        _buildField(
                          controller:
                          businessNameController,
                          label: languageProvider.translate(
                            'business_name',
                          ),
                          icon: Icons.business_outlined,
                          textInputAction:
                          TextInputAction.next,
                        ),

                        const SizedBox(height: 14),

                        _buildField(
                          controller:
                          businessPhoneController,
                          label: languageProvider.translate(
                            'business_phone',
                          ),
                          icon: Icons.phone_outlined,
                          keyboardType:
                          TextInputType.phone,
                          textInputAction:
                          TextInputAction.next,
                        ),

                        const SizedBox(height: 14),

                        _buildField(
                          controller:
                          businessEmailController,
                          label: languageProvider.translate(
                            'business_email',
                          ),
                          icon:
                          Icons.alternate_email_rounded,
                          keyboardType:
                          TextInputType.emailAddress,
                          textInputAction:
                          TextInputAction.done,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return null;
                            }

                            final regex = RegExp(
                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                            );

                            if (!regex.hasMatch(
                              value.trim(),
                            )) {
                              return languageProvider.translate(
                                'invalid_email',
                              );
                            }

                            return null;
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildSaveButton(
                      languageProvider,
                      provider,
                    ),

                    const SizedBox(height: 8),

                    TextButton(
                      onPressed: provider.isUpdating
                          ? null
                          : () => Navigator.pop(context),
                      child: Text(
                        languageProvider.translate('cancel'),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
      OwnerProfileProvider provider,
      ) {
    final profile = provider.profile;

    final imageUrl = _buildImageUrl(profile?.profileImage);

    ImageProvider? imageProvider;

    if (profileImage != null) {
      imageProvider = FileImage(profileImage!);
    } else if (imageUrl.isNotEmpty) {
      imageProvider = NetworkImage(imageUrl);
    }

    final name = profile?.fullName?.trim() ?? '';

    final initial = name.isNotEmpty
        ? name.substring(0, 1).toUpperCase()
        : 'O';

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 104,
              height: 104,
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
                backgroundColor: const Color(0xffEEF8E1),
                backgroundImage: imageProvider,
                child: imageProvider == null
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
                  customBorder: const CircleBorder(),
                  onTap: provider.isUpdating ||
                      provider.isUploadingImage
                      ? null
                      : _pickImage,
                  child: const Padding(
                    padding: EdgeInsets.all(9),
                    child: Icon(
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
          profile?.email ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
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
        border: Border.all(
          color: border,
        ),
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

              Text(
                title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: const TextStyle(
        color: navy,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: accent,
          size: 21,
        ),
        filled: true,
        fillColor: const Color(0xffFAFBFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: accent,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(
      LanguageProvider languageProvider,
      OwnerProfileProvider provider,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: provider.isUpdating ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          disabledBackgroundColor:
          accent.withValues(alpha: .55),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: provider.isUpdating
              ? const SizedBox(
            key: ValueKey('loading'),
            width: 21,
            height: 21,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: Colors.white,
            ),
          )
              : Text(
            languageProvider.translate(
              'save_changes',
            ),
            key: const ValueKey('text'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(
      OwnerProfileProvider provider,
      LanguageProvider languageProvider,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: .10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Colors.grey,
                size: 34,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              provider.errorMessage ??
                  languageProvider.translate(
                    'something_went_wrong',
                  ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: navy,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            TextButton.icon(
              onPressed: provider.loadProfile,
              icon: const Icon(
                Icons.refresh_rounded,
                color: accent,
              ),
              label: Text(
                languageProvider.translate('retry'),
                style: const TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}