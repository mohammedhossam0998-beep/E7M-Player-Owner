import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/features/player/profile/data/player_profile_repository.dart';
import 'package:e7m/features/player/profile/presentation/providers/player_profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final PlayerProfileProvider _profileProvider;

  File? selectedImage;
  final ImagePicker picker = ImagePicker();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final experienceController = TextEditingController();
  final bioController = TextEditingController();

  String city = "cairo";
  String position = "forward";
  String level = "intermediate";
  String preferredFoot = "left";

  // Fields موجودة في الـ API لكن مش موجودة في الـ UI الحالي.
  // لازم نحافظ عليها عند الحفظ بدل ما نمسحها.
  String? _dateOfBirth;
  String? _playingStyle;

  String? _profileImage;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPickingImage = false;

  static const List<String> _cities = [
    "cairo",
    "giza",
    "alexandria",
    "mansoura",
  ];

  static const List<String> _positions = [
    "goalkeeper",
    "defender",
    "midfielder",
    "forward",
  ];

  static const List<String> _feet = [
    "right",
    "left",
    "both",
  ];

  static const List<String> _levels = [
    "beginner",
    "intermediate",
    "pro_player",
  ];

  @override
  void initState() {
    super.initState();
    _profileProvider = PlayerProfileProvider(
      repository: PlayerProfileRepository(),
    );
    _loadProfile();
  }

  // ============================================================
  // LOAD PROFILE
  // GET /api/player/profile
  // ============================================================

  Future<void> _loadProfile() async {
    try {
      await _profileProvider.loadProfile();

      if (!mounted) return;

      final profile = _profileProvider.profile;
      if (profile == null) {
        throw Exception(
          _profileProvider.errorMessage ?? 'Profile data not found',
        );
      }

      nameController.text = profile.fullName ?? '';
      emailController.text = profile.email ?? '';
      phoneController.text = profile.phone ?? '';
      heightController.text = profile.height?.toString() ?? '';
      weightController.text = profile.weight?.toString() ?? '';
      experienceController.text = profile.experience?.toString() ?? '';
      bioController.text = profile.bio ?? '';

      _dateOfBirth = profile.dateOfBirth;
      _playingStyle = profile.playingStyle;
      _profileImage = profile.profileImage;

      final serverCity = profile.city?.toLowerCase();
      if (serverCity != null && _cities.contains(serverCity)) {
        city = serverCity;
      }

      final serverPosition = profile.position?.toLowerCase();
      if (serverPosition != null && _positions.contains(serverPosition)) {
        position = serverPosition;
      }

      final serverFoot = profile.preferredFoot?.toLowerCase();
      if (serverFoot != null && _feet.contains(serverFoot)) {
        preferredFoot = serverFoot;
      }

      final serverLevel = profile.skillLevel?.toLowerCase();
      if (serverLevel != null && _levels.contains(serverLevel)) {
        level = serverLevel;
      }

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> pickImage() async {
    // يمنع تشغيل ImagePicker مرتين في نفس الوقت.
    if (_isPickingImage) return;

    _isPickingImage = true;

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (!mounted) return;

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      _isPickingImage = false;
    }
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _saveProfile() async {
    final t = context.read<LanguageProvider>().translate;

    // الاسم
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('enter_name')),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // البريد
    final email = emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('enter_valid_email')),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // الهاتف
    final phone = phoneController.text.trim();

    if (phone.length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('enter_valid_phone')),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final height = _parseInt(heightController.text);
    final weight = _parseInt(weightController.text);
    final experience = _parseInt(experienceController.text);

    if (heightController.text.trim().isNotEmpty &&
        height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Height must be a valid number'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (weightController.text.trim().isNotEmpty &&
        weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weight must be a valid number'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (experienceController.text.trim().isNotEmpty &&
        experience == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Experience must be a valid number'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // ========================================================
      // 1. UPDATE ACCOUNT
      // PUT /api/player/account
      // ========================================================

      final accountUpdated = await _profileProvider.updateAccount({
        'full_name': nameController.text.trim(),
        'email': email,
        'phone': phone,
      });

      if (!accountUpdated) {
        throw Exception(
          _profileProvider.errorMessage ?? 'Failed to update account',
        );
      }

      // ========================================================
      // 2. UPDATE PLAYER PROFILE
      // PUT /api/player/profile
      //
      // IMPORTANT:
      // date_of_birth و playing_style يتم الحفاظ عليهم
      // من البيانات التي رجعت من GET.
      // ========================================================

      final profileUpdated = await _profileProvider.updateProfile({
        'position': position,
        'skill_level': level,
        'date_of_birth': _dateOfBirth,
        'preferred_foot': preferredFoot,
        'bio': bioController.text.trim().isEmpty
            ? null
            : bioController.text.trim(),
        'height': height,
        'weight': weight,
        'city': city,
        'experience': experience,
        'playing_style': _playingStyle,
      });

      if (!profileUpdated) {
        throw Exception(
          _profileProvider.errorMessage ?? 'Failed to update profile',
        );
      }

      // Upload the selected image only after the profile/account updates succeed.
      if (selectedImage != null) {
        final imageUploaded = await _profileProvider.uploadProfileImage(
          selectedImage!,
        );

        if (!imageUploaded) {
          throw Exception(
            _profileProvider.errorMessage ?? 'Failed to upload profile image',
          );
        }
      }

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('profile_updated_successfully'),
          ),
          backgroundColor: const Color(0xff7CC000),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  int? _parseInt(String value) {
    final text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    return int.tryParse(text);
  }

  // ============================================================
  // PROFILE IMAGE URL
  // ============================================================

  String? _profileImageUrl() {
    if (_profileImage == null ||
        _profileImage!.isEmpty ||
        _profileImage == 'null') {
      return null;
    }

    if (_profileImage!.startsWith('http://') ||
        _profileImage!.startsWith('https://')) {
      return _profileImage;
    }

    const serverBase = 'http://192.168.1.2:5000';

    if (_profileImage!.startsWith('/')) {
      return '$serverBase$_profileImage';
    }

    return '$serverBase/$_profileImage';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    heightController.dispose();
    weightController.dispose();
    experienceController.dispose();
    bioController.dispose();
    _profileProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
            color: const Color(0xff1E1446),
          ),
        ),
        title: Text(
          t('edit_profile'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xff7CC000),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ==================================================
            // PROFILE IMAGE
            // ==================================================

            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage:
                      selectedImage != null
                          ? FileImage(selectedImage!)
                          : (_profileImageUrl() != null
                          ? NetworkImage(
                        _profileImageUrl()!,
                      )
                          : const AssetImage(
                        "assets/images/player.png",
                      )) as ImageProvider,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xff7CC000),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // PERSONAL INFORMATION
            // ==================================================

            buildSectionTitle(t('personal_info')),
            const SizedBox(height: 12),

            buildTextField(
              nameController,
              t('full_name'),
              Icons.person_outline,
            ),

            const SizedBox(height: 15),

            buildTextField(
              emailController,
              t('email'),
              Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 15),

            buildTextField(
              phoneController,
              t('phone_number'),
              Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 15),

            buildDropdownField<String>(
              label: t('city'),
              value: city,
              icon: Icons.location_on_outlined,
              items: _cities,
              itemToString: (val) => t(val),
              onChanged: (val) {
                if (val == null) return;

                setState(() {
                  city = val;
                });
              },
            ),

            const Divider(height: 40),

            // ==================================================
            // PLAYER STATS
            // ==================================================

            buildSectionTitle(t('player_stats')),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: buildTextField(
                    heightController,
                    t('height_cm'),
                    Icons.height,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: buildTextField(
                    weightController,
                    t('weight_kg'),
                    Icons.fitness_center,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: buildDropdownField<String>(
                    label: t('position'),
                    value: position,
                    icon: Icons.sports_soccer,
                    items: _positions,
                    itemToString: (val) => t(val),
                    onChanged: (val) {
                      if (val == null) return;

                      setState(() {
                        position = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: buildDropdownField<String>(
                    label: t('preferred_foot'),
                    value: preferredFoot,
                    icon:
                    Icons.airline_seat_legroom_extra,
                    items: _feet,
                    itemToString: (val) => t(val),
                    onChanged: (val) {
                      if (val == null) return;

                      setState(() {
                        preferredFoot = val;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: buildTextField(
                    experienceController,
                    t('experience_years'),
                    Icons.timeline,
                    keyboardType:
                    TextInputType.number,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: buildDropdownField<String>(
                    label: t('preferred_level'),
                    value: level,
                    icon: Icons.bar_chart,
                    items: _levels,
                    itemToString: (val) => t(val),
                    onChanged: (val) {
                      if (val == null) return;

                      setState(() {
                        level = val;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            buildTextField(
              bioController,
              t('about_me'),
              Icons.notes,
              maxLines: 3,
            ),

            const SizedBox(height: 35),

            // ==================================================
            // SAVE
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xff7CC000),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed:
                _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  t('save_changes'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xff1E1446),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.grey,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xff1E1446),
        ),
        fillColor: Colors.white,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xff7CC000),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget buildDropdownField<T>({
    required String label,
    required T value,
    required IconData icon,
    required List<T> items,
    required String Function(T) itemToString,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.grey,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xff1E1446),
        ),
        fillColor: Colors.white,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xff7CC000),
            width: 1.5,
          ),
        ),
      ),
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemToString(item),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
    );
  }
}