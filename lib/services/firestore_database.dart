import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_meal/models/meal.dart';
import 'package:mess_meal/models/user.dart';
import 'package:mess_meal/services/firestore_path.dart';
import 'package:mess_meal/services/firestore_service.dart';
import 'package:meta/meta.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

/*
This is the main class access/call for any UI widgets that require to perform
any CRUD activities operation in Firestore database.
This class work hand-in-hand with FirestoreService and FirestorePath.
Notes:
For cases where you need to have a special method such as bulk update specifically
on a field, then is ok to use custom code and write it here. For example,
setAllTodoComplete is require to change all todos item to have the complete status
changed to true.
 */
class FirestoreDatabase {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid;

  final _firestoreService = FirestoreService.instance;

  // create new user (member)
  createUser(User user) async => await _firestoreService.setData(
      path: FirestorePath.user(user.uid), data: user.toMap());

  Future<int> _getUserCount() async {
    final data = await _firestoreService.getData(path: FirestorePath.counts());
    return data['users'];
  }

  Future<int> updateManagerSerials() async {
    int userCount = await _getUserCount();
    if (userCount < 5) {
      return userCount + 1;
    }

    int newUserManagerSerial;
    final users = await _firestoreService.listDocuments(
      path: FirestorePath.users(),
      builder: (data, documentId) => User.fromMap(data, documentId),
      queryBuilder: (query) => query.where('manager_serial', isGreaterThan: 4),
    );

    users.forEach((user) {
      _firestoreService.setData(
        path: FirestorePath.user(user.uid),
        data: {'managerSerial': user.managerSerial + 1},
        merge: true,
      );
    });

    return newUserManagerSerial;
  }

  //Method to create/update todoModel
  Future<void> setMeal(Meal meal) async => await _firestoreService.setData(
        path: FirestorePath.meal(uid, meal.date.toIso8601String()),
        data: meal.toMap(),
      );

  //Method to delete todoModel entry
  Future<void> deleteTodo(Meal meal) async {
    await _firestoreService.deleteData(
        path: FirestorePath.meal(uid, meal.date.toIso8601String()));
  }

  //Method to retrieve todoModel object based on the given todoId
  Stream<Meal> todoStream({@required String todoId}) =>
      _firestoreService.documentStream(
        path: FirestorePath.meal(uid, todoId),
        builder: (data, documentId) =>
            Meal.fromMap(data, date: DateTime.parse(documentId)),
      );

  //Method to retrieve all meals from the same user based on uid
  Future<List<Meal>> mealList() => _firestoreService.listDocuments(
        path: FirestorePath.meals(uid),
        builder: (data, documentId) =>
            Meal.fromMap(data, date: DateTime.parse(documentId)),
      );

  //Method to mark all todoModel to be complete
  Future<void> setAllTodoComplete() async {
    final batchUpdate = Firestore.instance.batch();

    final querySnapshot = await Firestore.instance
        .collection(FirestorePath.meals(uid))
        .getDocuments();

    for (DocumentSnapshot ds in querySnapshot.documents) {
      batchUpdate.updateData(ds.reference, {'complete': true});
    }
    await batchUpdate.commit();
  }

  Future<void> deleteAllTodoWithComplete() async {
    final batchDelete = Firestore.instance.batch();

    final querySnapshot = await Firestore.instance
        .collection(FirestorePath.meals(uid))
        .where('complete', isEqualTo: true)
        .getDocuments();

    for (DocumentSnapshot ds in querySnapshot.documents) {
      batchDelete.delete(ds.reference);
    }
    await batchDelete.commit();
  }
}
