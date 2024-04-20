import 'package:attendance_log/helper.dart';
import 'package:attendance_log/models/institute.dart';
import 'package:attendance_log/provider/user_provider.dart';
import 'package:attendance_log/services/collection_refrences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<String?> register(
      {required String name,
      required String email,
      required String password,
      required Role role,
      required String? registrationNumber,
      required Institute institute,
      required UserProvider userProvider}) async {
    try {
      final UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(credential);
      CollectionReference userCollection = role == Role.Student
          ? Collections().studentCollection()
          : role == Role.Admin
              ? Collections().adminCollection()
              : Collections().teacherCollection();
      await userCollection.doc(credential.user!.uid).set({
        "name": name,
        "email": email,
        "role": role.name,
        "registration": registrationNumber ?? '',
        "institute": institute.id,
        "subjects": []
      });
      DocumentSnapshot userDoc =
          await userCollection.doc(credential.user!.uid).get();
      userProvider.assignUser(userDoc: userDoc);
      if (role == Role.Student) {
        DocumentSnapshot doc = await Collections()
            .studentMappingCollection()
            .doc(institute.id)
            .get();
        Map<String, dynamic> studentMapping = {};
        print("doc $doc");
        if (!doc.exists) {
          studentMapping[registrationNumber!] = credential.user!.uid;
          await Collections()
              .studentMappingCollection()
              .doc(institute.id)
              .set({"ID_mapping": studentMapping});
          return null;
        }
        studentMapping = doc["ID_mapping"] ?? {};
        if (studentMapping.containsKey(registrationNumber)) {
          print("Sign up error registration number already registered");
          return "Registration Number already registered!";
        }
        studentMapping[registrationNumber!] = credential.user!.uid;
        await Collections()
            .studentMappingCollection()
            .doc(institute.id)
            .update({"ID_mapping": studentMapping});
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print("Firebase signup error $e");
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        print("Firebase signup error $e");
        return 'The account already exists for that email.';
      }
    } catch (e) {
      print("Firebase signup error $e");
      return "Unexpected Error Occured!";
    }
    return null;
  }

  Future<String?> login({
    required String email,
    required String password,
    required Role role,
    required UserProvider userProvider,
  }) async {
    try {
      final UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      print(credential);
      CollectionReference userCollection = role == Role.Student
          ? Collections().studentCollection()
          : role == Role.Admin
              ? Collections().adminCollection()
              : Collections().teacherCollection();
      DocumentSnapshot userDoc =
          await userCollection.doc(credential.user!.uid).get();
      userProvider.assignUser(userDoc: userDoc);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print("Firebase signin error $e");
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        print("Firebase signin error $e");
        return 'Wrong password provided for that user.';
      }
    } catch (e) {
      print("Firebase signin error $e");
      return "Unexpected Error Occured!";
    }
    return null;
  }
}
