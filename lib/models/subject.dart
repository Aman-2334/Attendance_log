import 'package:cloud_firestore/cloud_firestore.dart';

class Subject {
  String id;
  String name;
  String code;
  String teacherReference;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.teacherReference,
  }) : super();

  factory Subject.fromDoc(DocumentSnapshot doc) {
    return Subject(
      id: doc.id,
      name: doc['name'] ?? '',
      code: doc['code'] ?? '',
      teacherReference: doc['teacher_reference'] ?? '',
    );
  }

  @override
  String toString() {
    return "Subject Details $id, $name, $code $teacherReference";
  }
}
