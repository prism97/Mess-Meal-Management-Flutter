import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_meal/models/fund.dart';
import 'package:mess_meal/models/manager_cost.dart';
import 'package:mess_meal/models/meal.dart';
import 'package:mess_meal/models/meal_amount.dart';
import 'package:mess_meal/models/member.dart';
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
  FirestoreDatabase({@required this.uid});
  // : assert(uid != null);
  final String uid;

  final _firestoreService = FirestoreService.instance;

  // create new user (member)
  createUser(Member user) async {
    await _firestoreService.setData(
      path: FirestorePath.user(user.uid),
      data: user.toMap(),
    );

    // increment user count by 1
    await _firestoreService.setData(
      path: FirestorePath.counts(),
      data: {
        'users': FieldValue.increment(1),
      },
      merge: true,
    );

    if (user.isManager()) {
      // create new document in managers collection
      String managerId = await _firestoreService.createDocument(
        collectionPath: FirestorePath.managers(),
        data: {
          'uid': user.uid,
          'name': user.name,
        },
      );
      // update current manager document
      await _setCurrentManager(
        uid: user.uid,
        name: user.name,
        managerId: managerId,
      );
    }
  }

  Future<List<Member>> _getActiveUsers() async {
    List<Member> users = await _firestoreService.listDocuments(
      path: FirestorePath.users(),
      builder: (data, documentId) => Member.fromMap(data, documentId),
      queryBuilder: (query) => query.where('isDeleted', isNotEqualTo: true),
    );
    return users;
  }

  Future<int> getUserCount() async {
    final data = await _firestoreService.getData(path: FirestorePath.counts());
    return data['users'];
  }

  Future<int> getMessboyCount() async {
    final data = await _firestoreService.getData(path: FirestorePath.counts());
    return data['messboys'];
  }

  Future<int> getTotalFunds() async {
    final data = await _firestoreService.getData(path: FirestorePath.counts());
    return data['totalFunds'];
  }

  Stream<int> totalFundStream() => _firestoreService.documentStream(
        path: FirestorePath.counts(),
        builder: (data, documentId) => data['totalFunds'],
      );

  Stream<Map<String, dynamic>> currentManagerStream() =>
      _firestoreService.documentStream(
        path: FirestorePath.currentManager(),
        builder: (data, documentId) => data,
      );

  Future<int> updateManagerSerials() async {
    int userCount = await getUserCount();
    if (userCount < 5) {
      return userCount + 1;
    }

    final users = await _firestoreService.listDocuments(
      path: FirestorePath.users(),
      builder: (data, documentId) => Member.fromMap(data, documentId),
      queryBuilder: (query) => query.where('managerSerial', isGreaterThan: 4),
    );

    Member user;
    for (user in users) {
      await _firestoreService.setData(
        path: FirestorePath.user(user.uid),
        data: {
          'managerSerial': FieldValue.increment(1)
        }, //  user.managerSerial + 1
        merge: true,
      );
    }

    return 5; // new user will always start at serial 5
  }

  _setCurrentManager({String uid, String name, String managerId}) async {
    DateTime startDate = DateTime.now();
    if (startDate.hour > 7) {
      startDate = startDate.add(Duration(days: 1));
    }
    startDate = DateTime(startDate.year, startDate.month, startDate.day);
    await _firestoreService.setData(
      path: FirestorePath.currentManager(),
      data: {
        'managerId': managerId,
        'uid': uid,
        'name': name,
        'cost': 0,
        'totalEggCount': 0,
        'startDate': startDate.toIso8601String(),
      },
    );
  }

  Future<Map<String, dynamic>> getCurrentManager() =>
      _firestoreService.getData(path: FirestorePath.currentManager());

  Future<void> updateCurrentManagerCost(ManagerCost cost) async {
    await _firestoreService.setData(
      path: FirestorePath.currentManager(),
      data: {
        'cost': FieldValue.increment(cost.amount),
      },
      merge: true,
    );
    Map<String, dynamic> currentManager = await getCurrentManager();
    String managerId = currentManager['managerId'];
    return _firestoreService.createDocument(
      collectionPath: FirestorePath.managerCost(managerId),
      data: cost.toMap(),
    );
  }

  Future<List<ManagerCost>> getManagerCostList(String managerId) =>
      _firestoreService.listDocuments(
        path: FirestorePath.managerCost(managerId),
        builder: (data, documentId) => ManagerCost.fromMap(data),
        sort: (a, b) => b.date.difference(a.date).inSeconds,
      );

  // retrieve default meal of user
  Stream<Meal> defaultMealStream() => _firestoreService.documentStream(
        path: FirestorePath.user(uid),
        builder: (data, documentId) => Meal.fromMapWithDate(
          Map<String, dynamic>.from(data['defaultMeal']),
        ),
      );

  Future<Meal> getDefaultMeal() async {
    Member currentUser = Member.fromMap(
      await _firestoreService.getData(
        path: FirestorePath.user(uid),
      ),
      uid,
    );
    return currentUser.defaultMeal;
  }

  // update default meal of user
  Future<void> _setDefaultMeal(Meal meal) async {
    await _firestoreService.setData(
      path: FirestorePath.user(uid),
      data: {'defaultMeal': meal.toMap()},
      merge: true,
    );
  }

  Future<void> updateDefaultMeal(Meal oldMeal, Meal newMeal) async {
    await _setDefaultMeal(newMeal);

    /*  if default meal is updated after 7am, 
        set today's meal with old meal
        (in case today's meal doesn't exist yet)
    */
    DateTime now = DateTime.now();
    if (now.hour > 6) {
      DateTime today = DateTime(now.year, now.month, now.day);

      DocumentSnapshot document = await _firestoreService.getDocument(
          path: FirestorePath.meal(uid, today.toIso8601String()));
      if (!document.exists) {
        setMeal(
          Meal(
            breakfast: oldMeal.breakfast,
            lunch: oldMeal.lunch,
            dinner: oldMeal.dinner,
            date: today,
          ),
        );
      }
    }
  }

  // create/update meal
  Future<void> setMeal(Meal meal) => _firestoreService.setData(
        path: FirestorePath.meal(uid, meal.date.toIso8601String()),
        data: meal.toMap(),
        merge: true,
      );

  // create/update guest meal
  Future<void> setGuestMeal(Meal meal) => _firestoreService.setData(
        path: FirestorePath.guestMeal(uid, meal.date.toIso8601String()),
        data: meal.toMap(),
        merge: true,
      );

  // retrieve guest meal document
  Future<DocumentSnapshot> getGuestMeal(DateTime date) =>
      _firestoreService.getDocument(
        path: FirestorePath.guestMeal(uid, date.toIso8601String()),
      );

  // create/update meal of any user
  Future<void> _setMealOfUser(Meal meal, String userUid) =>
      _firestoreService.setData(
        path: FirestorePath.meal(userUid, meal.date.toIso8601String()),
        data: meal.toMap(),
        merge: true,
      );

  // retrieve meal by date
  Stream<Meal> mealStream({@required DateTime date}) =>
      _firestoreService.documentStream(
        path: FirestorePath.meal(uid, date.toIso8601String()),
        builder: (data, documentId) => Meal.fromMap(
          Map<String, bool>.from(data),
          date: DateTime.parse(documentId),
        ),
      );

  // create/update meal amount
  Future<void> setMealAmount(
          {@required DateTime date, @required MealAmount mealAmount}) =>
      _firestoreService.setData(
        path: FirestorePath.mealAmount(
          date.toIso8601String(),
        ),
        data: mealAmount.toMap(),
        merge: true,
      );

  // retrieve meal amount by date
  Stream<MealAmount> mealAmountStream({@required DateTime date}) =>
      _firestoreService.documentStream(
        path: FirestorePath.mealAmount(date.toIso8601String()),
        builder: (data, documentId) =>
            MealAmount.fromMap(Map<String, double>.from(data)),
      );

  Future<MealAmount> getMealAmount({@required DateTime date}) async =>
      MealAmount.fromMap(
          Map<String, double>.from(await _firestoreService.getData(
        path: FirestorePath.mealAmount(
          date.toIso8601String(),
        ),
      )));

  // retrieve fixed cost
  Future<double> getFixedCost() async {
    final data = await _firestoreService.getData(path: FirestorePath.others());
    return double.parse(data['fixedCost'].toString());
  }

  Future<void> saveOldManagerData(
      Map<String, dynamic> oldManager, double eggUnitPrice) {
    return _firestoreService.setData(
      path: FirestorePath.manager(oldManager['managerId']),
      data: {
        'startDate': oldManager['startDate'].toIso8601String(),
        'endDate': oldManager['endDate'].toIso8601String(),
        'totalCost': oldManager['cost'],
        'eggUnitPrice': eggUnitPrice,
        'totalEggCount': oldManager['totalEggCount'],
      },
      merge: true,
    );
  }

  // update manager
  Future<void> updateManager(
      Map<String, dynamic> oldManager, Map<String, dynamic> counts) async {
    // Map<String, dynamic> currentManager = await getCurrentManager();

    // String oldManagerId = currentManager['managerId'];
    // DateTime startDate = DateTime.parse(currentManager['startDate']);
    // DateTime endDate = DateTime.now();
    // if (endDate.hour < 7) {
    //   endDate = endDate.subtract(Duration(days: 1));
    // }
    // endDate = DateTime(endDate.year, endDate.month, endDate.day);
    // double eggUnitPrice = await getEggUnitPrice();

    // await _firestoreService.setData(
    //   path: FirestorePath.manager(oldManagerId),
    //   data: {
    //     'startDate': startDate.toIso8601String(),
    //     'endDate': endDate.toIso8601String(),
    //     'totalCost': currentManager['cost'],
    //     'eggUnitPrice': eggUnitPrice,
    //     'totalEggCount': currentManager['totalEggCount'],
    //   },
    //   merge: true,
    // );

    DateTime startDate = oldManager['startDate'];
    DateTime endDate = oldManager['endDate'];
    DateTime tempDate;
    Map<DateTime, MealAmount> mealAmounts = Map();
    tempDate = startDate;

    // int userCount = await getUserCount();
    // // system fixed cost is for one month, so divide by number of days
    // double fixedCost =
    //     (await getFixedCost()) / endDate.difference(startDate).inDays;
    // int messboyCount = await getMessboyCount();
    int userCount = counts['userCount'];
    int messboyCount = counts['messboyCount'];
    double fixedCost = counts['fixedCost'];
    double messboyMealAmount = 0;

    DocumentSnapshot document;
    // fetch meal amounts for the duration
    while (true) {
      document = await _firestoreService.getDocument(
        path: FirestorePath.mealAmount(
          tempDate.toIso8601String(),
        ),
      );
      if (document.exists) {
        mealAmounts[tempDate] =
            MealAmount.fromMap(Map<String, double>.from(document.data()));
      } else {
        mealAmounts[tempDate] = MealAmount.fromDefault();
      }
      messboyMealAmount += mealAmounts[tempDate].breakfast * messboyCount;
      messboyMealAmount += mealAmounts[tempDate].lunch * messboyCount;
      messboyMealAmount += mealAmounts[tempDate].dinner * messboyCount;

      if (tempDate.isAtSameMomentAs(endDate)) break;
      tempDate = tempDate.add(Duration(days: 1));
    }

    print('Meal amounts fetched');

    List<Member> users = await _firestoreService.listDocuments(
      path: FirestorePath.users(),
      builder: (data, documentId) => Member.fromMap(data, documentId),
    );

    MealAmount mealAmount;
    Meal meal, guestMeal;
    double totalMealAmount = 0, userMealAmount;
    int breakfastCount, lunchCount, dinnerCount, guestMealCount;

    String newManagerId;
    for (var user in users) {
      // this user will be the new manager
      if (user.managerSerial == 2) {
        // create new document in managers collection
        newManagerId = await _firestoreService.createDocument(
          collectionPath: FirestorePath.managers(),
          data: {
            'uid': user.uid,
            'name': user.name,
          },
        );
        // update current manager document
        await _setCurrentManager(
          uid: user.uid,
          name: user.name,
          managerId: newManagerId,
        );
      }

      // update user's manager serial
      if (user.isManager()) {
        await _firestoreService.setData(
          path: FirestorePath.user(user.uid),
          data: {'managerSerial': userCount},
          merge: true,
        );
      } else if (!user.isDeleted) {
        await _firestoreService.setData(
          path: FirestorePath.user(user.uid),
          data: {'managerSerial': FieldValue.increment(-1)},
          merge: true,
        );
      }

      tempDate = startDate;
      userMealAmount = 0;
      breakfastCount = 0;
      lunchCount = 0;
      dinnerCount = 0;
      guestMealCount = 0;

      while (true) {
        mealAmount = mealAmounts[tempDate];
        document = await _firestoreService.getDocument(
          path: FirestorePath.meal(user.uid, tempDate.toIso8601String()),
        );

        if (document.exists) {
          meal = Meal.fromMap(Map<String, bool>.from(document.data()));

          if (meal.breakfast) {
            userMealAmount += mealAmount.breakfast;
            breakfastCount++;
          }
          if (meal.lunch) {
            userMealAmount += mealAmount.lunch;
            lunchCount++;
          }
          if (meal.dinner) {
            userMealAmount += mealAmount.dinner;
            dinnerCount++;
          }
        }
        // retrieve guest meal for this date & user
        document = await _firestoreService.getDocument(
          path: FirestorePath.guestMeal(user.uid, tempDate.toIso8601String()),
        );
        if (document.exists) {
          guestMeal = Meal.fromMap(Map<String, bool>.from(document.data()));
          if (guestMeal.breakfast) {
            userMealAmount += mealAmount.breakfast * 1.5;
            guestMealCount++;
          }
          if (guestMeal.lunch) {
            userMealAmount += mealAmount.lunch * 1.5;
            guestMealCount++;
          }
          if (guestMeal.dinner) {
            userMealAmount += mealAmount.dinner * 1.5;
            guestMealCount++;
          }
        }

        if (tempDate.isAtSameMomentAs(endDate)) break;
        tempDate = tempDate.add(Duration(days: 1));
      }

      await _firestoreService.setData(
        path: FirestorePath.mealRecord(oldManager['managerId'], user.uid),
        data: {
          'teacherId': user.teacherId,
          'name': user.name,
          'mealAmount': userMealAmount,
          'breakfastCount': breakfastCount,
          'lunchCount': lunchCount,
          'dinnerCount': dinnerCount,
          'guestMealCount': guestMealCount,
        },
        merge: true,
      );

      totalMealAmount += userMealAmount;
    }

    print('user calc complete');

    double perMealCost = (oldManager['cost'] -
            oldManager['totalEggCount'] * counts['eggUnitPrice']) /
        (totalMealAmount + messboyMealAmount);
    double perUserFixedCost =
        (fixedCost + perMealCost * messboyMealAmount) / userCount;

    await _firestoreService.setData(
      path: FirestorePath.manager(oldManager['managerId']),
      data: {
        'totalMealAmount': totalMealAmount,
        'perMealCost': perMealCost,
        'perUserFixedCost': perUserFixedCost,
      },
      merge: true,
    );
  }

  Future<void> cleanupUserData() async {
    List<Member> deletedUsers = await _firestoreService.listDocuments(
      path: FirestorePath.users(),
      builder: (data, documentId) => Member.fromMap(data, documentId),
      queryBuilder: (query) => query.where('isDeleted', isEqualTo: true),
    );
    for (var user in deletedUsers) {
      await _firestoreService.deleteData(path: FirestorePath.user(user.uid));
    }
  }

  Future<void> addFund(Fund fund) async {
    await _firestoreService.createDocument(
      collectionPath: FirestorePath.funds(),
      data: fund.toMap(),
    );
    await _firestoreService.setData(
      path: FirestorePath.counts(),
      data: {
        'totalFunds': FieldValue.increment(fund.amount),
      },
      merge: true,
    );
  }

  Future<List<Fund>> getFundList() => _firestoreService.listDocuments(
        path: FirestorePath.funds(),
        builder: (data, documentId) => Fund.fromMap(data),
        sort: (a, b) => b.date.difference(a.date).inSeconds,
      );

  // list of users who subscribed for today's breakfast, lunch and dinner
  Future<Map<String, List<Member>>> getMealSubscribers() async {
    final today = DateTime.now();
    final _date = DateTime(today.year, today.month, today.day);
    final _updateTime = DateTime(today.year, today.month, today.day, 7);

    List<Member> users = await _firestoreService.listDocuments(
      path: FirestorePath.users(),
      builder: (data, documentId) => Member.fromMap(data, documentId),
    );

    Map<String, List<Member>> mealSubscribers = {
      'breakfast': List<Member>(),
      'lunch': List<Member>(),
      'dinner': List<Member>(),
    };

    Meal meal, defaultMeal;
    DocumentSnapshot document;
    Member user;
    for (user in users) {
      defaultMeal = user.defaultMeal;
      document = await _firestoreService.getDocument(
        path: FirestorePath.meal(user.uid, _date.toIso8601String()),
      );

      if (document.exists) {
        meal = Meal.fromMap(Map<String, bool>.from(document.data()));
      } else {
        if (defaultMeal.date.isBefore(_updateTime)) {
          meal = defaultMeal;
        } else {
          meal = Meal(breakfast: false, lunch: false, dinner: false);
        }

        // set only after 7 am
        if (DateTime.now().hour > 6) {
          _setMealOfUser(
            Meal(
              breakfast: meal.breakfast,
              lunch: meal.lunch,
              dinner: meal.dinner,
              date: _date,
            ),
            user.uid,
          );
        }
      }
      if (meal.breakfast) mealSubscribers['breakfast'].add(user);
      if (meal.lunch) mealSubscribers['lunch'].add(user);
      if (meal.dinner) mealSubscribers['dinner'].add(user);
    }

    return mealSubscribers;
  }

  // list of users who turned on guest meal for today's breakfast, lunch or dinner
  Future<Map<String, List<Member>>> getGuestMealSubscribers() async {
    final today = DateTime.now();
    final _date = DateTime(today.year, today.month, today.day);

    List<Member> users = await _firestoreService.listDocuments(
      path: FirestorePath.users(),
      builder: (data, documentId) => Member.fromMap(data, documentId),
    );

    Map<String, List<Member>> guestMealSubscribers = {
      'breakfast': List<Member>(),
      'lunch': List<Member>(),
      'dinner': List<Member>(),
    };

    Meal guestMeal;
    DocumentSnapshot document;
    Member user;
    for (user in users) {
      document = await _firestoreService.getDocument(
        path: FirestorePath.guestMeal(user.uid, _date.toIso8601String()),
      );

      if (document.exists) {
        guestMeal = Meal.fromMap(Map<String, bool>.from(document.data()));
        if (guestMeal.breakfast) guestMealSubscribers['breakfast'].add(user);
        if (guestMeal.lunch) guestMealSubscribers['lunch'].add(user);
        if (guestMeal.dinner) guestMealSubscribers['dinner'].add(user);
      }
    }
    return guestMealSubscribers;
  }

  Future<Map<String, dynamic>> getMealRecord(
      Map<String, dynamic> managerDocument,
      {String userId}) async {
    Map<String, dynamic> record = {};

    Map<String, dynamic> mealData = await _firestoreService.getData(
      path:
          FirestorePath.mealRecord(managerDocument['managerId'], userId ?? uid),
    );
    if (mealData != null && mealData.containsKey('mealAmount')) {
      record['mealAmount'] = mealData['mealAmount'];
      record['breakfastCount'] = mealData['breakfastCount'];
      record['lunchCount'] = mealData['lunchCount'];
      record['dinnerCount'] = mealData['dinnerCount'];
      record['guestMealCount'] = mealData['guestMealCount'];
      record['eggCount'] = mealData['eggCount'];
      record['mealCost'] =
          managerDocument['perMealCost'] * mealData['mealAmount'];
      record['fixedCost'] = managerDocument['perUserFixedCost'];
      record['totalCost'] = record['mealCost'] +
          (mealData['eggCount'] ?? 0) * managerDocument['eggUnitPrice'] +
          managerDocument['perUserFixedCost'];
    }

    return record;
  }

  Future<List<Map<String, dynamic>>> getManagerRecords() =>
      _firestoreService.listDocuments(
        path: FirestorePath.managers(),
        builder: (data, documentId) {
          data['managerId'] = documentId;
          return data;
        },
        queryBuilder: (query) => query.where('startDate', isGreaterThan: ''),
        sort: (a, b) => DateTime.parse(b['startDate'])
            .difference(DateTime.parse(a['startDate']))
            .inSeconds,
      );

  Future<List<Map<String, dynamic>>> calculateCost(
      List<Map<String, dynamic>> managers) async {
    List<Map<String, dynamic>> costList = [];
    List<Map<String, dynamic>> uniqueUserList = [];
    Set<String> uniqueUserIdList = Set();
    for (var manager in managers) {
      await _firestoreService.listDocuments(
        path: FirestorePath.mealRecords(manager['managerId']),
        builder: (data, documentId) {
          bool inserted = uniqueUserIdList.add(documentId);
          if (inserted) {
            uniqueUserList.add({
              'uid': documentId,
              'teacherId': data['teacherId'],
              'name': data['name'],
            });
          }
        },
      );
    }
    for (var user in uniqueUserList) {
      double totalCost = 0;
      for (var manager in managers) {
        Map<String, dynamic> record =
            await getMealRecord(manager, userId: user['uid']);
        totalCost += record['totalCost'] ?? 0;
      }
      costList.add({
        "teacherId": user['teacherId'],
        "name": user['name'],
        "totalCost": double.parse((totalCost).toStringAsFixed(2)),
      });
    }
    return costList;
  }

  Future<void> updateFixedCost(double newFixedCost) =>
      _firestoreService.setData(
        path: FirestorePath.others(),
        data: {
          'fixedCost': newFixedCost,
        },
        merge: true,
      );

  // retrieve unit price of eggs
  Future<double> getEggUnitPrice() async {
    final data = await _firestoreService.getData(path: FirestorePath.others());
    return double.parse(data['eggUnitPrice'].toString());
  }

  Stream<double> eggUnitPriceStream() => _firestoreService.documentStream(
        path: FirestorePath.others(),
        builder: (data, documentId) =>
            double.parse(data['eggUnitPrice'].toString()),
      );

  Future<void> updateEggUnitPrice(double newPrice) => _firestoreService.setData(
        path: FirestorePath.others(),
        data: {
          'eggUnitPrice': newPrice,
        },
        merge: true,
      );

  Future<void> updateEggCountOfUser(String userId) async {
    Map<String, dynamic> currentManager = await getCurrentManager();
    String managerId = currentManager['managerId'];

    await _firestoreService.setData(
      path: FirestorePath.mealRecord(managerId, userId),
      data: {
        'eggCount': FieldValue.increment(1),
      },
      merge: true,
    );
    return _firestoreService.setData(
      path: FirestorePath.currentManager(),
      data: {
        'totalEggCount': FieldValue.increment(1),
      },
      merge: true,
    );
  }

  // retrieve user list (names only) sorted by manager serial
  Future<List<Member>> getManagerList() => _firestoreService.listDocuments(
        path: FirestorePath.users(),
        builder: (data, documentId) => Member.fromMap(data, documentId),
        queryBuilder: (query) => query.orderBy('managerSerial').limit(5),
      );

  Future<bool> deleteAccount() async {
    final doc =
        await _firestoreService.getDocument(path: FirestorePath.user(uid));
    Member user = Member.fromMap(doc.data(), doc.id);
    int managerSerial = user.managerSerial;

    // current manager account can't be deleted
    if (managerSerial == 1) return false;

    try {
      await doc.reference.set(
        {
          'isDeleted': true,
          'managerSerial': -1,
          'defaultMeal': Meal(
            breakfast: false,
            lunch: false,
            dinner: false,
            date: DateTime.now(),
          ),
        },
        SetOptions(merge: true),
      );

      // decrement user count by 1
      await _firestoreService.setData(
        path: FirestorePath.counts(),
        data: {
          'users': FieldValue.increment(-1),
        },
        merge: true,
      );
      // update manager serials
      final users = await _firestoreService.listDocuments(
        path: FirestorePath.users(),
        builder: (data, documentId) => Member.fromMap(data, documentId),
        queryBuilder: (query) =>
            query.where('managerSerial', isGreaterThan: managerSerial),
      );

      for (Member user in users) {
        await _firestoreService.setData(
          path: FirestorePath.user(user.uid),
          data: {
            'managerSerial': FieldValue.increment(-1)
          }, //  user.managerSerial - 1
          merge: true,
        );
      }
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  /*
  *
  * extra function, might be needed later
  *
  */
  Future<void> recalculateManagerStats(String managerId) async {
    Map<String, dynamic> manager =
        await _firestoreService.getData(path: FirestorePath.manager(managerId));

    DateTime startDate = DateTime.parse(manager['startDate']);
    DateTime endDate = DateTime.parse(manager['endDate']);

    DateTime tempDate;
    Map<DateTime, MealAmount> mealAmounts = Map();
    tempDate = startDate;

    int userCount = await getUserCount();
    // system fixed cost is for one month, so divide by number of days
    double fixedCost =
        (await getFixedCost()) / endDate.difference(startDate).inDays;
    int messboyCount = await getMessboyCount();
    double messboyMealAmount = 0;

    DocumentSnapshot document;
    // fetch meal amounts for the duration
    while (true) {
      document = await _firestoreService.getDocument(
        path: FirestorePath.mealAmount(
          tempDate.toIso8601String(),
        ),
      );
      if (document.exists) {
        mealAmounts[tempDate] =
            MealAmount.fromMap(Map<String, double>.from(document.data()));
      } else {
        mealAmounts[tempDate] = MealAmount.fromDefault();
      }
      messboyMealAmount += mealAmounts[tempDate].breakfast * messboyCount;
      messboyMealAmount += mealAmounts[tempDate].lunch * messboyCount;
      messboyMealAmount += mealAmounts[tempDate].dinner * messboyCount;

      if (tempDate.isAtSameMomentAs(endDate)) break;
      tempDate = tempDate.add(Duration(days: 1));
    }

    List<Member> users = await _firestoreService.listDocuments(
      path: FirestorePath.users(),
      builder: (data, documentId) => Member.fromMap(data, documentId),
    );

    MealAmount mealAmount;
    Meal meal, guestMeal;
    double totalMealAmount = 0, userMealAmount;
    int breakfastCount, lunchCount, dinnerCount, guestMealCount;

    Member user;

    for (user in users) {
      tempDate = startDate;
      userMealAmount = 0;
      breakfastCount = 0;
      lunchCount = 0;
      dinnerCount = 0;
      guestMealCount = 0;

      while (true) {
        mealAmount = mealAmounts[tempDate];
        document = await _firestoreService.getDocument(
          path: FirestorePath.meal(user.uid, tempDate.toIso8601String()),
        );

        if (document.exists) {
          meal = Meal.fromMap(Map<String, bool>.from(document.data()));

          if (meal.breakfast) {
            userMealAmount += mealAmount.breakfast;
            breakfastCount++;
          }
          if (meal.lunch) {
            userMealAmount += mealAmount.lunch;
            lunchCount++;
          }
          if (meal.dinner) {
            userMealAmount += mealAmount.dinner;
            dinnerCount++;
          }
        }
        // retrieve guest meal for this date & user
        document = await _firestoreService.getDocument(
          path: FirestorePath.guestMeal(user.uid, tempDate.toIso8601String()),
        );
        if (document.exists) {
          guestMeal = Meal.fromMap(Map<String, bool>.from(document.data()));
          if (guestMeal.breakfast) {
            userMealAmount += mealAmount.breakfast * 1.5;
            guestMealCount++;
          }
          if (guestMeal.lunch) {
            userMealAmount += mealAmount.lunch * 1.5;
            guestMealCount++;
          }
          if (guestMeal.dinner) {
            userMealAmount += mealAmount.dinner * 1.5;
            guestMealCount++;
          }
        }

        if (tempDate.isAtSameMomentAs(endDate)) break;
        tempDate = tempDate.add(Duration(days: 1));
      }

      await _firestoreService.setData(
        path: FirestorePath.mealRecord(managerId, user.uid),
        data: {
          'mealAmount': userMealAmount,
          'breakfastCount': breakfastCount,
          'lunchCount': lunchCount,
          'dinnerCount': dinnerCount,
          'guestMealCount': guestMealCount,
        },
        merge: true,
      );

      totalMealAmount += userMealAmount;
    }

    double perMealCost = (manager['totalCost'] -
            manager['totalEggCount'] * manager['eggUnitPrice']) /
        (totalMealAmount + messboyMealAmount);
    double perUserFixedCost =
        (fixedCost + perMealCost * messboyMealAmount) / userCount;

    await _firestoreService.setData(
      path: FirestorePath.manager(managerId),
      data: {
        'totalMealAmount': totalMealAmount,
        'perMealCost': perMealCost,
        'perUserFixedCost': perUserFixedCost,
      },
      merge: true,
    );
  }
}
