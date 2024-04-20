import 'package:attendance_log/models/institute.dart';
import 'package:attendance_log/services/collection_refrences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InstituteService{
  Future<Institute?> getInstitute(String instituteId) async {
    Institute? institutes;
    try {
      DocumentSnapshot documentSnapshot =
          await Collections().instituteCollection().doc(instituteId).get();
      institutes = Institute.fromDoc(documentSnapshot);
    } on Exception catch (e) {
      print("load institute error: $e");
    }
    return institutes;
  }

  Future<List<Institute>> loadInstitute() async {
    List<Institute> institute = [];
    try {
      // await sendInstitute();
      QuerySnapshot querySnapshots =
          await Collections().instituteCollection().get();
      // print(querySnapshots.docs);
      for (var doc in querySnapshots.docs) {
        institute.add(Institute.fromDoc(doc));
      }
      // print("institute $institute");
    } on Exception catch (e) {
      print("load Institute error: $e");
    }
    return institute;
  }

  // List<String> institutes = [
  //   "IIT Bombay",
  //   "IIT Delhi",
  //   "IIT Madras",
  //   "IIT Kanpur",
  //   "IIT Kharagpur",
  //   "IIT Roorkee",
  //   "IIT Guwahati",
  //   "IIT Hyderabad",
  //   "IIT Gandhinagar",
  //   "IIT Ropar",
  //   "IIT Bhubaneswar",
  //   "IIT Indore",
  //   "IIT Mandi",
  //   "IIT Jodhpur",
  //   "IIT Patna",
  //   "IIT(ISM) Dhanbad",
  //   "IIT Tirupati",
  //   "IIT Bhilai",
  //   "IIT Palakkad",
  //   "IIT Jammu",
  //   "IIT Goa",
  // ];

  // Future<void> sendInstitute() async{
  //   for(String institute in institutes){
  //     await Collections().instituteCollection().doc().set({"name": institute});
  //   }
  // }
}