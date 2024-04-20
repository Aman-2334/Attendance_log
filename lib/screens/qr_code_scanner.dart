// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:attendance_log/models/student.dart';
import 'package:attendance_log/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scan/scan.dart';

class QRCodeScanner extends StatefulWidget {
  final ValueChanged<Student> getStudent;
  const QRCodeScanner({super.key, required this.getStudent});

  @override
  State<QRCodeScanner> createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  ScanController controller = ScanController();

  final ImagePicker picker = ImagePicker();

  Future<String?> picImage() async {
    String? result;
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        result = await Scan.parse(pickedFile.path);
      }
    } catch (e) {
      print("camera picked file error $e");
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = AppTheme().themeData;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              child: ScanView(
                controller: controller,
                scanAreaScale: .7,
                scanLineColor: themeData.primaryColor,
                onCapture: (data) {
                  Student student = Student.fromJson(jsonDecode(data));
                  widget.getStudent(student);
                  Navigator.of(context).pop();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TextButton.icon(
                  onPressed: () async {
                    controller.pause();
                    String? userData = await picImage();
                    if (userData == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No Data Found!")));
                    } else {
                      Student student = Student.fromJson(jsonDecode(userData));
                      widget.getStudent(student);
                      Navigator.of(context).pop();
                    }
                    controller.resume();
                  },
                  label: Text(
                    "Upload from Gallery",
                    style: themeData.textTheme.bodySmall,
                  ),
                  icon: const Icon(Icons.image_outlined),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
