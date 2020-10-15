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
                      ),
                      MealListCard(
                        users: _lunch,
                        mealName: 'Lunch',
                      ),
                      MealListCard(
                        users: _dinner,
                        mealName: 'Dinner',
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

class MealListCard extends StatelessWidget {
  final List<Member> users;
  final String mealName;

  const MealListCard({@required this.users, @required this.mealName});

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
              mealName,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: CircleAvatar(
              backgroundColor: primaryColorLight,
              foregroundColor: Colors.white,
              child: Text(
                users.length.toString(),
              ),
            ),
          ),
          Divider(),
          ExpansionTile(
            title: Text(
              'subscribers',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            children: users
                .map(
                  (user) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Text(
                          user.name,
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
}
