import 'package:attendance_log/helper.dart';
import 'package:attendance_log/models/attendance.dart';
import 'package:attendance_log/models/student_subject_report.dart';
import 'package:attendance_log/provider/user_provider.dart';
import 'package:attendance_log/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AttendanceModalBottomSheet extends StatelessWidget {
  StudentSubjectReport subjectReport;
  late UserProvider userProvider;
  AttendanceModalBottomSheet({required this.subjectReport, super.key});

  Widget attendanceListTile(Attendance attendance, int index) {
    int totalPresent = attendance.studentIds.contains(userProvider.user!.id)
        ? attendance.classCount
        : 0;
    return ListTile(
      title: Text(sessionFormat(attendance)),
      subtitle: Text(
          "Total Classes: ${attendance.classCount} | Present: $totalPresent"),
    );
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    ThemeData themeData = AppTheme().themeData;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "${subjectReport.subject.name} (${subjectReport.subject.code})",
                  style: themeData.textTheme.titleSmall!
                      .copyWith(overflow: TextOverflow.ellipsis),
                ),
              ),
              // OutlinedButton.icon(
              //   onPressed: () => {},
              //   icon: const Icon(
              //     Icons.sync_outlined,
              //   ),
              //   label: Text(
              //     "Sync",
              //     style: themeData.textTheme.titleSmall,
              //   ),
              // ),
            ],
          ),
        ),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) =>
              attendanceListTile(subjectReport.attendanceReport[index], index),
          separatorBuilder: (context, index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: const Divider(),
          ),
          itemCount: subjectReport.attendanceReport.length,
        ),
      ],
    );
  }
}
