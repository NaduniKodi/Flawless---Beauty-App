// lib/widgets/user_avatar.dart
//
// Resolves the correct avatar source from UserData:
//   1. avatarFile  — freshly picked local file (shown while upload is running)
//   2. avatarUrl   — signed Supabase Storage URL
//   3. asset       — bundled fallback
//
// Usage:
//   UserAvatar(radius: 22)   // nav bar / header
//   UserAvatar(radius: 80)   // profile card

import 'package:flutter/material.dart';
import 'package:flawless_beauty_app/services/user_data.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.radius});
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserData.instance,
      builder: (_, __) {
        final u = UserData.instance;
        final ImageProvider image;

        if (u.avatarFile != null) {
          image = FileImage(u.avatarFile!);
        } else if (u.avatarUrl != null && u.avatarUrl!.isNotEmpty) {
          image = NetworkImage(u.avatarUrl!);
        } else {
          image = const AssetImage('assets/images/profile.png');
        }

        return CircleAvatar(radius: radius, backgroundImage: image);
      },
    );
  }
}