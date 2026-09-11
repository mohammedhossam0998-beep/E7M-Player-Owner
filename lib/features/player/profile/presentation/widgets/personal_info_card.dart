import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/player_profile_model.dart';
import '../../../../../shared/localization/language_provider.dart';
import 'profile_info_row.dart';

class PersonalInfoCard extends StatelessWidget {
  final PlayerProfileModel profile;

  const PersonalInfoCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().translate;

    return _CardContainer(
      title: t('personal_information'),
      icon: Icons.person_outline,
      children: [
        if (_hasValue(profile.phone))
          ProfileInfoRow(
            icon: Icons.phone_outlined,
            title: t('phone'),
            value: profile.phone!,
          ),

        if (_hasValue(profile.email))
          ProfileInfoRow(
            icon: Icons.email_outlined,
            title: t('email'),
            value: profile.email!,
          ),

        if (_hasValue(profile.city))
          ProfileInfoRow(
            icon: Icons.location_on_outlined,
            title: t('city'),
            value: profile.city!,
          ),

        if (_hasValue(profile.dateOfBirth))
          ProfileInfoRow(
            icon: Icons.cake_outlined,
            title: t('date_of_birth'),
            value: profile.dateOfBirth!,
          ),

        if (!_hasAnyData) _emptyState(t),
      ],
    );
  }

  bool get _hasAnyData {
    return _hasValue(profile.phone) ||
        _hasValue(profile.email) ||
        _hasValue(profile.city) ||
        _hasValue(profile.dateOfBirth);
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  Widget _emptyState(String Function(String) t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        t('no_information_available'),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _CardContainer({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xff7CC000),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xff1E1446),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}