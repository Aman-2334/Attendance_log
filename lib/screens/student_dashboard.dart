import 'package:attendance_log/models/attendance.dart';
import 'package:attendance_log/models/student_subject_report.dart';
import 'package:attendance_log/provider/student_provider.dart';
import 'package:attendance_log/provider/subject_provider.dart';
import 'package:attendance_log/provider/user_provider.dart';
import 'package:attendance_log/theme/theme.dart';
import 'package:attendance_log/widgets/attendance_modal_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

late StateSetter radialCenterTextStateSetter;
String radialCenterText = "Attendance Overview";

class Classroom extends StatefulWidget {
  const Classroom({super.key});

  @override
  State<Classroom> createState() => _ClassroomState();
}

class _ClassroomState extends State<Classroom> {
  late StudentProvider studentProvider;
  late SubjectProvider subjectProvider;
  late UserProvider userProvider;

  Widget subjectListTile(StudentSubjectReport subjectReport,
      AttendanceSummary attendanceSummary, int index, ThemeData themeData) {
    return ListTile(
      onTap: () => showModalBottomSheet(
        context: context,
        builder: (context) => AttendanceModalBottomSheet(
          subjectReport: subjectReport,
        ),
      ),
      title: Text(
        "${subjectReport.subject.name} (${subjectReport.subject.code})",
      ),
      subtitle: Text(
        "Professor: ${subjectReport.teacher.teacher.name} \n"
        "Classes Present: ${attendanceSummary.totalPresent} | Total Classes: ${attendanceSummary.totalClass}",
      ),
      isThreeLine: true,
      trailing: Text(
        attendanceSummary.totalClass == 0
            ? "0.0%"
            : "${((attendanceSummary.totalPresent / attendanceSummary.totalClass) * 100).toStringAsFixed(1)}%",
      ),
    );
  }

  List<Color> colors = const <Color>[
    Color(0xFFE178C5),
    Color(0xFFFF8E8F),
    Color(0xFFC5EBAA),
    Color(0xFF7BD3EA),
    Color(0xFFFFFDCB),
    Color(0xFFA5DD9B),
    Color(0xFF7743DB),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      studentProvider.getStudentReport(subjectProvider, userProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = AppTheme().themeData;
    subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    studentProvider = Provider.of<StudentProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text("Classroom"),
      ),
      body:
          Consumer<StudentProvider>(builder: (context, studentProvider, child) {
        if (!studentProvider.loadingStudentSubjectReport) {
          if (studentProvider.studentSubjectReport == null ||
              studentProvider.studentSubjectReport!.isEmpty) {
            return Center(
              child: Center(
                child: Text(
                  "No Subjects Added",
                  style: themeData.textTheme.bodySmall,
                ),
              ),
            );
          }
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  SfCircularChart(
                    key: GlobalKey(),
                    annotations: const [
                      CircularChartAnnotation(widget: RadialCenterText())
                    ],
                    series: <RadialBarSeries<AttendanceSummary, String>>[
                      RadialBarSeries<AttendanceSummary, String>(
                          onPointTap: (ChartPointDetails chartPointDetails) {
                            int subjectIndex = chartPointDetails.pointIndex!;
                            AttendanceSummary attendanceSummary =
                                studentProvider.attendanceSummary[subjectIndex];
                            radialCenterTextStateSetter(() {
                              radialCenterText =
                                  "Present: ${attendanceSummary.totalPresent} \nClasses: ${attendanceSummary.totalClass}";
                            });
                          },
                          maximumValue: 100,
                          dataLabelSettings: const DataLabelSettings(
                              isVisible: false,
                              textStyle: TextStyle(fontSize: 10.0)),
                          dataSource: studentProvider.attendanceSummary,
                          cornerStyle: CornerStyle.bothCurve,
                          gap: '5%',
                          radius: '100%',
                          innerRadius: '50%',
                          xValueMapper: (AttendanceSummary data, _) =>
                              data.subject.name,
                          yValueMapper: (AttendanceSummary data, _) =>
                              (data.totalPresent / data.totalClass) * 100,
                          pointRadiusMapper: (AttendanceSummary data, _) =>
                              data.subject.code,
                          pointColorMapper: (AttendanceSummary data, i) =>
                              colors[i],
                          dataLabelMapper: (AttendanceSummary data, _) =>
                              data.subject.name)
                    ],
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      builder: (data, point, series, pointIndex, seriesIndex) {
                        return Container(
                          padding: const EdgeInsets.all(10),
                          color: AppTheme().bottomNavbarColor,
                          child: Text(
                            data.subject.name,
                            style: themeData.textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: studentProvider.studentSubjectReport!.length,
                    itemBuilder: (ctx, i) => subjectListTile(
                        studentProvider.studentSubjectReport![i],
                        studentProvider.attendanceSummary[i],
                        i,
                        themeData),
                    separatorBuilder: (context, index) => Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: const Divider(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      }),
    );
  }
}

class RadialCenterText extends StatefulWidget {
  const RadialCenterText({super.key});

  @override
  State<RadialCenterText> createState() => _RadialCenterTextState();
}

class _RadialCenterTextState extends State<RadialCenterText> {
  @override
  void initState() {
    radialCenterTextStateSetter = setState;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = AppTheme().themeData;
    return Text(
      radialCenterText,
      style: themeData.textTheme.bodySmall,
    );
  }
}
