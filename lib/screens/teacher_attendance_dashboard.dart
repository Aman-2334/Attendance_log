// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:attendance_log/helper.dart';
import 'package:attendance_log/models/attendance.dart';
import 'package:attendance_log/models/student.dart';
import 'package:attendance_log/models/subject.dart';
import 'package:attendance_log/provider/attendance_provider.dart';
import 'package:attendance_log/provider/subject_provider.dart';
import 'package:attendance_log/provider/user_provider.dart';
import 'package:attendance_log/screens/qr_code_scanner.dart';
import 'package:attendance_log/services/attendance_service.dart';
import 'package:attendance_log/theme/theme.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:attendance_log/screens/teacher_online_attendance.dart';

class TeacherAttendanceDashboard extends StatefulWidget {
  const TeacherAttendanceDashboard({super.key});

  @override
  State<TeacherAttendanceDashboard> createState() =>
      _TeacherAttendanceDashboardState();
}

class _TeacherAttendanceDashboardState
    extends State<TeacherAttendanceDashboard> {
  Student? student;
  Subject? subject;
  DateTime? date;
  String? classCount;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Attendance? attendanceSession;
  Attendance? clashingSession;
  bool markingAttendance = false;
  bool sessionSelected = false;
  AttendanceType attendanceType = AttendanceType.Online;
  final formKey = GlobalKey<FormState>();
  late AttendanceProvider attendanceProvider;
  late UserProvider userProvider;
  final List<File> photos = [];

  void checkForSessions(Attendance session) {
    int sessionStartTime =
        session.startTime.hour * 100 + session.startTime.minute;
    int sessionEndTime = session.endTime.hour * 100 + session.endTime.minute;
    int slotStartTime = startTime!.hour * 100 + startTime!.minute;
    int slotEndTime = endTime!.hour * 100 + endTime!.minute;
    if ((sessionStartTime <= slotStartTime &&
            slotStartTime <= sessionEndTime) ||
        sessionStartTime <= slotEndTime && slotEndTime <= sessionEndTime) {
      clashingSession = session;
    }
  }

  void saveForm() async {
    if (formKey.currentState!.validate()) {
      if (!sessionSelected) {
        for (Attendance session in attendanceProvider.attendanceSession!) {
          checkForSessions(session);
        }
      }
      if (attendanceType == AttendanceType.Online && photos.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("No Image Selected!")));
        return;
      }
      if (clashingSession != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Current Session clashing with ${sessionFormat(clashingSession!)}")));
        return;
      }
      formKey.currentState!.save();
      setState(() {
        markingAttendance = true;
      });
      String? attendanceError = attendanceType == AttendanceType.Manual
          ? await AttendanceService().markManualAttendance(
              date: date!,
              startTime: startTime!,
              endTime: endTime!,
              classCount: classCount!,
              student: student!.student,
              subject: subject!,
              session: attendanceSession,
            )
          : await AttendanceService().markOnlineAttendance(
              date: date!,
              startTime: startTime!,
              endTime: endTime!,
              classCount: classCount!,
              user: userProvider.user!,
              subject: subject!,
              photos: photos,
              session: attendanceSession,
            );
      setState(() {
        markingAttendance = false;
      });
      if (attendanceError != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(attendanceError)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Attendance Marked Successfully!")));
      }
    }
  }

  void addImage(File image) {
    photos.add(image);
  }

  void getStudent(Student student) {
    setState(() {
      this.student = student;
    });
  }

  @override
  Widget build(BuildContext context) {
    attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    ThemeData themeData = AppTheme().themeData;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                      onPressed: () => setState(() {
                            attendanceType = AttendanceType.Online;
                          }),
                      style: themeData.outlinedButtonTheme.style!.copyWith(
                        backgroundColor: attendanceType == AttendanceType.Online
                            ? MaterialStateProperty.all(themeData.primaryColor)
                            : null,
                      ),
                      child: Text(
                        "Online Attendance",
                        style: themeData.textTheme.bodySmall,
                      )),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: OutlinedButton(
                      onPressed: () => setState(() {
                            attendanceType = AttendanceType.Manual;
                          }),
                      style: themeData.outlinedButtonTheme.style!.copyWith(
                        backgroundColor: attendanceType == AttendanceType.Manual
                            ? MaterialStateProperty.all(themeData.primaryColor)
                            : null,
                      ),
                      child: Text(
                        "Manual Attendance",
                        style: themeData.textTheme.bodySmall,
                      )),
                ),
              ],
            ),
          ),
          attendanceType == AttendanceType.Online
              ? OnlineAttendance(
                  photos: photos,
                  addImage: addImage,
                )
              : Container(),
          attendanceType == AttendanceType.Manual
              ? Container(
                  height: AppTheme().buttonHeight,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: TextButton.icon(
                    onPressed: markingAttendance
                        ? () {}
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => QRCodeScanner(
                                  getStudent: getStudent,
                                ),
                              ),
                            ),
                    icon: const Icon(
                      Icons.qr_code_2_outlined,
                    ),
                    label: Text(
                      'Scan Student ID',
                      style: themeData.textTheme.titleSmall,
                    ),
                  ),
                )
              : Container(),
          Form(
            key: formKey,
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                attendanceType == AttendanceType.Manual
                    ? Container(
                        margin: const EdgeInsets.symmetric(vertical: 7),
                        child: TextFormField(
                          key: Key(student.toString()),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "This Field is Mandatory";
                            }
                            return null;
                          },
                          enabled: !markingAttendance,
                          decoration: const InputDecoration(
                              labelText: "Student Name",
                              hintText: "Scan Student ID to fill this field"),
                          readOnly: true,
                          initialValue: student?.student.name,
                          onSaved: (String? value) {},
                        ),
                      )
                    : Container(),
                Consumer<SubjectProvider>(
                  builder: (context, subjectProvider, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 7),
                      child: DropdownSearch<Subject>(
                        items: subjectProvider.subject,
                        enabled: !subjectProvider.loadingSubject ||
                            !markingAttendance,
                        popupProps: PopupProps.modalBottomSheet(
                          showSearchBox: true,
                          itemBuilder: (context, subject, isSelected) =>
                              ListTile(
                            tileColor: Colors.transparent,
                            title: Text(
                              "${subject.code} ${subject.name}",
                              style: themeData.textTheme.titleSmall!
                                  .copyWith(fontWeight: FontWeight.w400),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle_outline,
                                    color: Color(0xFFE3FEF7),
                                  )
                                : null,
                          ),
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: themeData.primaryColorDark,
                                hintText: "Search Subject by name or code"),
                          ),
                          showSelectedItems: true,
                        ),
                        compareFn: (subject1, subject2) =>
                            subject1.code == subject2.code,
                        dropdownButtonProps: const DropdownButtonProps(
                          color: Color(0xFFE3FEF7),
                        ),
                        itemAsString: (subject) => subject.name,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          baseStyle: themeData.textTheme.bodyLarge,
                          dropdownSearchDecoration: InputDecoration(
                            label: Text(subjectProvider.loadingSubject
                                ? "Loading Subjects please wait..."
                                : "Subject"),
                          ),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return "This Field is Mandatory";
                          }
                          return null;
                        },
                        onChanged: (Subject? value) {
                          subject = value;
                          if (date != null) {
                            attendanceProvider.loadAttendanceSession(
                                instituteId: userProvider.user!.institute,
                                courseId: subject!.code,
                                date: date!);
                          }
                        },
                        onSaved: (Subject? value) {
                          subject = value;
                        },
                      ),
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 7),
                  child: TextFormField(
                    enabled: !markingAttendance,
                    key: Key(date.toString()),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 200)),
                        lastDate: DateTime(2099),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          date = pickedDate;
                          if (subject != null) {
                            attendanceProvider.loadAttendanceSession(
                                instituteId: userProvider.user!.institute,
                                courseId: subject!.code,
                                date: date!);
                          }
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This Field is Mandatory";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Date",
                    ),
                    readOnly: true,
                    initialValue: date == null
                        ? null
                        : DateFormat("dd-MM-yyyy").format(date!),
                    onSaved: (String? value) {},
                  ),
                ),
                Consumer<AttendanceProvider>(
                  builder: (context, attendanceProvider, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 7),
                      child: DropdownSearch<Attendance>(
                        items: attendanceProvider.attendanceSession ?? [],
                        enabled: !attendanceProvider.loadingAttendanceSession ||
                            !markingAttendance,
                        popupProps: PopupProps.modalBottomSheet(
                          emptyBuilder: (context, searchEntry) => SizedBox(
                            height: 40,
                            child: Center(
                                child: Text(
                              searchEntry.isEmpty &&
                                      subject == null &&
                                      date == null
                                  ? "Select subject and date to view previous session"
                                  : "No previous sessions found!",
                              style: themeData.textTheme.bodySmall,
                            )),
                          ),
                          showSearchBox: true,
                          itemBuilder: (context, session, isSelected) =>
                              ListTile(
                            tileColor: Colors.transparent,
                            title: Text(
                              sessionFormat(session),
                              style: themeData.textTheme.titleSmall!
                                  .copyWith(fontWeight: FontWeight.w400),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle_outline,
                                    color: Color(0xFFE3FEF7),
                                  )
                                : null,
                          ),
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: themeData.primaryColorDark,
                                hintText: "Search Session"),
                          ),
                          showSelectedItems: true,
                        ),
                        compareFn: (session1, session2) =>
                            session1.id == session2.id,
                        dropdownButtonProps: const DropdownButtonProps(
                          color: Color(0xFFE3FEF7),
                        ),
                        itemAsString: (session) => sessionFormat(session),
                        selectedItem: attendanceSession,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          baseStyle: themeData.textTheme.bodyLarge,
                          dropdownSearchDecoration: InputDecoration(
                              label: Text(attendanceProvider
                                      .loadingAttendanceSession
                                  ? "Loading Attendance Session please wait..."
                                  : "Attendance Session"),
                              prefixIcon: attendanceSession != null
                                  ? IconButton(
                                      onPressed: () {
                                        setState(() {
                                          sessionSelected = false;
                                          attendanceSession = null;
                                        });
                                      },
                                      icon: const Icon(
                                          Icons.highlight_remove_outlined))
                                  : null),
                        ),
                        onChanged: (Attendance? session) {
                          setState(() {
                            attendanceSession = session;
                            sessionSelected = true;
                            clashingSession = null;
                            startTime = session!.startTime;
                            endTime = session.endTime;
                            classCount = session.classCount.toString();
                          });
                        },
                        onSaved: (Attendance? session) {
                          attendanceSession = session;
                        },
                      ),
                    );
                  },
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                  child: Text(
                    "Select Class Slot",
                    style: themeData.textTheme.bodySmall,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          enabled: !markingAttendance && !sessionSelected,
                          key: Key(startTime.toString()),
                          onTap: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (BuildContext context, Widget? child) {
                                  return MediaQuery(
                                    data: MediaQuery.of(context)
                                        .copyWith(alwaysUse24HourFormat: true),
                                    child: child!,
                                  );
                                });
                            if (pickedTime != null && pickedTime != startTime) {
                              setState(() {
                                startTime = pickedTime;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "This Field is Mandatory";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: "Start Time",
                          ),
                          readOnly: true,
                          initialValue: startTime == null
                              ? null
                              : timeOfDaytoString(startTime!),
                          onSaved: (String? value) {},
                        ),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Expanded(
                        child: TextFormField(
                          enabled: !markingAttendance && !sessionSelected,
                          key: Key(endTime.toString()),
                          onTap: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (BuildContext context, Widget? child) {
                                  return MediaQuery(
                                    data: MediaQuery.of(context)
                                        .copyWith(alwaysUse24HourFormat: true),
                                    child: child!,
                                  );
                                });
                            if (pickedTime != null && pickedTime != endTime) {
                              setState(() {
                                endTime = pickedTime;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "This Field is Mandatory";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: "End Time",
                          ),
                          readOnly: true,
                          initialValue: endTime == null
                              ? null
                              : timeOfDaytoString(endTime!),
                          onSaved: (String? value) {},
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 7),
                  child: TextFormField(
                    key: Key(classCount.toString()),
                    enabled: !markingAttendance && !sessionSelected,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This Field is Mandatory";
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return "Only numeric values are allowed";
                      } else if (int.parse(value) > 10) {
                        return "Maximum allowed value is 10";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Class Count",
                      hintText: "Maximum allowed value is 10",
                    ),
                    initialValue: classCount,
                    keyboardType: TextInputType.number,
                    onSaved: (String? value) {
                      classCount = value;
                    },
                  ),
                ),
              ],
            ),
          ),
          markingAttendance
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: const CircularProgressIndicator(),
                  ),
                )
              : Container(
                  height: AppTheme().buttonHeight,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: TextButton.icon(
                    onPressed: saveForm,
                    icon: const Icon(
                      Icons.checklist_rtl_outlined,
                    ),
                    label: Text(
                      'Mark Attendance',
                      style: themeData.textTheme.titleSmall,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
