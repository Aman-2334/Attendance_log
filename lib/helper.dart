// ignore_for_file: constant_identifier_names

import 'package:attendance_log/models/attendance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Role{
  Admin,
  Teacher,
  Student,
}

enum AttendanceType{
  Online,
  Manual,
}

String sessionFormat(Attendance session) {
    return "${DateFormat("dd-MM-yyyy").format(session.date)} ${timeOfDaytoString(session.startTime)}-${timeOfDaytoString(session.endTime)}";
  }

String timeOfDaytoString(TimeOfDay time) {
    String addLeadingZeroIfNeeded(int value) {
      if (value < 10) {
        return '0$value';
      }
      return value.toString();
    }

    final String hourLabel = addLeadingZeroIfNeeded(time.hour);
    final String minuteLabel = addLeadingZeroIfNeeded(time.minute);

    return '$hourLabel:$minuteLabel';
  }

String attendanceBucket({
  required String institute,
  required String code,
  required String sessionDate,
  required String id,
}){
  return "attendance/$institute/$code/$sessionDate/$id";
}

Future<void> putDummyField(DocumentSnapshot doc) async{
  await doc.reference.set({"dummy": "dummy"});
}