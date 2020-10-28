import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/member.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:provider/provider.dart';

class CurrentManagerCard extends StatefulWidget {
  @override
  _CurrentManagerCardState createState() => _CurrentManagerCardState();
}

class _CurrentManagerCardState extends State<CurrentManagerCard> {
  bool _loading = false;
  int _workPeriod;
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
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _workPeriod = DateTime.now()
              .difference(DateTime.parse(snapshot.data['startDate']))
              .inDays;

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
                  Text(
                    'Current Manager',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  Column(
                    children: <Widget>[
                      Divider(),
                      ListTile(
                        title: Text('Name'),
                        trailing: Text(snapshot.data['name']),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Start Date'),
                        trailing: Text(
                          snapshot.data['startDate']
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
                        trailing: Text(snapshot.data['cost'].toString()),
                      ),
                      Divider(),
                      StreamBuilder<Member>(
                        stream:
                            Provider.of<AuthProvider>(context, listen: false)
                                .user,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data.isConvener) {
                            return _loading
                                ? Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: SpinKitFadingCircle(
                                      color: primaryColorDark,
                                      size: 40.0,
                                    ),
                                  )
                                : RaisedButton(
                                    color: accentColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(kBorderRadius),
                                    ),
                                    child: Text(
                                      'Update Manager',
                                      style: Theme.of(context)
                                          .textTheme
                                          .button
                                          .copyWith(color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      // if (_workPeriod >= 14) {
                                      EasyDialog(
                                        height: 160,
                                        closeButton: false,
                                        descriptionPadding: EdgeInsets.only(
                                            bottom: kBorderRadius),
                                        description: Text(
                                            'Are you sure you want to update manager? The current manager has worked for $_workPeriod days.'),
                                        contentList: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              FlatButton(
                                                color: primaryColorDark,
                                                textColor: Colors.white,
                                                padding: EdgeInsets.all(
                                                    kBorderRadius),
                                                child: Text('Yes, update'),
                                                onPressed: () {
                                                  setState(() {
                                                    _loading = true;
                                                  });
                                                  db
                                                      .updateManager()
                                                      .whenComplete(
                                                        () => setState(() {
                                                          _loading = false;
                                                        }),
                                                      );

                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              SizedBox(
                                                width: kBorderRadius,
                                              ),
                                              FlatButton(
                                                color: Colors.white,
                                                textColor: primaryColorDark,
                                                padding: EdgeInsets.all(
                                                    kBorderRadius),
                                                child: Text('No, cancel'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ).show(context);
                                      // } else {
                                      //   EasyDialog(
                                      //     description: Text(
                                      //       'Minimum work period of a manager is 14 days',
                                      //     ),
                                      //   ).show(context);
                                      // }
                                    },
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
