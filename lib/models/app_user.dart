import 'dart:ui';

import 'clinic.dart';

class AppUser {
  String name;
  String nameLast;
  String email;
  String userid;
  String contact;
  String age;
  String gender;
  String profilePic;

  bool darkMode;
  Color colorSeed;

  List<Clinic> favoriteClinics;

  //TODO add contact, age, gender, etc

  AppUser({
    required this.name,
    required this.nameLast,
    required this.email,
    required this.userid,
    required this.contact,
    required this.age,
    required this.gender,
    required this.profilePic,
    this.darkMode = false,
    this.colorSeed = const Color(0xFFBBDEFB),
    this.favoriteClinics = const [],
  });
}
