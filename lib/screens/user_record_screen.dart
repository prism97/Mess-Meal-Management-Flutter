import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:mess_meal/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class UserRecordScreen extends StatefulWidget {
  final Map<String, dynamic> managerDocument;

  const UserRecordScreen({@required this.managerDocument});

  @override
  _UserRecordScreenState createState() => _UserRecordScreenState();
}

class _UserRecordScreenState extends State<UserRecordScreen> {
  bool _loading = true;
  Map<String, dynamic> record;
  FirestoreDatabase db;

  @override
  void initState() {
    super.initState();
    db = Provider.of<FirestoreDatabase>(context, listen: false);
    db.getMealRecord(widget.managerDocument).then((value) {
      record = value;
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Meal Record"),
      body: _loading
          ? SpinKitFadingCircle(
              color: accentColor,
              size: 50.0,
            )
          : Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Breakfast'),
                    trailing: Text(
                      record['breakfastCount'].toString(),
                    ),
                  ),
                  ListTile(
                    title: Text('Lunch'),
                    trailing: Text(
                      record['lunchCount'].toString(),
                    ),
                  ),
                  ListTile(
                    title: Text('Dinner'),
                    trailing: Text(
                      record['dinnerCount'].toString(),
                    ),
                  ),
                  ListTile(
                    title: Text('Eggs'),
                    trailing: Text(
                      record['eggCount'].toString(),
                    ),
                  ),
                  ListTile(
                    title: Text('Guest Meal'),
                    trailing: Text(
                      record['guestMealCount'].toString(),
                    ),
                  ),
                  ListTile(
                    title: Text('Meal Cost'),
                    trailing: Text(
                      double.parse((record['mealCost']).toStringAsFixed(2))
                          .toString(),
                    ),
                  ),
                  ListTile(
                    title: Text('Fixed Cost'),
                    trailing: Text(
                      double.parse((record['fixedCost']).toStringAsFixed(2))
                          .toString(),
                    ),
                  ),
                  ListTile(
                    title: Text('Total Cost'),
                    trailing: Text(
                      double.parse((record['totalCost']).toStringAsFixed(2))
                          .toString(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
