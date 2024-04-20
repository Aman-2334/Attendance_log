import 'package:attendance_log/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  AppUser student;

  Student({
    required this.student,
  }) : super();

  factory Student.fromDoc(DocumentSnapshot doc) {
    return Student(
      student: AppUser.fromDoc(doc),
    );
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      student: AppUser.fromJson(json['student']),
    );
  }

  Map<String, dynamic> toJson() => {
    "student": student.toJson(),
  };
  
  @override
  String toString() {
    return "Student Details $student";
  }
}
