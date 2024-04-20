import 'package:attendance_log/provider/subject_provider.dart';
import 'package:attendance_log/provider/user_provider.dart';
import 'package:attendance_log/screens/teacher_attendance_dashboard.dart';
import 'package:attendance_log/screens/teacher_profile.dart';
import 'package:attendance_log/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherHomepage extends StatefulWidget {
  const TeacherHomepage({super.key});
  static const routeName = 'teacherHomepage';

  @override
  State<TeacherHomepage> createState() => _TeacherHomepageState();
}

class _TeacherHomepageState extends State<TeacherHomepage> {
  int selectedScreen = 0;

  List<Widget> screens = [
    const TeacherAttendanceDashboard(),
    const TeacherProfile(),
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      SubjectProvider subjectProvider =
          Provider.of<SubjectProvider>(context, listen: false);
      subjectProvider.loadSubjectsById(
          userProvider.user!.institute, userProvider.user!.subjects);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: selectedScreen == 0
            ? const Text("Attendance")
            : selectedScreen == 1
                ? const Text("Attendance")
                : const Text("Profile Setting"),
      ),
      body: screens[selectedScreen],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: AppTheme().bottomNavbarColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              navbarItem(Icons.class_outlined, "Attendance", 0),
              navbarItem(Icons.account_circle_outlined, "Profile", 1),
            ],
          ),
        ),
      ),
    );
  }
}
