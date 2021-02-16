import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:provider/provider.dart';

class ManagerUpdateDialog extends StatefulWidget {
  @override
  _ManagerUpdateDialogState createState() => _ManagerUpdateDialogState();
}

class _ManagerUpdateDialogState extends State<ManagerUpdateDialog> {
  FirestoreDatabase db;
  // initial data
  Map<String, dynamic> oldManager;
  String oldManagerId;
  DateTime startDate, endDate;
  double eggUnitPrice;
  bool initialLoading = true;
  // system counts
  int userCount;
  double fixedCost;
  int messboyCount;

  Future<void> _fetchInitialData() async {
    oldManager = await db.getCurrentManager();
    eggUnitPrice = await db.getEggUnitPrice();
    oldManagerId = oldManager['managerId'];
    startDate = DateTime.parse(oldManager['startDate']);
    endDate = DateTime.now();
    if (endDate.hour < 7) {
      endDate = endDate.subtract(Duration(days: 1));
    }
    endDate = DateTime(endDate.year, endDate.month, endDate.day);
    oldManager['startDate'] = startDate;
    oldManager['endDate'] = endDate;
    return db.saveOldManagerData(oldManager, eggUnitPrice);
  }

  Future<void> _fetchSystemCounts() async {
    userCount = await db.getUserCount();
    messboyCount = await db.getMessboyCount();
    // system fixed cost is for one month, so divide by number of days
    fixedCost =
        (await db.getFixedCost()) / endDate.difference(startDate).inDays;
  }

  @override
  void initState() {
    super.initState();
    db = Provider.of<FirestoreDatabase>(context, listen: false);
    _fetchInitialData().whenComplete(() {
      setState(() {
        initialLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Card(
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            initialLoading
                ? Text('Fetching old manager data...')
                : FutureBuilder<void>(
                    future: _fetchSystemCounts(),
                    builder: (context, systemSnapshot) {
                      if (systemSnapshot.connectionState ==
                          ConnectionState.done) {
                        return FutureBuilder<void>(
                          future: db.updateManager(
                            oldManager,
                            {
                              'userCount': userCount,
                              'messboyCount': messboyCount,
                              'fixedCost': fixedCost,
                              'eggUnitPrice': eggUnitPrice,
                            },
                          ),
                          builder: (context, updateSnapshot) {
                            if (updateSnapshot.connectionState ==
                                ConnectionState.done) {
                              return FutureBuilder<void>(
                                future: db.cleanupUserData(),
                                builder: (context, deleteSnapshot) {
                                  if (deleteSnapshot.connectionState ==
                                      ConnectionState.done) {
                                    Future.delayed(
                                      Duration(seconds: 2),
                                      () => Navigator.pop(context),
                                    );
                                    return Text(
                                      'Manager update has completed successfully',
                                      textAlign: TextAlign.center,
                                    );
                                  }
                                  return Text('Cleaning up user data...');
                                },
                              );
                            }
                            return Text('Calculating meal cost...');
                          },
                        );
                      }
                      return Text('Fetching system counts...');
                    },
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SpinKitFadingCircle(
                color: primaryColorDark,
                size: 40.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
