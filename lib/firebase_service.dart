import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final CollectionReference taskCollection = FirebaseFirestore.instance.collection('tasks');

  Stream<QuerySnapshot> getTasksFromFirestore() {
    return taskCollection.snapshots();
  }

  Future<void> addTaskToFirestore(String task, String date, String time, String priority) {
    return taskCollection.add({
      'Task': task,
      'Date': date,
      'Time': time,
      'Priority': priority,
      'Completed': false,
    });
  }

  Future<void> deleteTaskFromFirestore(String id) {
    return taskCollection.doc(id).delete();
  }

  Future<void> updateTaskCompletion(String id, bool completed) {
    return taskCollection.doc(id).update({'Completed': completed});
  }

  Future<void> editTaskInFirestore(String id, String task, String date, String time, String priority, bool completed) {
    return taskCollection.doc(id).update({
      'Task': task,
      'Date': date,
      'Time': time,
      'Priority': priority,
      'Completed': completed,
    });
  }
}
