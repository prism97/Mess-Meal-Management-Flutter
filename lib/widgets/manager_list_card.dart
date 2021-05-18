import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/member.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:provider/provider.dart';

class ManagerListCard extends StatefulWidget {
  final int start;
  final int end;

  const ManagerListCard({Key key, @required this.start, @required this.end})
      : super(key: key);

  @override
  _ManagerListCardState createState() => _ManagerListCardState();
}

class _ManagerListCardState extends State<ManagerListCard> {
  FirestoreDatabase db;
  List<Member> users;
  Member currentManager;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    db = Provider.of<FirestoreDatabase>(context, listen: false);
    db.getManagerList(widget.start, widget.end).then((value) {
      if (widget.start == 0) {
        currentManager = value.elementAt(0);
        users = value.sublist(1);
      } else {
        users = value;
      }

      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? SpinKitFadingCircle(
            color: primaryColorDark,
            size: 40.0,
          )
        : Card(
            elevation: kElevation,
            margin: const EdgeInsets.all(10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  widget.start == 0
                      ? Column(
                          children: [
                            Text('Current Manager'),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                tileColor: accentColor,
                                title: Text(
                                  currentManager.name,
                                  style: TextStyle(color: Colors.white),
                                ),
                                leading: Chip(
                                  backgroundColor: Colors.white,
                                  label: Icon(
                                    Icons.star,
                                    color: primaryColorLight,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                            Divider(),
                          ],
                        )
                      : Container(),
                  Text('Upcoming Managers'),
                  ...users.map<Widget>(
                    (user) => ListTile(
                      title: Text(
                        user.name,
                      ),
                      leading: Chip(
                        label: Text(
                          (user.managerSerial - 1).toString(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
