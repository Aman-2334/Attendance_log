import 'package:attendance_log/models/attendance.dart';
import 'package:attendance_log/models/student_subject_report.dart';
import 'package:attendance_log/provider/subject_provider.dart';
import 'package:attendance_log/provider/user_provider.dart';
import 'package:attendance_log/services/student_service.dart';
import 'package:flutter/material.dart';

class StudentProvider extends ChangeNotifier {
  List<StudentSubjectReport>? studentSubjectReport;
  List<AttendanceSummary> attendanceSummary = [];
  bool loadingStudentSubjectReport = false;

  Future<void> getStudentReport(
      SubjectProvider subjectProvider, UserProvider userProvider) async {
    print("get student Report");
    loadingStudentSubjectReport = true;
    notifyListeners();
    studentSubjectReport =
        await StudentService().loadSubjectReport(subjectProvider, userProvider);
    print("studentSubjectReport $studentSubjectReport");
    getAttendanceSummary(userProvider);
    loadingStudentSubjectReport = false;
    notifyListeners();
  }

  void getAttendanceSummary(UserProvider userProvider) {
    List<AttendanceSummary> summary = [];
    if (studentSubjectReport == null) return;
    for (StudentSubjectReport report in studentSubjectReport!) {
      print("report $report");
      int totalClass = 0, totalPresent = 0;
      for (Attendance session in report.attendanceReport) {
        print("session $session");
        totalClass += session.classCount;
        totalPresent += session.studentIds.contains(userProvider.user!.id)
            ? session.classCount
            : 0;
      }
      summary.add(AttendanceSummary(
          subject: report.subject,
          totalClass: totalClass,
          totalPresent: totalPresent));
    }
    attendanceSummary = summary;
  }
}
