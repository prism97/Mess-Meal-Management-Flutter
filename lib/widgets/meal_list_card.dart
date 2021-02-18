import 'package:flutter/material.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/member.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:provider/provider.dart';

class MealListCard extends StatefulWidget {
  final List<Member> users;
  final String mealName;
  final isMessboy;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const MealListCard(
      {@required this.users,
      @required this.mealName,
      @required this.isMessboy,
      @required this.scaffoldKey});

  @override
  _MealListCardState createState() => _MealListCardState();
}

class _MealListCardState extends State<MealListCard> {
  FirestoreDatabase db;

  @override
  void initState() {
    super.initState();
    db = Provider.of<FirestoreDatabase>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      elevation: kElevation,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius)),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              widget.mealName,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: CircleAvatar(
              backgroundColor: primaryColorLight,
              foregroundColor: Colors.white,
              child: Text(
                widget.users.length.toString(),
              ),
            ),
          ),
          Divider(),
          ExpansionTile(
            title: Text(
              'subscribers',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            children: widget.users
                .map(
                  (user) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          user.name,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              .copyWith(fontSize: 14),
                        ),
                        trailing: widget.isMessboy
                            ? RaisedButton(
                                color: primaryColorDark,
                                textColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(kBorderRadius),
                                ),
                                child: Text(
                                  'Add egg',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(color: Colors.white),
                                ),
                                onPressed: () {
                                  String message;
                                  db
                                      .updateEggCountOfUser(user.uid)
                                      .then((value) => message =
                                          "Added one egg for ${user.name}")
                                      .catchError((e) => message =
                                          "Couldn't update egg count for ${user.name}")
                                      .whenComplete(
                                          () => showEggSnackBar(message));
                                },
                              )
                            : Container(
                                height: 1.0,
                                width: 1.0,
                              ),
                      ),
                      Divider(),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  void showEggSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      backgroundColor: Theme.of(context).disabledColor,
      elevation: kElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(kBorderRadius),
          topRight: Radius.circular(kBorderRadius),
        ),
      ),
    );
    widget.scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
