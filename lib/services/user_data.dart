// lib/services/user_data.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'profile_service.dart';

class UserData extends ChangeNotifier {
  static final UserData instance = UserData._();
  UserData._();

  // ── Fields ─────────────────────────────────────────────────────────────────
  String       name         = '';
  String       username     = '';
  String       address      = '';
  String       contact      = '';
  String       email        = '';
  int?         age;
  String       skinType     = '';
  List<String> skinConcerns = [];
  String?      avatarUrl;   // remote Supabase URL
  File?        avatarFile;  // local file shown while uploading

  // ── Load from Supabase ─────────────────────────────────────────────────────
  Future<void> load() async {
    final row = await ProfileService.instance.fetch();
    if (row == null) return; // new user — keep defaults

    name         = (row['name']          as String?) ?? '';
    username     = (row['username']      as String?) ?? '';
    address      = (row['address']       as String?) ?? '';
    contact      = (row['contact']       as String?) ?? '';
    email        = (row['email']         as String?) ?? '';
    age          = row['age']            as int?;
    skinType     = (row['skin_type']     as String?) ?? '';
    skinConcerns = _toList(row['skin_concerns']);
    avatarUrl    = row['avatar_url']     as String?;
    avatarFile   = null; // local path is device-specific, never carry it across

    notifyListeners();
  }

  // ── Mutators ───────────────────────────────────────────────────────────────

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

    ProfileService.instance.save({
      if (name     != null) 'name':     name,
      if (username != null) 'username': username,
      if (address  != null) 'address':  address,
      if (contact  != null) 'contact':  contact,
      if (email    != null) 'email':    email,
    });
    notifyListeners();
  }

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

    if (this.username.isEmpty && name != null && name.isNotEmpty) {
      this.username = '@${name.toLowerCase().replaceAll(' ', '')}';
    }

    ProfileService.instance.save({
      if (name         != null) 'name':          name,
      if (age          != null) 'age':           age,
      if (skinType     != null) 'skin_type':     skinType,
      if (skinConcerns != null) 'skin_concerns': skinConcerns,
      'username': this.username,
    });
    notifyListeners();
  }

  /// Shows the local file immediately, then uploads and switches to the URL.
  Future<void> updateAvatar(File file) async {
    avatarFile = file;
    notifyListeners(); // instant visual feedback

    final url = await ProfileService.instance.uploadAvatar(file);
    if (url != null) {
      avatarUrl  = url;
      avatarFile = null; // now using remote URL
    }
    notifyListeners();
  }

  // ── Clear (sign-out) ───────────────────────────────────────────────────────
  void clear() {
    name = ''; username = ''; address = ''; contact = ''; email = '';
    age = null; skinType = ''; skinConcerns = [];
    avatarUrl = null; avatarFile = null;
    notifyListeners();
  }

  // ── Helper ─────────────────────────────────────────────────────────────────
  static List<String> _toList(dynamic value) =>
      (value as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
}