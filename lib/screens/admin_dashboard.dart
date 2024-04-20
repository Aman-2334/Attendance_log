// ignore_for_file: use_build_context_synchronously

import 'package:attendance_log/models/teacher.dart';
import 'package:attendance_log/provider/subject_provider.dart';
import 'package:attendance_log/provider/teacher_provider.dart';
import 'package:attendance_log/provider/user_provider.dart';
import 'package:attendance_log/theme/theme.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? subjectCode;
  String? subjectName;
  Teacher? subjectTeacher;
  bool addingSubject = false;
  List<String> managementTiles = ["Add Subject", "View Subjects"];
  final formKey = GlobalKey<FormState>();
  late UserProvider userProvider;
  late SubjectProvider subjectProvider;

  void saveForm() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      setState(() {
        addingSubject = true;
      });
      String? addSubjectError;
      addSubjectError = await subjectProvider.addSubject(
          subjectCode: subjectCode!,
          subjectName: subjectName!,
          subjectTeacher: subjectTeacher!,
          userProvider: userProvider);
      setState(() {
        addingSubject = false;
      });
      if (addSubjectError != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(addSubjectError)));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Subject Added")));
      }
    }
  }

  Widget expandablePanel(String headerTitle, ThemeData themeData) {
    return ExpandablePanel(
        theme: const ExpandableThemeData(
          hasIcon: false,
          tapHeaderToExpand: true,
        ),
        header: ListTile(
          title: Text(headerTitle),
          trailing: const Icon(Icons.arrow_drop_down_rounded),
        ),
        collapsed: Container(),
        expanded: Container(
            margin: const EdgeInsets.only(top: 7),
            child: headerTitle == "Add Subject"
                ? addSubjectExpandable(themeData)
                : headerTitle == "View Subjects"
                    ? viewSubjectsExpandable(themeData)
                    : Container()));
  }

  Widget addSubjectExpandable(ThemeData themeData) {
    return Container(
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 7),
              child: TextFormField(
                initialValue: subjectCode,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "This Field is Mandatory";
                  } else if (value.length <= 2) {
                    return "Invalid name, Length must be greater than 2";
                  }
                  return null;
                },
                maxLength: 20,
                decoration: const InputDecoration(
                    counterText: "",
                    labelText: "Subject Code",
                    prefixIcon: Icon(Icons.bookmark_outline)),
                onSaved: (String? value) => subjectCode = value,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 7),
              child: TextFormField(
                initialValue: subjectName,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "This Field is Mandatory";
                  } else if (value.length <= 2) {
                    return "Invalid name, Length must be greater than 2";
                  }
                  return null;
                },
                maxLength: 50,
                decoration: const InputDecoration(
                    counterText: "",
                    labelText: "Subject Name",
                    prefixIcon: Icon(Icons.book_outlined)),
                onSaved: (String? value) => subjectName = value,
              ),
            ),
            Consumer<TeacherProvider>(
              builder: (context, teacherProvider, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 7),
                  child: DropdownSearch<Teacher>(
                    items: teacherProvider.teacher,
                    enabled: !teacherProvider.loadingTeacher,
                    popupProps: PopupProps.modalBottomSheet(
                      showSearchBox: true,
                      disabledItemFn: (teacher) => teacher.subjects.length >= 10,
                      itemBuilder: (context, item, isSelected) => Container(
                        // margin: const EdgeInsets.symmetric(
                        //     vertical: 5, horizontal: 5),
                        child: ListTile(
                          tileColor: Colors.transparent,
                          title: Text(
                            item.teacher.name,
                            style: themeData.textTheme.titleSmall!
                                .copyWith(fontWeight: FontWeight.w400),
                          ),
                          subtitle: Text(
                            item.teacher.email,
                            style: themeData.textTheme.bodySmall,
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_outline,
                                  color: Color(0xFFE3FEF7),
                                )
                              : null,
                        ),
                      ),
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: themeData.primaryColorDark,
                            hintText: "Search Teacher by email or name"),
                      ),
                      showSelectedItems: true,
                    ),
                    compareFn: (item1, item2) =>
                        item1.teacher.email == item2.teacher.email,
                    dropdownButtonProps: const DropdownButtonProps(
                      color: Color(0xFFE3FEF7),
                    ),
                    itemAsString: (item) => item.teacher.name,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      baseStyle: themeData.textTheme.bodyLarge,
                      dropdownSearchDecoration: InputDecoration(
                          label: Text(teacherProvider.loadingTeacher
                              ? "Loading Teachers please wait..."
                              : "Assign Teacher"),
                          prefixIcon: const Icon(Icons.apartment_outlined)),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return "This Field is Mandatory";
                      }
                      return null;
                    },
                    onSaved: (Teacher? value) {
                      subjectTeacher = value;
                    },
                  ),
                );
              },
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.end,
              children: [
                addingSubject
                    ? Container(
                        padding: const EdgeInsets.all(10),
                        child: const CircularProgressIndicator())
                    : TextButton.icon(
                        onPressed: saveForm,
                        icon: const Icon(Icons.add_circle_outline),
                        label: Text(
                          "Add",
                          style: themeData.textTheme.bodySmall,
                        ),
                      ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget viewSubjectsExpandable(ThemeData themeData) {
    return Consumer<SubjectProvider>(
      builder: (context, subjectProvider, child) {
        return subjectProvider.loadingSubject
            ? const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator()),
              )
            : subjectProvider.subject.isEmpty
                ? SizedBox(
                    height: 40,
                    child: Center(
                        child: Text(
                      "Add Subjects to View them here!",
                      style: themeData.textTheme.bodySmall,
                    )),
                  )
                : ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) => ListTile(
                          tileColor: Colors.transparent,
                          title: Text(
                            "${subjectProvider.subject[index].name}(${subjectProvider.subject[index].code})",
                            style: themeData.textTheme.titleSmall!
                                .copyWith(fontWeight: FontWeight.w400),
                          ),
                        ),
                    separatorBuilder: (context, index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: const Divider(),
                        ),
                    itemCount: subjectProvider.subject.length);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      TeacherProvider teacherProvider =
          Provider.of<TeacherProvider>(context, listen: false);
      teacherProvider.loadTeacher(userProvider.user!.institute);
      subjectProvider.loadSubject(userProvider.user!.institute);
    });
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    ThemeData themeData = AppTheme().themeData;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text("Institute Management"),
      ),
      body: SafeArea(
        child: ListView.separated(
          itemCount: managementTiles.length,
          itemBuilder: (ctx, i) =>
              expandablePanel(managementTiles[i], themeData),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          separatorBuilder: (context, index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: const Divider(),
          ),
        ),
      ),
    );
  }
}
