import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/member.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:provider/provider.dart';

class ManagerListCard extends StatefulWidget {
  @override
  _ManagerListCardState createState() => _ManagerListCardState();
}

class _ManagerListCardState extends State<ManagerListCard> {
  FirestoreDatabase db;
  List<Member> users;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    db = Provider.of<FirestoreDatabase>(context, listen: false);
    db.getManagerList().then((value) {
      users = value.sublist(1);
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
                  Text('Upcoming Managers'),
                  Divider(),
                  ...users.map<Widget>(
                    (user) => ListTile(
                      title: Text(
                        user.name,
                      ),
                      leading: Chip(
                          label: Text(
                        (user.managerSerial - 1).toString(),
                      )),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
