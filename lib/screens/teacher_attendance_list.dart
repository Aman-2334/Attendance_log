import 'package:attendance_log/helper.dart';
import 'package:attendance_log/models/attendance.dart';
import 'package:attendance_log/models/subject.dart';
import 'package:attendance_log/provider/attendance_provider.dart';
import 'package:attendance_log/provider/subject_provider.dart';
import 'package:attendance_log/provider/user_provider.dart';
import 'package:attendance_log/services/attendance_service.dart';
import 'package:attendance_log/theme/theme.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TeacherAttendanceList extends StatefulWidget {
  const TeacherAttendanceList({super.key});

  @override
  State<TeacherAttendanceList> createState() => _TeacherAttendanceListState();
}

class _TeacherAttendanceListState extends State<TeacherAttendanceList> {
  Subject? subject;
  DateTime? date;
  Attendance? attendanceSession;
  bool generatingPdf = false;
  final formKey = GlobalKey<FormState>();
  late AttendanceProvider attendanceProvider;
  late UserProvider userProvider;

  void saveForm() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      setState(() {
        generatingPdf = true;
      });
      String? downloadAttendanceListError =
          await AttendanceService().downloadAttendanceList(
        user: userProvider.user!,
        subject: subject!,
        date: date!,
        session: attendanceSession!,
      );
      setState(() {
        generatingPdf = false;
      });
      if (downloadAttendanceListError != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(downloadAttendanceListError)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Attendance List generated Successfully!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    attendanceProvider =
        Provider.of<AttendanceProvider>(context, listen: false);
    ThemeData themeData = AppTheme().themeData;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          children: [
            Form(
              key: formKey,
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Consumer<SubjectProvider>(
                    builder: (context, subjectProvider, child) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 7),
                        child: DropdownSearch<Subject>(
                          items: subjectProvider.subject,
                          enabled:
                              !subjectProvider.loadingSubject || !generatingPdf,
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
                      enabled: !generatingPdf,
                      key: Key(date.toString()),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 100)),
                          lastDate: DateTime.now(),
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
                          enabled:
                              !attendanceProvider.loadingAttendanceSession ||
                                  !generatingPdf,
                          popupProps: PopupProps.modalBottomSheet(
                            emptyBuilder: (context, searchEntry) => SizedBox(
                              height: 40,
                              child: Center(
                                  child: Text(
                                searchEntry.isEmpty &&
                                        subject == null &&
                                        date == null
                                    ? "Select subject and date to view previous sessions"
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
                            });
                          },
                          onSaved: (Attendance? session) {
                            attendanceSession = session;
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                    child: Text(
                      "Absent Student Attendance List",
                      style: themeData.textTheme.bodyLarge,
                    ),
                  ),
                  generatingPdf
                      ? Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: const CircularProgressIndicator(),
                          ),
                        )
                      : TextButton.icon(
                          onPressed: saveForm,
                          icon: const Icon(
                            Icons.download_outlined,
                          ),
                          label: Text(
                            'Download',
                            style: themeData.textTheme.bodyMedium,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
