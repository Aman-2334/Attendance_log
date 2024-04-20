import 'package:attendance_log/screens/admin_dashboard.dart';
import 'package:attendance_log/screens/admin_profile.dart';
import 'package:attendance_log/theme/theme.dart';
import 'package:flutter/material.dart';

class AdminHomepage extends StatefulWidget {
  const AdminHomepage({super.key});
  static const routeName = 'adminHomepage';

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
  int selectedScreen = 0;

  List<Widget> screens = [
    const AdminDashboard(),
    const AdminProfile(),
  ];

  Widget navbarItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedScreen = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
          ),
          Text(
            label,
            style: AppTheme().themeData.textTheme.bodySmall,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedScreen],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: AppTheme().bottomNavbarColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            navbarItem(Icons.apartment_outlined, "Institute", 0),
            navbarItem(Icons.account_circle_outlined, "Profile", 1),
          ],
        ),
      ),
    );
  }
}
