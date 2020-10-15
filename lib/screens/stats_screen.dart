import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:mess_meal/widgets/custom_app_bar.dart';
import 'package:mess_meal/widgets/nav_drawer.dart';
import 'package:provider/provider.dart';

class StatsScreen extends StatefulWidget {
  static const String id = 'stats_screen';

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> records;
  FirestoreDatabase db;

  Future<void> fetchMealRecords() async {
    records = await db.getMealRecords();
  }

  @override
  void initState() {
    super.initState();
    db = Provider.of<FirestoreDatabase>(context, listen: false);
    fetchMealRecords().whenComplete(() {
      print(records);
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(title: 'User Statistics'),
      drawer: NavDrawer(currentRoute: StatsScreen.id),
      body: SingleChildScrollView(
        child: _loading
            ? SpinKitFadingCircle(
                color: accentColor,
                size: 50.0,
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> record = records[index];
                    return Card(
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                'Manager : ${record['managerName']}',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              Text(
                                '${record['startDate'].toString().substring(0, 10)} to ${record['endDate'].toString().substring(0, 10)}',
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                              Divider(),
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
                                title: Text('Meal Cost'),
                                trailing: Text(
                                  record['mealCost'].toString(),
                                ),
                              ),
                              ListTile(
                                title: Text('Fixed Cost'),
                                trailing: Text(
                                  record['fixedCost'].toString(),
                                ),
                              ),
                              ListTile(
                                title: Text('Total Cost'),
                                trailing: Text(
                                  record['totalCost'].toString(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
