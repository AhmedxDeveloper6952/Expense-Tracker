import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future updateEmployeeDetails(
      String id, Map<String, dynamic> updatedInfo) async {
    await FirebaseFirestore.instance
        .collection("Employee")
        .doc(id)
        .update(updatedInfo);
  }

  Future addEmployeeDetails(
      Map<String, dynamic> employeeInfoMap, String id, String category) async {
    await FirebaseFirestore.instance
        .collection("Employee")
        .doc(id)
        .set(employeeInfoMap);
  }

  Stream<QuerySnapshot> getEmployeeDetails() {
    return FirebaseFirestore.instance.collection("Employee").snapshots();
  }

  // Other methods...

  Future deleteEmployeeDetails(String title) async {
    await FirebaseFirestore.instance
        .collection("Employee")
        .where("Title", isEqualTo: title)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }
}
