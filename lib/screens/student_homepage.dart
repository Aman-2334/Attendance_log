import 'package:attendance_log/screens/student_dashboard.dart';
import 'package:attendance_log/screens/qrcode.dart';
import 'package:attendance_log/screens/student_profile.dart';
import 'package:attendance_log/screens/student_subject_selection.dart';
import 'package:attendance_log/theme/theme.dart';
import 'package:flutter/material.dart';

class StudentHomepage extends StatefulWidget {
  const StudentHomepage({super.key});
  static const routeName = 'studentHomepage';

  @override
  State<StudentHomepage> createState() => _StudentHomepageState();
}

class _StudentHomepageState extends State<StudentHomepage> {
  int selectedScreen = 0;

  List<Widget> screens = [
    const Classroom(),
    const SubjectSelection(),
    const QRcode(),
    const StudentProfile(),
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
            navbarItem(Icons.school_outlined, "Classroom", 0),
            navbarItem(Icons.class_outlined, "Subject", 1),
            navbarItem(Icons.qr_code_2_rounded, "QR code", 2),
            navbarItem(Icons.account_circle_outlined, "Profile", 3),
          ],
        ),
      ),
    );
  }
}
