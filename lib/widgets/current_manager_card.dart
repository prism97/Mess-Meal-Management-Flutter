import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/services/database.dart';

class CurrentManagerCard extends StatefulWidget {
  final bool admin;

  const CurrentManagerCard({this.admin = false});

  @override
  _CurrentManagerCardState createState() => _CurrentManagerCardState();
}

class _CurrentManagerCardState extends State<CurrentManagerCard> {
  bool _loading = true;
  String _name = '';
  String _studentId = '';
  String _cost = '';
  String _startDate = '';
  String _workPeriod = '';

  Future<void> getManagerInfo() async {
    final result = await DatabaseService.getManagerData();
    _name = result['name'];
    _studentId = result['studentId'];
    _startDate = result['startDate'];
    _workPeriod = result['workPeriod'];
    _cost = result['cost'];
  }

  @override
  void initState() {
    super.initState();
    getManagerInfo().whenComplete(() {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Current Manager',
              style: Theme.of(context).textTheme.body2,
            ),
            _loading
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SpinKitFadingCircle(
                      color: primaryColorDark,
                      size: 40.0,
                    ),
                  )
                : Column(
                    children: <Widget>[
                      Divider(),
                      ListTile(
                        title: Text(_name),
                        trailing: Text(_studentId),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Start Date'),
                        trailing: Text(_startDate),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Work Period'),
                        trailing: Text('$_workPeriod days'),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Cost until now'),
                        trailing: Text(_cost),
                      ),
                      Divider(),
                      widget.admin
                          ? RaisedButton(
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
                                setState(() {
                                  _loading = true;
                                });
                                await DatabaseService.createManagerData(
                                    DateTime.now());
                                Future.delayed(const Duration(seconds: 10), () {
                                  getManagerInfo().whenComplete(() {
                                    setState(() {
                                      _loading = false;
                                    });
                                  });
                                });
                              },
                            )
                          : Container(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
