import 'dart:convert';

import 'package:attendance_log/models/student.dart';
import 'package:attendance_log/provider/user_provider.dart';
import 'package:attendance_log/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';

class QRcode extends StatelessWidget {
  const QRcode({super.key});

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 250,
          width: 250,
          child: PrettyQrView.data(
            data: jsonEncode(Student(student: userProvider.user!).toJson()),
            decoration: PrettyQrDecoration(
              shape: PrettyQrSmoothSymbol(color: AppTheme().qrcodeColor),
            ),
          ),
        ),
      ),
    );
  }
}
