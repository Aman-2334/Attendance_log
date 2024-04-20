// ignore_for_file: use_build_context_synchronously

import 'package:attendance_log/helper.dart';
import 'package:attendance_log/models/institute.dart';
import 'package:attendance_log/provider/institute_provider.dart';
import 'package:attendance_log/provider/user_provider.dart';
import 'package:attendance_log/services/auth_service.dart';
import 'package:attendance_log/theme/theme.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);
  static const routeName = "Authentication";
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool register = false;
  bool checkedValue = false;
  bool authenticating = false;
  String? name;
  String? email;
  String? password;
  Institute? institute;
  Role? role;
  String? registrationNumber;
  late UserProvider userProvider;
  final formKey = GlobalKey<FormState>();

  void saveForm() async {
    if (formKey.currentState!.validate()) {
      if (register && checkedValue == false) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please accept Terms of Service")));
        return;
      }
      formKey.currentState!.save();
      setState(() {
        authenticating = true;
      });
      String? authenticationError;
      if (register) {
        authenticationError = await AuthService().register(
            name: name!,
            email: email!,
            password: password!,
            role: role!,
            registrationNumber: registrationNumber,
            institute: institute!,
            userProvider: userProvider);
      } else {
        authenticationError = await AuthService().login(
            email: email!,
            password: password!,
            role: role!,
            userProvider: userProvider);
      }
      setState(() {
        authenticating = false;
      });
      if (authenticationError != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(authenticationError)));
      } else {
        if (role == Role.Admin) {
          Navigator.of(context).pushReplacementNamed("adminHomepage");
        } else if (role == Role.Teacher) {
          Navigator.of(context).pushReplacementNamed("teacherHomepage");
        } else {
          Navigator.of(context).pushReplacementNamed("studentHomepage");
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      InstituteProvider constantsProvider =
          Provider.of<InstituteProvider>(context, listen: false);
      constantsProvider.loadInstitutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = AppTheme().themeData;
    userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/attendancelog_logo.png",
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 15),
                          child: Align(
                            child: register
                                ? Text(
                                    'Create an Account',
                                    style: themeData.textTheme.titleMedium,
                                  )
                                : Text(
                                    'Hey there, Welcome Back',
                                    style: themeData.textTheme.titleMedium,
                                  ),
                          ),
                        ),
                        register
                            ? Container(
                                margin: const EdgeInsets.symmetric(vertical: 7),
                                child: TextFormField(
                                  initialValue: name,
                                  enabled: !authenticating,
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
                                      labelText: "Name",
                                      prefixIcon:
                                          Icon(Icons.person_outline_rounded)),
                                  onSaved: (String? value) => name = value,
                                ),
                              )
                            : Container(),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 7),
                          child: TextFormField(
                            enabled: !authenticating,
                            initialValue: email,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This Field is Mandatory";
                              } else if (!RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+.[a-zA-Z]+")
                                  .hasMatch(value)) {
                                return "Invalid email";
                              }
                              return null;
                            },
                            maxLength: 100,
                            decoration: const InputDecoration(
                                counterText: "",
                                labelText: "Email",
                                prefixIcon: Icon(Icons.email_outlined)),
                            onSaved: (String? value) => email = value,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 7),
                          child: TextFormField(
                            initialValue: password,
                            enabled: !authenticating,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This Field is Mandatory";
                              } else if (value.length < 6 && register) {
                                return "Password must be greater than 6 characters";
                              }
                              return null;
                            },
                            maxLength: 50,
                            decoration: const InputDecoration(
                              counterText: "",
                              labelText: "Password",
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            obscureText: true,
                            onSaved: (String? value) => password = value,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 7),
                          child: DropdownButtonFormField<Role>(
                              dropdownColor: themeData.primaryColor,
                              validator: (value) {
                                if (value == null) {
                                  return "This Field is Mandatory";
                                }
                                return null;
                              },
                              value: role,
                              items: Role.values
                                  .map((Role role) => DropdownMenuItem(
                                      value: role,
                                      child: Text(
                                        role.name,
                                        style: themeData.textTheme.bodySmall,
                                      )))
                                  .toList(),
                              iconEnabledColor: themeData.primaryColorLight,
                              decoration: InputDecoration(
                                labelText: "Select Role",
                                enabled: !authenticating,
                                prefixIcon: const Icon(Icons.groups_2_outlined),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  role = value;
                                });
                              }),
                        ),
                        register && role == Role.Student
                            ? Container(
                                margin: const EdgeInsets.symmetric(vertical: 7),
                                child: TextFormField(
                                  initialValue: registrationNumber,
                                  enabled: !authenticating,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "This Field is Mandatory";
                                    } else if (value.length <= 2) {
                                      return "Invalid registration Number, Length must be greater than 2";
                                    }
                                    return null;
                                  },
                                  maxLength: 30,
                                  decoration: const InputDecoration(
                                      counterText: "",
                                      labelText: "Registration Number",
                                      prefixIcon: Icon(Icons.badge_outlined)),
                                  onSaved: (String? value) =>
                                      registrationNumber = value,
                                ),
                              )
                            : Container(),
                        register
                            ? Consumer<InstituteProvider>(
                                builder: (context, instituteProvider, child) {
                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 7),
                                    child: DropdownSearch<Institute>(
                                      items: instituteProvider.institutes,
                                      enabled: !instituteProvider
                                              .loadingInstitutes &&
                                          !authenticating,
                                      popupProps: PopupProps.modalBottomSheet(
                                        showSearchBox: true,
                                        itemBuilder:
                                            (context, item, isSelected) =>
                                                Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          child: ListTile(
                                            tileColor: Colors.transparent,
                                            title: Text(
                                              item.name,
                                              style: themeData
                                                  .textTheme.titleSmall!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w400),
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
                                              fillColor:
                                                  themeData.primaryColorDark,
                                              hintText: "Search Institute"),
                                        ),
                                        showSelectedItems: true,
                                      ),
                                      compareFn: (item1, item2) =>
                                          item1.id != item2.id,
                                      dropdownButtonProps:
                                          const DropdownButtonProps(
                                        color: Color(0xFFE3FEF7),
                                      ),
                                      itemAsString: (item) => item.name,
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        baseStyle:
                                            themeData.textTheme.bodyLarge,
                                        dropdownSearchDecoration: InputDecoration(
                                            label: Text(instituteProvider
                                                    .loadingInstitutes
                                                ? "Loading Institues please wait..."
                                                : "Select Institute"),
                                            prefixIcon: const Icon(
                                                Icons.apartment_outlined)),
                                      ),
                                      validator: (value) {
                                        if (value == null) {
                                          return "This Field is Mandatory";
                                        }
                                        return null;
                                      },
                                      onSaved: (Institute? value) {
                                        institute = value;
                                      },
                                    ),
                                  );
                                },
                              )
                            : Container(),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 20,
                          ),
                          child: register
                              ? CheckboxListTile(
                                  enabled: !authenticating,
                                  title: RichText(
                                    textAlign: TextAlign.left,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                            text:
                                                "By creating an account, you agree to our ",
                                            style:
                                                themeData.textTheme.bodySmall),
                                        WidgetSpan(
                                          child: InkWell(
                                            onTap: () {
                                              // ignore: avoid_print
                                              print('Conditions of Use');
                                            },
                                            child: Text(
                                              "Conditions of Use",
                                              style: themeData
                                                  .textTheme.bodySmall!
                                                  .copyWith(
                                                      decorationColor:
                                                          const Color(
                                                              0xFFE3FEF7),
                                                      decorationThickness: 3,
                                                      decoration: TextDecoration
                                                          .underline),
                                            ),
                                          ),
                                        ),
                                        TextSpan(
                                            text: " and ",
                                            style:
                                                themeData.textTheme.bodySmall),
                                        WidgetSpan(
                                          child: InkWell(
                                            onTap: () {
                                              // ignore: avoid_print
                                              print('Privacy Notice');
                                            },
                                            child: Text(
                                              "Privacy Notice",
                                              style: themeData
                                                  .textTheme.bodySmall!
                                                  .copyWith(
                                                      decorationColor:
                                                          const Color(
                                                              0xFFE3FEF7),
                                                      decorationThickness: 3,
                                                      decoration: TextDecoration
                                                          .underline),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  value: checkedValue,
                                  onChanged: (newValue) {
                                    setState(() {
                                      checkedValue = newValue!;
                                    });
                                  },
                                  checkColor: const Color(0xFFE3FEF7),
                                  activeColor: themeData.primaryColor,
                                  side: const BorderSide(
                                    color: Color(0xFFE3FEF7),
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                )
                              : InkWell(
                                  onTap: () {},
                                  child: Text(
                                    "Forgot your password?",
                                    style: themeData.textTheme.bodySmall,
                                  ),
                                ),
                        ),
                        !authenticating
                            ? Container(
                                height: AppTheme().buttonHeight,
                                width: double.infinity,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: TextButton(
                                  onPressed: saveForm,
                                  child: Text(
                                    register ? "Register" : "Login",
                                    style: themeData.textTheme.titleSmall,
                                  ),
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: CircularProgressIndicator(),
                              ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: register
                                    ? "Already have an account? "
                                    : "Don’t have an account yet? ",
                                style: themeData.textTheme.bodySmall,
                              ),
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      if (register) {
                                        register = false;
                                      } else {
                                        register = true;
                                      }
                                    });
                                  },
                                style: themeData.textTheme.bodySmall!
                                    .copyWith(color: themeData.primaryColor),
                                text: register ? "Login" : "Register",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
