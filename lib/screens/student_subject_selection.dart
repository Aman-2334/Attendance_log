import 'package:attendance_log/models/subject.dart';
import 'package:attendance_log/provider/subject_provider.dart';
import 'package:attendance_log/provider/user_provider.dart';
import 'package:attendance_log/theme/theme.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubjectSelection extends StatefulWidget {
  const SubjectSelection({super.key});

  @override
  State<SubjectSelection> createState() => _SubjectSelectionState();
}

class _SubjectSelectionState extends State<SubjectSelection> {
  late SubjectProvider subjectProvider;
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      subjectProvider.loadSubject(userProvider.user!.institute);
      subjectProvider.loadUserSubject(
          userProvider.user!.institute, userProvider.user!.subjects);
    });
  }

  @override
  Widget build(BuildContext context) {
    subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    ThemeData themeData = AppTheme().themeData;
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        toolbarHeight: 100,
        title: const Text("Classroom"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          Consumer<SubjectProvider>(
            builder: (context, subjectProvider, child) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 7),
                child: DropdownSearch<Subject>(
                  items: subjectProvider.subject,
                  enabled: !subjectProvider.loadingSubject,
                  popupProps: PopupProps.modalBottomSheet(
                    showSearchBox: true,
                    itemBuilder: (context, subject, isSelected) => ListTile(
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
                    showSelectedItems: false,
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
                  onChanged: (Subject? subject) {
                    subjectProvider.addStudentSubject(subject!, userProvider);
                  },
                  onSaved: (Subject? value) {
                    // subject = value;
                  },
                ),
              );
            },
          ),
          Consumer<SubjectProvider>(
            builder: (context, subjectProvider, child) {
              return subjectProvider.loadingUserSubject
                  ? const SizedBox(
                      height: 40,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : subjectProvider.userSubject == null ||
                          subjectProvider.userSubject!.isEmpty
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
                                  "${subjectProvider.userSubject![index].name}(${subjectProvider.userSubject![index].code})",
                                  style: themeData.textTheme.titleSmall!
                                      .copyWith(fontWeight: FontWeight.w400),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                      Icons.highlight_remove_outlined),
                                  onPressed: () =>
                                      subjectProvider.removeStudentSubject(
                                          subjectProvider.userSubject![index],
                                          userProvider),
                                ),
                              ),
                          separatorBuilder: (context, index) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: const Divider(),
                              ),
                          itemCount: subjectProvider.userSubject!.length);
            },
          )
        ],
      ),
    );
  }
}
