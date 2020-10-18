import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/models/member.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:mess_meal/widgets/basic_white_button.dart';
import 'package:mess_meal/widgets/custom_app_bar.dart';
import 'package:mess_meal/widgets/nav_drawer.dart';
import 'package:provider/provider.dart';

class MealListScreen extends StatefulWidget {
  static const String id = 'meal_list_screen';
  final isMessboy;

  const MealListScreen({this.isMessboy = false});

  @override
  _MealListScreenState createState() => _MealListScreenState();
}

class _MealListScreenState extends State<MealListScreen> {
  static final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Member> _breakfast;
  List<Member> _lunch;
  List<Member> _dinner;
  bool _loading = true;

  FirestoreDatabase db;
  Future<void> fetchMealData() async {
    final meals = await db.getMealSubscribers();

    _breakfast = meals['breakfast'];
    _lunch = meals['lunch'];
    _dinner = meals['dinner'];
    return;
  }

  @override
  void initState() {
    super.initState();
    db = Provider.of<FirestoreDatabase>(context, listen: false);
    fetchMealData().whenComplete(() {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: widget.isMessboy
          ? null
          : NavDrawer(
              currentRoute: MealListScreen.id,
            ),
      appBar: CustomAppBar(title: 'Today\'s Meal'),
      body:
          (_loading || _breakfast == null || _lunch == null || _dinner == null)
              ? SpinKitFadingCircle(
                  color: primaryColorDark,
                  size: 40.0,
                )
              : SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      MealListCard(
                        mealName: 'Breakfast',
                        users: _breakfast,
                        isMessboy: widget.isMessboy,
                      ),
                      MealListCard(
                        users: _lunch,
                        mealName: 'Lunch',
                        isMessboy: widget.isMessboy,
                      ),
                      MealListCard(
                        users: _dinner,
                        mealName: 'Dinner',
                        isMessboy: widget.isMessboy,
                      ),
                      widget.isMessboy
                          ? BasicWhiteButton(
                              text: 'Logout',
                              onPressed: () {
                                final auth = Provider.of<AuthProvider>(context,
                                    listen: false);
                                auth.signOut();
                              },
                            )
                          : Container(),
                    ],
                  ),
                ),
    );
  }
}

class MealListCard extends StatefulWidget {
  final List<Member> users;
  final String mealName;
  final isMessboy;

  const MealListCard(
      {@required this.users,
      @required this.mealName,
      @required this.isMessboy});

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
                        ),
                        trailing: widget.isMessboy
                            ? RaisedButton(
                                color: primaryColorDark,
                                textColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(kBorderRadius),
                                ),
                                child: Text('Add egg'),
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
    _MealListScreenState._scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
