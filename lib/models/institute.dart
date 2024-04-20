import 'package:cloud_firestore/cloud_firestore.dart';

class Institute{
  String id;
  String name;

  Institute({
    required this.id,
    required this.name,
  }) : super();

  factory Institute.fromDoc(DocumentSnapshot doc) {
    return Institute(
      id: doc.id,
      name: doc['name'] ?? '',
    );
  }

  @override
  String toString() {
    return "Institute Details $id, $name";
  }
}