import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../widgets/profile/gender_avatar.dart';
import '../widgets/profile/profile_info_card.dart';
import '../widgets/profile/profile_menu_tile.dart';
import '../widgets/profile/profile_toggle_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfile user = const UserProfile(
    name: 'Alex Johnson',
    memberSince: 'Member since Jan 2026',
    age: 34,
    gender: GenderType.other,
    bloodType: 'O+',
    smoker: false,
    regularAlcoholConsumption: false,
    imagePath: null, // 사진 넣을 거면 assets 경로 넣기
  );

  late bool smoker;
  late bool regularAlcoholConsumption;

  @override
  void initState() {
    super.initState();
    smoker = user.smoker;
    regularAlcoholConsumption = user.regularAlcoholConsumption;
  }

  String _genderText(GenderType gender) {
    switch (gender) {
      case GenderType.male:
        return 'Male';
      case GenderType.female:
        return 'Female';
      case GenderType.other:
        return 'Others';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(Icons.chevron_left, color: Color(0xFF0C8A8A)),
                        SizedBox(width: 2),
                        Text(
                          'Back',
                          style: TextStyle(
                            color: Color(0xFF0C8A8A),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 60),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    GenderAvatar(
                      gender: user.gender,
                      imagePath: user.imagePath,
                      size: 92,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.memberSince,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFA6A6AD),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'PERSONAL INFO',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9B9BA1),
                ),
              ),
              const SizedBox(height: 10),
              ProfileInfoCard(
                children: [
                  ProfileInfoRow(title: 'Age', value: '${user.age}'),
                  ProfileInfoRow(
                    title: 'Gender',
                    value: _genderText(user.gender),
                  ),
                  ProfileInfoRow(
                    title: 'Blood Type',
                    value: user.bloodType,
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'HEALTH FACTORS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9B9BA1),
                ),
              ),
              const SizedBox(height: 10),
              ProfileInfoCard(
                children: [
                  ProfileToggleTile(
                    title: 'Smoker',
                    value: smoker,
                    onChanged: (value) {
                      setState(() {
                        smoker = value;
                      });
                    },
                  ),
                  ProfileToggleTile(
                    title: 'Regular Alcohol Consumption',
                    value: regularAlcoholConsumption,
                    onChanged: (value) {
                      setState(() {
                        regularAlcoholConsumption = value;
                      });
                    },
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9B9BA1),
                ),
              ),
              const SizedBox(height: 10),
              ProfileInfoCard(
                children: [
                  ProfileMenuTile(title: 'Privacy Policy', onTap: () {}),
                  ProfileMenuTile(title: 'Notifications', onTap: () {}),
                  ProfileMenuTile(
                    title: 'Log Out',
                    onTap: () {},
                    isLogout: true,
                    isLast: true,
                  ),
                ],
              ),
              const Spacer(),
              const Center(
                child: Text(
                  'Oral Check v1.0.0',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFC4C4C9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}