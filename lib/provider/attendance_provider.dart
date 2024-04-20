import 'package:attendance_log/models/attendance.dart';
import 'package:attendance_log/services/attendance_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceProvider extends ChangeNotifier {
  List<Attendance>? attendanceSession;
  bool loadingAttendanceSession = false;

  Future<void> loadAttendanceSession({
    required String instituteId,
    required String courseId,
    required DateTime date,
  }) async {
    print("loading attendance session");
    loadingAttendanceSession = true;
    notifyListeners();
    attendanceSession = await AttendanceService().getAttendanceSession(
        instituteId: instituteId,
        courseId: courseId,
        date: DateFormat("dd-MM-yyyy").format(date));
    print("Attendance sessions: $attendanceSession");
    loadingAttendanceSession = false;
    notifyListeners();
  }
}
