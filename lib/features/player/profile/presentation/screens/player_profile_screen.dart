import 'package:flutter/material.dart';

import 'package:e7m/features/player/profile/models/player_profile_model.dart';
import 'package:e7m/features/player/profile/presentation/providers/player_profile_provider.dart';
import 'package:e7m/features/player/profile/presentation/screens/edit_profile_screen.dart';

import 'package:e7m/features/player/profile/presentation/widgets/profile_header.dart';
import 'package:e7m/features/player/profile/presentation/widgets/player_stats_card.dart';
import 'package:e7m/features/player/profile/presentation/widgets/personal_info_card.dart';
import 'package:e7m/features/player/profile/presentation/widgets/football_info_card.dart';
import 'package:e7m/features/player/profile/presentation/widgets/about_me_card.dart';

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  final PlayerProfileProvider _provider = PlayerProfileProvider();

  static const Color _backgroundColor = Color(0xffF7F7F3);
  static const Color _primaryColor = Color(0xff1E1446);
  static const Color _greenColor = Color(0xff7CC000);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _provider.loadProfile();
  }

  Future<void> _openEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );

    if (!mounted) return;

    await _loadProfile();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: _primaryColor,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _provider,
        builder: (context, _) {
          return RefreshIndicator(
            color: _greenColor,
            onRefresh: _loadProfile,
            child: _buildBody(_provider.profile),
          );
        },
      ),
    );
  }

  Widget _buildBody(PlayerProfileModel? profile) {
    if (_provider.isLoading && profile == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: _greenColor,
        ),
      );
    }

    if (profile == null) {
      return _buildErrorState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        30,
      ),
      child: Column(
        children: [
          ProfileHeader(
            profile: profile,
          ),

          const SizedBox(height: 16),

          const PlayerStatsCard(),

          const SizedBox(height: 20),

          PersonalInfoCard(
            profile: profile,
          ),

          const SizedBox(height: 16),

          FootballInfoCard(
            profile: profile,
          ),

          const SizedBox(height: 16),

          AboutMeCard(
            profile: profile,
          ),

          const SizedBox(height: 20),

          _buildEditButton(),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: _openEditProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: _greenColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        icon: const Icon(
          Icons.edit_outlined,
        ),
        label: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(25),
      children: [
        const SizedBox(height: 100),

        Icon(
          Icons.person_off_outlined,
          size: 70,
          color: Colors.grey.shade400,
        ),

        const SizedBox(height: 20),

        const Text(
          'Unable to load your profile',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          _provider.errorMessage ?? 'Something went wrong.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 25),

        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _loadProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: _greenColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}