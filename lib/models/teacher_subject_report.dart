import 'package:attendance_log/models/subject.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherSubjectReport {
  String reportId;
  String subjectReference;
  Subject subject;
  int totalClass;

  TeacherSubjectReport({
    required this.reportId,
    required this.subjectReference,
    required this.subject,
    required this.totalClass,
  }) : super();

  factory TeacherSubjectReport.fromDoc(DocumentSnapshot teacherSubjectReportDoc,
      DocumentSnapshot subjectDoc) {
    return TeacherSubjectReport(
      reportId: teacherSubjectReportDoc.id,
      subjectReference: teacherSubjectReportDoc['subject_reference'] ?? '',
      subject: Subject.fromDoc(subjectDoc),
      totalClass: teacherSubjectReportDoc['totalClass'] ?? 0,
    );
  }

  factory TeacherSubjectReport.fromJson(Map<String, dynamic> json) {
    return TeacherSubjectReport(
      reportId: json['reportId'] ?? '',
      subjectReference: json['subject_reference'] ?? '',
      subject: json['subject'] ?? '',
      totalClass: json['totalClass'] ?? 0,
    );
  }

  @override
  String toString() {
    return "Subject Report $reportId $subjectReference, $subject, $totalClass";
  }
}