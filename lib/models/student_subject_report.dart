import 'package:attendance_log/models/attendance.dart';
import 'package:attendance_log/models/subject.dart';
import 'package:attendance_log/models/teacher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentSubjectReport {
  Subject subject;
  Teacher teacher;
  List<Attendance> attendanceReport;

  StudentSubjectReport({
    required this.subject,
    required this.teacher,
    required this.attendanceReport,
  }) : super();

  factory StudentSubjectReport.fromDoc(
      Subject subject,DocumentSnapshot teacherDoc, List<DocumentSnapshot> attendanceDocs) {
    return StudentSubjectReport(
      subject: subject,
      teacher: Teacher.fromDoc(teacherDoc),
      attendanceReport: attendanceDocs.map<Attendance>((DocumentSnapshot doc) => Attendance.fromDoc(doc)).toList(),
    );
  }

  @override
  String toString() {
    return "Subject Report $subject, $teacher, $attendanceReport";
  }
}