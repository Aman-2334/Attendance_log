import 'package:attendance_log/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Teacher {
  AppUser teacher;
  List<String> subjects;

  Teacher({
    required this.teacher,
    required this.subjects,
  }) : super();

  factory Teacher.fromDoc(DocumentSnapshot doc) {
    return Teacher(
      teacher: AppUser.fromDoc(doc),
      subjects: List.from(doc["subjects"]),
    );
  }

  @override
  String toString() {
    return "Teacher Details $teacher, $subjects";
  }
}
