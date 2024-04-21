import 'dart:convert';

import 'package:attendance_log/helper.dart';
import 'package:attendance_log/models/user.dart';
import 'package:attendance_log/provider/attendance_provider.dart';
import 'package:attendance_log/provider/institute_provider.dart';
import 'package:attendance_log/provider/student_provider.dart';
import 'package:attendance_log/provider/subject_provider.dart';
import 'package:attendance_log/provider/teacher_provider.dart';
import 'package:attendance_log/provider/user_provider.dart';
import 'package:attendance_log/screens/admin_homepage.dart';
import 'package:attendance_log/screens/auth.dart';
import 'package:attendance_log/screens/student_homepage.dart';
import 'package:attendance_log/screens/teacher_homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:attendance_log/theme/theme.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<AppUser> getUser() async {
    AppUser user;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = AppUser.fromJson(jsonDecode(prefs.getString("user")!));
    print("User before app start $user");
    return user;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = AppTheme().themeData;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SubjectProvider>(
            create: (_) => SubjectProvider()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<TeacherProvider>(
            create: (_) => TeacherProvider()),
        ChangeNotifierProvider<InstituteProvider>(
            create: (_) => InstituteProvider()),
        ChangeNotifierProvider<StudentProvider>(
            create: (_) => StudentProvider()),
        ChangeNotifierProvider<AttendanceProvider>(
            create: (_) => AttendanceProvider()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Attendance Log',
          theme: AppTheme().themeData,
          // home: const AdminHomepage(),
          home: FirebaseAuth.instance.currentUser == null
              ? const AuthPage()
              : FutureBuilder(
                  future: getUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.data == null) {
                        FirebaseAuth.instance.signOut();
                        return const AuthPage();
                      }
                      AppUser currentUser = snapshot.data!;
                      Provider.of<UserProvider>(context, listen: false).user =
                          currentUser;
                      if (currentUser.role == Role.Admin) {
                        return const AdminHomepage();
                      } else if (currentUser.role == Role.Teacher) {
                        return const TeacherHomepage();
                      } else {
                        return const StudentHomepage();
                      }
                    } else {
                      return Container(
                        color: themeData.primaryColorDark,
                      );
                    }
                  }),
          routes: {
            AuthPage.routeName: (context) => const AuthPage(),
            AdminHomepage.routeName: (context) => const AdminHomepage(),
            TeacherHomepage.routeName: (context) => const TeacherHomepage(),
            StudentHomepage.routeName: (context) => const StudentHomepage(),
          }),
    );
  }
}
