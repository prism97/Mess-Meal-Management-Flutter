import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/member.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/screens/manager_cost_screen.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:mess_meal/widgets/manager_update_dialog.dart';
import 'package:provider/provider.dart';

class CurrentManagerCard extends StatefulWidget {
  @override
  _CurrentManagerCardState createState() => _CurrentManagerCardState();
}

class _CurrentManagerCardState extends State<CurrentManagerCard> {
  bool _loading = false, _fundLoading = false;
  int _workPeriod;
  int _fund;
  FirestoreDatabase db;

  @override
  void initState() {
    super.initState();
    db = Provider.of<FirestoreDatabase>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: db.currentManagerStream(),
      builder: (context, managerSnapshot) {
        if (managerSnapshot.hasData) {
          _workPeriod = DateTime.now()
              .difference(DateTime.parse(managerSnapshot.data['startDate']))
              .inDays;

          _fund = 0;

          return Card(
            elevation: kElevation,
            margin: EdgeInsets.all(kBorderRadius),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                kBorderRadius,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Manager',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManagerCostScreen(
                                managerId: managerSnapshot.data['managerId'],
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "View Costs >>",
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Divider(),
                      ListTile(
                        title: Text('Name'),
                        trailing: SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Text(
                            managerSnapshot.data['name'],
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Start Date'),
                        trailing: Text(
                          managerSnapshot.data['startDate']
                              .toString()
                              .substring(0, 10),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Work Period'),
                        trailing: Text(
                            '$_workPeriod ${_workPeriod > 1 ? "days" : "day"}'),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Cost until now'),
                        trailing: Text(managerSnapshot.data['cost'].toString()),
                      ),
                      Divider(),
                      StreamBuilder<Member>(
                        stream:
                            Provider.of<AuthProvider>(context, listen: false)
                                .user,
                        builder: (context, userSnapshot) {
                          if (userSnapshot.hasData &&
                              userSnapshot.data.isConvener) {
                            return _loading
                                ? Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: SpinKitFadingCircle(
                                      color: primaryColorDark,
                                      size: 40.0,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                            Colors.white,
                                          ),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
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
                                            title: Text('Update Manager Fund'),
                                            contentList: [
                                              TextFormField(
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                cursorColor: primaryColorLight,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        signed: true),
                                                style: TextStyle(
                                                    color: primaryColorDark),
                                                decoration: InputDecoration(
                                                  errorStyle: TextStyle(
                                                      color: accentColor),
                                                  focusedBorder:
                                                      Theme.of(context)
                                                          .inputDecorationTheme
                                                          .focusedBorder
                                                          .copyWith(
                                                            borderSide:
                                                                BorderSide(
                                                              color:
                                                                  primaryColorLight,
                                                            ),
                                                          ),
                                                  focusedErrorBorder:
                                                      Theme.of(context)
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
                                                      color: primaryColorDark),
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
                                                          managerSnapshot.data[
                                                              'managerId'],
                                                          managerSnapshot
                                                              .data['name'],
                                                        );
                                                        setState(() {
                                                          _fundLoading = false;
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                            ],
                                          ).show(context);
                                        },
                                      ),
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
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
                                          'Update Manager',
                                          style: Theme.of(context)
                                              .textTheme
                                              .button
                                              .copyWith(color: Colors.white),
                                        ),
                                        onPressed: () async {
                                          EasyDialog(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                3,
                                            descriptionPadding: EdgeInsets.only(
                                                bottom: kBorderRadius),
                                            description: Text(
                                                'Are you sure you want to update manager? The current manager has worked for $_workPeriod days.'),
                                            contentList: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  TextButton(
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
                                                          MaterialStateProperty.all<
                                                              EdgeInsetsGeometry>(
                                                        EdgeInsets.all(
                                                            kBorderRadius),
                                                      ),
                                                    ),
                                                    child: Text('Yes, update'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            false,
                                                        builder: (context) =>
                                                            ManagerUpdateDialog(),
                                                      );
                                                    },
                                                  ),
                                                  SizedBox(
                                                    width: kBorderRadius,
                                                  ),
                                                  TextButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                        Colors.white,
                                                      ),
                                                      foregroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                        primaryColorDark,
                                                      ),
                                                      padding:
                                                          MaterialStateProperty.all<
                                                              EdgeInsetsGeometry>(
                                                        EdgeInsets.all(
                                                            kBorderRadius),
                                                      ),
                                                    ),
                                                    child: Text('No, cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ).show(context);
                                        },
                                      ),
                                    ],
                                  );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SpinKitFadingCircle(
              color: primaryColorDark,
              size: 40.0,
            ),
          );
        }
      },
    );
  }
}
