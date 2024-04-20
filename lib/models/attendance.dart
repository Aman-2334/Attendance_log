import 'package:attendance_log/helper.dart';
import 'package:attendance_log/models/subject.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Attendance {
  String id;
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  int classCount;
  List<String> studentIds;
  List<String> studentsMarkedManually;
  List<String> studentsMarkedOnline;
  List<String> imageUrls;

  Attendance(
      {required this.id,
      required this.date,
      required this.startTime,
      required this.endTime,
      required this.classCount,
      required this.studentIds,
      required this.studentsMarkedManually,
      required this.studentsMarkedOnline,
      required this.imageUrls})
      : super();

  factory Attendance.fromDoc(DocumentSnapshot doc) {
    return Attendance(
      id: doc.id,
      date: DateTime.parse(doc['date']),
      startTime: TimeOfDay(
          hour: int.parse(doc['startTime'].split(":")[0]),
          minute: int.parse(doc['startTime'].split(":")[1])),
      endTime: TimeOfDay(
          hour: int.parse(doc['endTime'].split(":")[0]),
          minute: int.parse(doc['endTime'].split(":")[1])),
      classCount: int.parse(doc['classCount']),
      studentIds: List<String>.from(doc['studentIds']),
      studentsMarkedManually: List<String>.from(doc['studentsMarkedManually']),
      studentsMarkedOnline: List<String>.from(doc['studentsMarkedOnline']),
      imageUrls: List<String>.from(doc['imageUrls']),
    );
  }

  Map<String, dynamic> toJson() => {
        "date": date.toString(),
        "startTime": timeOfDaytoString(startTime),
        "endTime": timeOfDaytoString(endTime),
        "classCount": classCount.toString(),
        "studentIds": studentIds,
        "studentsMarkedManually": studentsMarkedManually,
        "studentsMarkedOnline": studentsMarkedOnline,
        "imageUrls": imageUrls,
      };

  @override
  String toString() {
    return "attendance $id $date, $startTime, $endTime, $classCount, $studentIds, $studentsMarkedManually, $studentsMarkedOnline, $imageUrls";
  }
}

class AttendanceSummary{
  final Subject subject;
  final int totalClass;
  final int totalPresent;

  AttendanceSummary({
    required this.subject,
    required this.totalClass,
    required this.totalPresent,
  });
}
