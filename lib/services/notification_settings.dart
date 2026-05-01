// lib/services/notification_settings.dart
import 'package:flutter/foundation.dart';
import 'profile_service.dart';

class NotificationSettings extends ChangeNotifier {
  NotificationSettings._();
  static final NotificationSettings instance = NotificationSettings._();

  // defaults
  bool pushAll       = true;
  bool pushMessages  = true;
  bool pushLikes     = true;
  bool pushComments  = true;
  bool pushFollowers = false;
  bool pushPromos    = false;
  bool emailWeekly   = true;
  bool emailUpdates  = false;
  bool emailTips     = true;
  bool sound         = true;
  bool vibration     = true;
  bool doNotDisturb  = false;

  // ── Load ───────────────────────────────────────────────────────────────────
  Future<void> load() async {
    final row = await ProfileService.instance.fetch();
    if (row == null) return;

    bool b(String col, bool def) => (row[col] as bool?) ?? def;

    pushAll       = b('notif_push_all',       true);
    pushMessages  = b('notif_push_messages',  true);
    pushLikes     = b('notif_push_likes',     true);
    pushComments  = b('notif_push_comments',  true);
    pushFollowers = b('notif_push_followers', false);
    pushPromos    = b('notif_push_promos',    false);
    emailWeekly   = b('notif_email_weekly',   true);
    emailUpdates  = b('notif_email_updates',  false);
    emailTips     = b('notif_email_tips',     true);
    sound         = b('notif_sound',          true);
    vibration     = b('notif_vibration',      true);
    doNotDisturb  = b('notif_do_not_disturb', false);

    notifyListeners();
  }

  // ── Setters ────────────────────────────────────────────────────────────────
  void setPushAll(bool v) {
    pushAll = pushMessages = pushLikes = pushComments = v;
    ProfileService.instance.save({
      'notif_push_all': v, 'notif_push_messages': v,
      'notif_push_likes': v, 'notif_push_comments': v,
    });
    notifyListeners();
  }

  void setPushMessages(bool v)  => _set(() => pushMessages  = v, 'notif_push_messages',  v);
  void setPushLikes(bool v)     => _set(() => pushLikes     = v, 'notif_push_likes',     v);
  void setPushComments(bool v)  => _set(() => pushComments  = v, 'notif_push_comments',  v);
  void setPushFollowers(bool v) => _set(() => pushFollowers = v, 'notif_push_followers', v);
  void setPushPromos(bool v)    => _set(() => pushPromos    = v, 'notif_push_promos',    v);
  void setEmailWeekly(bool v)   => _set(() => emailWeekly   = v, 'notif_email_weekly',   v);
  void setEmailUpdates(bool v)  => _set(() => emailUpdates  = v, 'notif_email_updates',  v);
  void setEmailTips(bool v)     => _set(() => emailTips     = v, 'notif_email_tips',     v);
  void setSound(bool v)         => _set(() => sound         = v, 'notif_sound',          v);
  void setVibration(bool v)     => _set(() => vibration     = v, 'notif_vibration',      v);
  void setDoNotDisturb(bool v)  => _set(() => doNotDisturb  = v, 'notif_do_not_disturb', v);

  void _set(void Function() mutate, String col, bool v) {
    mutate();
    ProfileService.instance.save({col: v});
    notifyListeners();
  }

  // ── Clear (sign-out) ───────────────────────────────────────────────────────
  void clear() {
    pushAll = true; pushMessages = true; pushLikes = true;
    pushComments = true; pushFollowers = false; pushPromos = false;
    emailWeekly = true; emailUpdates = false; emailTips = true;
    sound = true; vibration = true; doNotDisturb = false;
    notifyListeners();
  }
}