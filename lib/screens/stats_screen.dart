import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/screens/user_record_screen.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:mess_meal/widgets/basic_white_button.dart';
import 'package:mess_meal/widgets/custom_app_bar.dart';
import 'package:mess_meal/widgets/nav_drawer.dart';
import 'package:mess_meal/widgets/pdf_generator.dart';
import 'package:provider/provider.dart';

class StatsScreen extends StatefulWidget {
  static const String id = 'stats_screen';

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> records;
  List<Map<String, dynamic>> selectedRecords = [];
  FirestoreDatabase db;
  bool _canGeneratePDF = false;

  @override
  void initState() {
    super.initState();
    db = Provider.of<FirestoreDatabase>(context, listen: false);
    db.getManagerRecords().then((value) {
      records = value;
      for (var record in records) {
        record['selected'] = false;
      }
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(title: 'Statistics'),
      drawer: NavDrawer(currentRoute: StatsScreen.id),
      floatingActionButton: _canGeneratePDF
          ? FloatingActionButton(
              child: Icon(FontAwesomeIcons.filePdf),
              onPressed: () async {
                final pdfData = await PdfGenerator.generate(
                    await db.calculateCost(selectedRecords));
                PdfGenerator.saveAsFile(context, pdfData);
              },
            )
          : Container(),
      body: _loading
          ? SpinKitFadingCircle(
              color: accentColor,
              size: 50.0,
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                physics: ScrollPhysics(),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> record = records[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              'Manager : ${record['name']}',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            subtitle: Text(
                              '${record['startDate'].toString().substring(0, 10)} to ${record['endDate'].toString().substring(0, 10)}',
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            trailing: IconButton(
                              color: primaryColorLight,
                              icon: Icon(record['selected']
                                  ? FontAwesomeIcons.solidCheckCircle
                                  : FontAwesomeIcons.checkCircle),
                              onPressed: () {
                                setState(() {
                                  record['selected'] = !record['selected'];
                                });

                                if (record['selected']) {
                                  selectedRecords.add(record);
                                } else {
                                  selectedRecords.remove(record);
                                }
                                if (selectedRecords.length > 0) {
                                  setState(() {
                                    _canGeneratePDF = true;
                                  });
                                } else {
                                  setState(() {
                                    _canGeneratePDF = false;
                                  });
                                }
                              },
                            ),
                          ),
                          Divider(),
                          ListTile(
                            title: Text('Total Cost'),
                            trailing: Text(
                              record['totalCost'].toString(),
                            ),
                            dense: true,
                          ),
                          ListTile(
                            title: Text('Total Meal Amount'),
                            trailing: Text(
                              record['totalMealAmount'].toString(),
                            ),
                            dense: true,
                          ),
                          BasicWhiteButton(
                            text: "View your data",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserRecordScreen(
                                        managerDocument: record)),
                              );
                            },
                          ),
                          BasicWhiteButton(
                            text: "Recalculate stats",
                            onPressed: () {
                              db.recalculateManagerStats(record['managerId']);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
