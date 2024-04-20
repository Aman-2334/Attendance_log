import 'package:cloud_firestore/cloud_firestore.dart';

class Collections {
  CollectionReference instituteCollection() =>
      FirebaseFirestore.instance.collection('Institute');
  CollectionReference studentMappingCollection() =>
      FirebaseFirestore.instance.collection('ID_Mapper');
  CollectionReference subjectCollection(String instituteId) =>
      instituteCollection().doc(instituteId).collection('Subject');
  CollectionReference adminCollection() =>
      FirebaseFirestore.instance.collection('Admin');
  CollectionReference teacherCollection() =>
      FirebaseFirestore.instance.collection('Teacher');
  CollectionReference studentCollection() =>
      FirebaseFirestore.instance.collection('Student');
  CollectionReference studentSubjectCollection(String studentId) =>
      studentCollection().doc(studentId).collection('Subject');
  CollectionReference teacherSubjectCollection(String teacherId) =>
      studentCollection().doc(teacherId).collection('Subject');
  CollectionReference attendanceCollection(
          String instituteId, String courseId) =>
      FirebaseFirestore.instance
          .collection('Attendance')
          .doc(instituteId)
          .collection(courseId);
  CollectionReference attendanceSessionCollection(
          String instituteId, String courseId, String date) =>
      attendanceCollection(instituteId, courseId)
          .doc(date)
          .collection('Session');
}
