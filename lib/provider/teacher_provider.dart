import 'package:attendance_log/models/teacher.dart';
import 'package:attendance_log/services/teacher_service.dart';
import 'package:flutter/material.dart';

class TeacherProvider extends ChangeNotifier {
  List<Teacher> teacher = [];
  bool loadingTeacher = false;

  Future<void> loadTeacher(String instituteId) async {
    loadingTeacher = true;
    notifyListeners();
    teacher = await TeacherService().getTeacher(instituteId);
    loadingTeacher = false;
    notifyListeners();
  }
}