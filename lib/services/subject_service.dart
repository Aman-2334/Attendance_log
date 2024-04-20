import 'package:attendance_log/models/subject.dart';
import 'package:attendance_log/models/teacher.dart';
import 'package:attendance_log/provider/user_provider.dart';
import 'package:attendance_log/services/collection_refrences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectService {
  Future<String?> addSubject(
      {required String instituteId,
      required String subjectCode,
      required String subjectName,
      required Teacher subjectTeacher}) async {
    try {
      DocumentSnapshot subjectDoc = await Collections()
          .subjectCollection(instituteId)
          .doc(subjectCode)
          .get();
      if (subjectDoc.exists) return "Subject $subjectCode already exists!";

      FirebaseFirestore.instance.runTransaction<void>(
        (transaction) {
          DocumentReference subjectDocumentReference =
              Collections().subjectCollection(instituteId).doc(subjectCode);
          DocumentReference teacherDocumentReference =
              Collections().teacherCollection().doc(subjectTeacher.teacher.id);

          transaction.set(subjectDocumentReference, {
            "name": subjectName,
            "code": subjectCode,
            "teacher_reference": subjectTeacher.teacher.id
          });
          transaction.update(
              teacherDocumentReference, {"subjects": subjectTeacher.subjects});

          return Future(() => null);
        },
      );
    } on Exception catch (e) {
      print("adding subject error: $e");
      return "Error Adding Subject!";
    }
    return null;
  }

  Future<String?> addStudentSubject(
      {required Subject subject, required UserProvider userProvider}) async {
    try {
      await Collections()
          .studentCollection()
          .doc(userProvider.user!.id)
          .update({"subjects": userProvider.user!.subjects});
    } on Exception catch (e) {
      print("adding student subject error: $e");
      return "Error Adding Subject!";
    }
    return null;
  }

  Future<String?> removeStudentSubject(
      {required Subject subject, required UserProvider userProvider}) async {
    try {
      await Collections()
          .studentCollection()
          .doc(userProvider.user!.id)
          .update({"subjects": userProvider.user!.subjects});
    } on Exception catch (e) {
      print("removing student subject error: $e");
      return "Error Adding Subject!";
    }
    return null;
  }

  Future<List<Subject>> loadSubject(String instituteId) async {
    List<Subject> subjects = [];
    try {
      QuerySnapshot querySnapshots =
          await Collections().subjectCollection(instituteId).get();
      print(querySnapshots.docs);
      for (QueryDocumentSnapshot doc in querySnapshots.docs) {
        subjects.add(Subject.fromDoc(doc));
      }
    } on Exception catch (e) {
      print("load subject error: $e");
    }
    return subjects;
  }

  Future<List<Subject>> loadSubjectsById(
      String instituteId, List<String> subjectsList) async {
    List<Subject> subjects = [];
    // print("subject list size ${subjectsList.length}");
    try {
      for (String subjectCode in subjectsList) {
        DocumentSnapshot doc = await Collections()
            .subjectCollection(instituteId)
            .doc(subjectCode)
            .get();
        subjects.add(Subject.fromDoc(doc));
      }
      // QuerySnapshot querySnapshots = await Collections()
      //     .subjectCollection(instituteId)
      //     .where(FieldPath.documentId, whereIn: subjectsList)
      //     .get();
      // print(querySnapshots.docs);
      // for (QueryDocumentSnapshot doc in querySnapshots.docs) {
      //   subjects.add(Subject.fromDoc(doc));
      // }
    } on Exception catch (e) {
      print("load subject by id error: $e");
    }
    return subjects;
  }
}
