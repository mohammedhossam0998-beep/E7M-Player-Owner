import 'package:flutter/material.dart';
import '../../models/player_profile_model.dart';

class ProfileHeader extends StatelessWidget {
  final PlayerProfileModel profile;
  final VoidCallback? onEditImage;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.onEditImage,
  });

  static const Color primaryGreen = Color(0xff7CC000);
  static const Color darkNavy = Color(0xff1E1446);

  // Backend server URL
  static const String _serverUrl ='http://169.254.98.204:5000';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            _buildProfileImage(),

            if (onEditImage != null)
              GestureDetector(
                onTap: onEditImage,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        Text(
          _displayValue(profile.fullName, 'Player'),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: darkNavy,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        if (_hasValue(profile.email))
          Text(
            profile.email!,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

        if (_hasValue(profile.position)) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              profile.position!,
              style: const TextStyle(
                color: primaryGreen,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileImage() {
    final imageUrl = _buildImageUrl(profile.profileImage);

    if (imageUrl == null) {
      return _buildPlaceholder();
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 112,
        height: 112,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _buildPlaceholder();
        },
      ),
    );
  }

  String? _buildImageUrl(String? image) {
    if (!_hasValue(image)) {
      return null;
    }

    final value = image!.trim();

    // Full URL returned by backend.
    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    // Relative path returned by backend.
    if (value.startsWith('/')) {
      return '$_serverUrl$value';
    }

    return '$_serverUrl/$value';
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 112,
      height: 112,
      decoration: const BoxDecoration(
        color: primaryGreen,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 58,
      ),
    );
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String _displayValue(String? value, String fallback) {
    return _hasValue(value) ? value!.trim() : fallback;
  }
}