import 'package:attendance_log/models/student_subject_report.dart';
import 'package:attendance_log/models/subject.dart';
import 'package:attendance_log/provider/subject_provider.dart';
import 'package:attendance_log/provider/user_provider.dart';
import 'package:attendance_log/services/collection_refrences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentService {
  Future<List<StudentSubjectReport>> loadSubjectReport(
      SubjectProvider subjectProvider, UserProvider userProvider) async {
    List<StudentSubjectReport> subjectReports = [];
    try {
      await subjectProvider.loadUserSubject(
          userProvider.user!.institute, userProvider.user!.subjects);
      if (subjectProvider.userSubject == null) {
        return subjectReports;
      }
      List<Subject> subjects = subjectProvider.userSubject!;
      for (Subject subject in subjects) {
        DocumentSnapshot teacherDoc = await Collections()
            .teacherCollection()
            .doc(subject.teacherReference)
            .get();
        QuerySnapshot dateDocs = await Collections()
            .attendanceCollection(userProvider.user!.institute, subject.code)
            .get();
        List<DocumentSnapshot> subjectAttendance = [];
        for (DocumentSnapshot dateDoc in dateDocs.docs) {
          QuerySnapshot sessionDocs = await Collections()
              .attendanceSessionCollection(
                  userProvider.user!.institute, subject.code, dateDoc.id)
              .get();
          subjectAttendance.addAll(sessionDocs.docs);
        }
        subjectReports.add(StudentSubjectReport.fromDoc(
            subject, teacherDoc, subjectAttendance));
      }
    } on Exception catch (e) {
      print("load subject report error: $e");
    }
    return subjectReports;
  }
}
