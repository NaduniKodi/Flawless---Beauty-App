// lib/services/user_data.dart
// Simple shared singleton so profile edits propagate to HomePage in real-time.

import 'package:flutter/material.dart';


class UserData extends ChangeNotifier {
  static final UserData instance = UserData._();
  UserData._();

  String name        = "Sarah";
  String username    = "@sarahbeauty";
  String address     = "";
  String contact     = "";
  String email       = "";

  // For a real app, swap this with a network/file image.
  // null = use the default asset.
  String? avatarAsset = "assets/images/profile.webp";

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
}