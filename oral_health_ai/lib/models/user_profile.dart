enum GenderType { male, female, other }

class UserProfile {
  final String name;
  final String memberSince;
  final int age;
  final GenderType gender;
  final String bloodType;
  final bool smoker;
  final bool regularAlcoholConsumption;
  final String? imagePath;

  const UserProfile({
    required this.name,
    required this.memberSince,
    required this.age,
    required this.gender,
    required this.bloodType,
    required this.smoker,
    required this.regularAlcoholConsumption,
    this.imagePath,
  });
}