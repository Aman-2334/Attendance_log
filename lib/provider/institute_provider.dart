import 'package:attendance_log/models/institute.dart';
import 'package:attendance_log/services/institute_service.dart';
import 'package:flutter/material.dart';

class InstituteProvider extends ChangeNotifier {
  Institute? institute;
List<Institute> institutes = [];
  bool loadingInstitutes = false;

  Future<void> loadInstitutes() async {
    if (institutes.isNotEmpty) return;
    print("Loading Institue");
    loadingInstitutes = true;
    notifyListeners();
    InstituteService().loadInstitute().then((value) {
      loadingInstitutes = false;
      institutes = value;
      notifyListeners();
    });
  }
  Future<void> getInstitute(String instituteId) async {
    institute = await InstituteService().getInstitute(instituteId);
    notifyListeners();
  }
}