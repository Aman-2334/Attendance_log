import 'package:attendance_log/models/student_subject_report.dart';
import 'package:attendance_log/models/subject.dart';
import 'package:attendance_log/models/teacher.dart';
import 'package:attendance_log/provider/user_provider.dart';
import 'package:attendance_log/services/subject_service.dart';
import 'package:flutter/material.dart';

class SubjectProvider extends ChangeNotifier {
  List<Subject> subject = [];
  List<Subject>? userSubject;
  List<StudentSubjectReport> subjectReports = [];
  bool loadingSubject = false;
  bool loadingUserSubject = false;

  Future<void> loadSubject(String instituteId) async {
    print("Loading Subject");
    loadingSubject = true;
    notifyListeners();
    subject = await SubjectService().loadSubject(instituteId);
    loadingSubject = false;
    notifyListeners();
  }

  Future<void> loadUserSubject(
      String instituteId, List<String> subjects) async {
    print("Loading user Subject");
    // if(userSubject != null) return;
    loadingUserSubject = true;
    userSubject =
        await SubjectService().loadSubjectsById(instituteId, subjects);
    print("userSubject: $userSubject");
    loadingUserSubject = false;
    notifyListeners();
  }

  Future<void> loadSubjectsById(
      String instituteId, List<String> subjects) async {
    print("Loading Subject by id $subjects");
    loadingSubject = true;
    notifyListeners();
    subject = await SubjectService().loadSubjectsById(instituteId, subjects);
    loadingSubject = false;
    notifyListeners();
  }

  Future<String?> addStudentSubject(
      Subject subject, UserProvider userProvider) async {
    if (userSubject!.contains(subject)) return "Subject Already Exists!";
    userSubject!.add(subject);
    userProvider.user!.subjects.add(subject.code);
    userProvider.setUser();
    String? addStudentSubjectError = await SubjectService()
        .addStudentSubject(subject: subject, userProvider: userProvider);

    notifyListeners();
    return addStudentSubjectError;
  }

  Future<String?> removeStudentSubject(
      Subject subject, UserProvider userProvider) async {
    userSubject!.remove(subject);
    userProvider.user!.subjects.remove(subject.code);
    userProvider.setUser();
    String? addStudentSubjectError = await SubjectService()
        .removeStudentSubject(subject: subject, userProvider: userProvider);

    notifyListeners();
    return addStudentSubjectError;
  }

  Future<String?> addSubject(
      {required UserProvider userProvider,
      required String subjectCode,
      required String subjectName,
      required Teacher subjectTeacher}) async {
    String? addSubjectError = await SubjectService().addSubject(
        instituteId: userProvider.user!.institute,
        subjectCode: subjectCode,
        subjectName: subjectName,
        subjectTeacher: subjectTeacher);
    if (addSubjectError == null) {
      int overwriteSubjectIndex =
          subject.indexWhere((element) => element.code == subjectCode);
      subjectTeacher.subjects.add(subjectCode);
      if (overwriteSubjectIndex != -1) {
        subject[overwriteSubjectIndex].name = subjectName;
      } else {
        subject.add(Subject(
            id: subjectCode,
            name: subjectName,
            code: subjectCode,
            teacherReference: subjectTeacher.teacher.id));
      }
    }
    notifyListeners();
    return addSubjectError;
  }
}
