import 'package:attendance_log/models/teacher.dart';
import 'package:attendance_log/services/collection_refrences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherService {
  Future<List<Teacher>> getTeacher(String instituteId) async {
    List<Teacher> teachers = [];
    try {
      QuerySnapshot querySnapshots = await Collections()
          .teacherCollection()
          .where("institute", isEqualTo: instituteId)
          .get();
      print("get teacher query snapshot ${querySnapshots.docs}");
      for (QueryDocumentSnapshot doc in querySnapshots.docs) {
        teachers.add(Teacher.fromDoc(doc));
      }
    } on Exception catch (e) {
      print("load teacher error: $e");
    }
    return teachers;
  }
}
