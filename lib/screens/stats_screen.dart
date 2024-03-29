import 'package:easy_dialog/easy_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/member.dart';
import 'package:mess_meal/providers/auth_provider.dart';
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
  bool _loading = true, _pdfLoading = false;
  List<Map<String, dynamic>> records;
  List<int> selectedRecordIndices = [];
  FirestoreDatabase db;
  bool _canGeneratePDF = false;
  bool _isConvener = false, _fundLoading = false;
  int _fund;

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
              child: _pdfLoading
                  ? SpinKitFadingCircle(
                      color: Colors.white,
                      size: 30.0,
                    )
                  : Icon(FontAwesomeIcons.filePdf),
              onPressed: () async {
                setState(() {
                  _pdfLoading = true;
                });
                List<Map<String, dynamic>> selectedRecords = [];
                List<Map<String, String>> managers = [];
                for (int i in selectedRecordIndices) {
                  Map<String, dynamic> record = records[i];
                  selectedRecords.add(record);
                  managers.add({
                    "manager": record['name'],
                    "duration":
                        '${record['startDate'].toString().substring(0, 10)} to ${record['endDate'].toString().substring(0, 10)}',
                  });
                }

                final pdfData = await PdfGenerator.generate(
                    await db.calculateCost(selectedRecords), managers);
                setState(() {
                  _pdfLoading = false;
                });
                PdfGenerator.saveAsFile(context, pdfData);
              },
            )
          : Container(),
      body: StreamBuilder<Member>(
          stream: Provider.of<AuthProvider>(context, listen: false).user,
          builder: (context, userSnapshot) {
            if (userSnapshot.hasData) {
              _isConvener = userSnapshot.data.isConvener;

              return _loading
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
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                    subtitle: Text(
                                      '${record['startDate'].toString().substring(0, 10)} to ${record['endDate'].toString().substring(0, 10)}',
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                    trailing: _isConvener
                                        ? IconButton(
                                            color: primaryColorLight,
                                            icon: Icon(record['selected']
                                                ? FontAwesomeIcons
                                                    .solidCheckCircle
                                                : FontAwesomeIcons.checkCircle),
                                            onPressed: () {
                                              setState(() {
                                                record['selected'] =
                                                    !record['selected'];
                                              });

                                              if (record['selected']) {
                                                selectedRecordIndices
                                                    .add(index);
                                              } else {
                                                selectedRecordIndices
                                                    .remove(index);
                                              }
                                              if (selectedRecordIndices.length >
                                                  0) {
                                                setState(() {
                                                  _canGeneratePDF = true;
                                                });
                                              } else {
                                                setState(() {
                                                  _canGeneratePDF = false;
                                                });
                                              }
                                            },
                                          )
                                        : Container(
                                            height: 0,
                                            width: 0,
                                          ),
                                  ),
                                  Divider(),
                                  ListTile(
                                    title: Text('Total Egg Count'),
                                    trailing: Text(
                                      (record['totalEggCount'] ?? 0).toString(),
                                    ),
                                    dense: true,
                                  ),
                                  ListTile(
                                    title: Text('Per Meal Cost'),
                                    trailing: Text(
                                      record['perMealCost'].toStringAsFixed(2),
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
                                  ListTile(
                                    title: Text('Total Cost'),
                                    trailing: Text(
                                      record['totalCost'].toString(),
                                    ),
                                    dense: true,
                                  ),
                                  ListTile(
                                    title: Text('Assigned Fund'),
                                    trailing: Text(
                                      (record['assignedFund'] ?? 0).toString(),
                                    ),
                                    dense: true,
                                  ),
                                  ListTile(
                                    title: Text('Remaining Fund'),
                                    trailing: Text(
                                      (record['assignedFund'] == null
                                              ? 0
                                              : (record['totalCost'] -
                                                  record['assignedFund']))
                                          .toString(),
                                    ),
                                    dense: true,
                                  ),
                                  BasicWhiteButton(
                                    text: "View your data",
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UserRecordScreen(
                                            managerDocument: record,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  _isConvener
                                      ? ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(
                                              Colors.white,
                                            ),
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(
                                              accentColor,
                                            ),
                                            shape: MaterialStateProperty.all<
                                                OutlinedBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        kBorderRadius),
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            'Update Fund',
                                          ),
                                          onPressed: () {
                                            EasyDialog(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  3,
                                              title:
                                                  Text('Update Manager Fund'),
                                              contentList: [
                                                TextFormField(
                                                  autovalidateMode:
                                                      AutovalidateMode
                                                          .onUserInteraction,
                                                  cursorColor:
                                                      primaryColorLight,
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                          signed: true),
                                                  style: TextStyle(
                                                      color: primaryColorDark),
                                                  decoration: InputDecoration(
                                                    errorStyle: TextStyle(
                                                        color: accentColor),
                                                    focusedBorder: Theme.of(
                                                            context)
                                                        .inputDecorationTheme
                                                        .focusedBorder
                                                        .copyWith(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                primaryColorLight,
                                                          ),
                                                        ),
                                                    focusedErrorBorder: Theme
                                                            .of(context)
                                                        .inputDecorationTheme
                                                        .focusedErrorBorder
                                                        .copyWith(
                                                          borderSide:
                                                              BorderSide(
                                                            color:
                                                                primaryColorDark,
                                                          ),
                                                        ),
                                                    labelText: 'amount',
                                                    labelStyle: TextStyle(
                                                        color:
                                                            primaryColorDark),
                                                    hintText:
                                                        'can be positive/negative',
                                                  ),
                                                  validator: (val) =>
                                                      int.tryParse(val) == null
                                                          ? 'Invalid amount'
                                                          : null,
                                                  onChanged: (val) {
                                                    _fund = int.tryParse(val);
                                                  },
                                                ),
                                                SizedBox(
                                                  height: 16,
                                                ),
                                                _fundLoading
                                                    ? SpinKitFadingCircle(
                                                        color: accentColor,
                                                        size: 40.0,
                                                      )
                                                    : TextButton(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(
                                                            primaryColorDark,
                                                          ),
                                                          foregroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(
                                                            Colors.white,
                                                          ),
                                                          padding:
                                                              MaterialStateProperty
                                                                  .all<
                                                                      EdgeInsetsGeometry>(
                                                            EdgeInsets.all(
                                                                kBorderRadius),
                                                          ),
                                                        ),
                                                        child: Text('Update'),
                                                        onPressed: () async {
                                                          print(_fund);
                                                          setState(() {
                                                            _fundLoading = true;
                                                          });
                                                          await db
                                                              .updateManagerFund(
                                                            _fund,
                                                            userSnapshot.data,
                                                            record['managerId'],
                                                            record['name'],
                                                          );
                                                          setState(() {
                                                            _fundLoading =
                                                                false;
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                              ],
                                            ).show(context);
                                          },
                                        )
                                      : Container(),
                                  // _isConvener
                                  //     ? BasicWhiteButton(
                                  //         text: "Recalculate stats",
                                  //         onPressed: () {
                                  //           db.recalculateManagerStats(
                                  //               record['managerId']);
                                  //         },
                                  //       )
                                  //     : Container(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
            }
            return Container();
          }),
    );
  }
}
