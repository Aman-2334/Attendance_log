// ignore_for_file: use_build_context_synchronously

import 'package:attendance_log/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  void logoff(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed("Authentication");
    SharedPreferences.getInstance().then((pref) => pref.clear());
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = AppTheme().themeData;
    return SizedBox(
      height: AppTheme().buttonHeight,
      child: TextButton.icon(
        onPressed: () => logoff(context),
        icon: const Icon(Icons.power_settings_new_outlined),
        label: Text(
          "Log Out",
          style: themeData.textTheme.titleSmall,
        ),
      ),
    );
  }
}
