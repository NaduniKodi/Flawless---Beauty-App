// lib/services/user_data.dart
import 'package:flutter/material.dart';
import 'dart:io';

class UserData extends ChangeNotifier {
  static final UserData instance = UserData._();
  UserData._();

  // ── Core identity ────────────────────────────────────────────────────────────
  String name     = "";
  String username = "";
  String address  = "";
  String contact  = "";
  String email    = "";

  // ── Skin / beauty profile (filled in UserDetailsPage) ───────────────────────
  int?         age;
  String       skinType     = "";          // e.g. "Oily", "Dry", etc.
  List<String> skinConcerns = [];          // e.g. ["Acne", "Dark Spots"]

  // ── Avatar ───────────────────────────────────────────────────────────────────
  String? avatarAsset = "assets/images/profile.png";
  File?   avatarFile; 

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Updates profile-page fields (name, username, address, contact, email).
  void update({
    String? name,
    String? username,
    String? address,
    String? contact,
    String? email,
  }) {
    if (name     != null) this.name     = name;
    if (username != null) this.username = username;
    if (address  != null) this.address  = address;
    if (contact  != null) this.contact  = contact;
    if (email    != null) this.email    = email;
    notifyListeners();
  }

  /// Updates the beauty-profile fields captured during onboarding.
  void updateDetails({
    String?       name,
    int?          age,
    String?       skinType,
    List<String>? skinConcerns,
  }) {
    if (name         != null) this.name         = name;
    if (age          != null) this.age          = age;
    if (skinType     != null) this.skinType     = skinType;
    if (skinConcerns != null) this.skinConcerns = skinConcerns;
    // Auto-generate a username stub if none exists yet
    if (this.username.isEmpty && name != null && name.isNotEmpty) {
      this.username = "@${name.toLowerCase().replaceAll(' ', '')}";
    }
    notifyListeners();
  }

void updateAvatar(File file) {
    avatarFile = file;
    notifyListeners();
  }


}