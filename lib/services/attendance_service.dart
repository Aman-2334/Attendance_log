import 'dart:convert';
import 'dart:io';

import 'package:attendance_log/helper.dart';
import 'package:attendance_log/models/attendance.dart';
import 'package:attendance_log/models/subject.dart';
import 'package:attendance_log/models/user.dart';
import 'package:attendance_log/services/collection_refrences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AttendanceService {
  Future<List<Attendance>> getAttendanceSession(
      {required String instituteId,
      required String courseId,
      required String date}) async {
    print("getting attendance session");
    List<Attendance> attendanceSession = [];
    try {
      QuerySnapshot sessionQuerySnapshot = await Collections()
          .attendanceSessionCollection(instituteId, courseId, date)
          .get();
      for (QueryDocumentSnapshot sessionDoc in sessionQuerySnapshot.docs) {
        attendanceSession.add(Attendance.fromDoc(sessionDoc));
      }
    } on Exception catch (e) {
      print("get session error $e");
    }
    return attendanceSession;
  }

  Future<String?> markOnlineAttendance({
    required AppUser user,
    required Subject subject,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String classCount,
    required List<File> photos,
    required Attendance? session,
  }) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      if (session == null) {
        String sessionDate = DateFormat("dd-MM-yyyy").format(date);
        await putDummyField(await FirebaseFirestore.instance
            .collection("Attendance")
            .doc(user.institute)
            .get());
        await putDummyField(await Collections()
            .attendanceCollection(
              user.institute,
              subject.code,
            )
            .doc(sessionDate)
            .get());
        DocumentReference docRef = await Collections()
            .attendanceSessionCollection(
                user.institute, subject.code, sessionDate)
            .add({
          "date": date.toString(),
          "startTime": timeOfDaytoString(startTime),
          "endTime": timeOfDaytoString(endTime),
          "classCount": classCount,
          "studentIds": [],
          "studentsMarkedManually": [],
          "studentsMarkedOnline": [],
          "imageUrls": [],
        });
        DocumentSnapshot doc = await Collections()
            .attendanceSessionCollection(
                user.institute, subject.code, sessionDate)
            .doc(docRef.id)
            .get();
        session = Attendance.fromDoc(doc);
      }

      String sessionDate = DateFormat("dd-MM-yyyy").format(session.date);
      String bucket = attendanceBucket(
          institute: user.institute,
          code: subject.code,
          sessionDate: sessionDate,
          id: session.id);
      List<String> urls = [];
      for (File photo in photos) {
        final attendanceImageRef =
            storageRef.child("$bucket/${photo.path.split('/').last}");
        await attendanceImageRef.putFile(photo);
        String url = await attendanceImageRef.getDownloadURL();
        urls.add(url);
      }
      
      
      final response = await http.post(
          Uri.parse("http://192.168.119.70:5000/process_images"),
          body: json.encode({"urls": urls}));
      print("response: $response");
      print(json.decode(response.body));
      List<String> users = ["Z2Wv7AxOJaOFeKRu4gnUVIqxLwC3"];
      session.imageUrls.addAll(urls);
      for (String user in users) {
        if (!session.studentIds.contains(user)) {
          session.studentsMarkedOnline.add(user);
          session.studentIds.add(user);
        }
      }
      await Collections()
          .attendanceSessionCollection(
              user.institute, subject.code, sessionDate)
          .doc(session.id)
          .update(session.toJson());
    } on Exception catch (e) {
      print("mark online attendance error $e");
      return "An error occured!";
    }
    return null;
  }

  Future<String?> markManualAttendance({
    required AppUser student,
    required Subject subject,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String classCount,
    required Attendance? session,
  }) async {
    try {
      if (session != null) {
        String sessionDate = DateFormat("dd-MM-yyyy").format(session.date);
        if (session.studentIds.contains(student.id)) {
          return "Student already marked present";
        }
        session.studentsMarkedManually.add(student.id);
        session.studentIds.add(student.id);
        await Collections()
            .attendanceSessionCollection(
                student.institute, subject.code, sessionDate)
            .doc(session.id)
            .update(session.toJson());
      } else {
        String sessionDate = DateFormat("dd-MM-yyyy").format(date);
        await putDummyField(await FirebaseFirestore.instance
            .collection("Attendance")
            .doc(student.institute)
            .get());
        await putDummyField(await Collections()
            .attendanceCollection(
              student.institute,
              subject.code,
            )
            .doc(sessionDate)
            .get());

        await Collections()
            .attendanceSessionCollection(
                student.institute, subject.code, sessionDate)
            .doc()
            .set({
          "date": date.toString(),
          "startTime": timeOfDaytoString(startTime),
          "endTime": timeOfDaytoString(endTime),
          "classCount": classCount,
          "studentIds": [student.id],
          "studentsMarkedManually": [student.id],
          "studentsMarkedOnline": [],
          "imageUrls": [],
        });
      }
    } on Exception catch (e) {
      print("mark manual attendance error $e");
      return "An error occured!";
    }
    return null;
  }
}
