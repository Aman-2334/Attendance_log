import 'package:attendance_log/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String id;
  String name;
  String email;
  String institute;
  String registration;
  Role role;
  List<String> subjects;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.institute,
    required this.registration,
    required this.role,
    required this.subjects,
  }) : super();

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    return AppUser(
      id: doc.id,
      name: doc['name'] ?? '',
      email: doc['email'] ?? '',
      institute: doc['institute'] ?? '',
      registration: doc['registration'] ?? '',
      role: doc['role'] == "Admin"
          ? Role.Admin
          : doc['role'] == "Teacher"
              ? Role.Teacher
              : Role.Student,
      subjects: List<String>.from(doc["subjects"] ?? [])
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      institute: json['institute'] ?? '',
      registration: json['registration'] ?? '',
      role: json['role'] == "Admin"
          ? Role.Admin
          : json['role'] == "Teacher"
              ? Role.Teacher
              : Role.Student,
      subjects: json["subjects"].toString().split("-"),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'institute': institute,
        'registration': registration,
        'role': role.name,
        'subjects': subjects.join("-"),
      };

  @override
  String toString() {
    return "User Details $id, $name, $email, $institute, $registration, $role, $subjects";
  }
}
