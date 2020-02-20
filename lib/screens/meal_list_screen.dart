import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/services/auth.dart';
import 'package:mess_meal/services/database.dart';
import 'package:mess_meal/widgets/basic_white_button.dart';
import 'package:mess_meal/widgets/custom_app_bar.dart';
import 'package:mess_meal/widgets/loading.dart';
import 'package:mess_meal/widgets/nav_drawer.dart';

class MealListScreen extends StatefulWidget {
  static const String id = 'meal_list_screen';
  final isMessboy;

  const MealListScreen({this.isMessboy = false});

  @override
  _MealListScreenState createState() => _MealListScreenState();
}

class _MealListScreenState extends State<MealListScreen> {
  List<String> _breakfast;
  List<String> _lunch;
  List<String> _dinner;
  bool loading = true;

  Future<void> fetchMealData() async {
    final meals = await DatabaseService.mealTakersGrouped();

    _breakfast = meals['breakfast'];
    _lunch = meals['lunch'];
    _dinner = meals['dinner'];
    return;
  }

  @override
  void initState() {
    super.initState();
    fetchMealData().whenComplete(() {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            drawer: widget.isMessboy
                ? null
                : NavDrawer(
                    currentRoute: MealListScreen.id,
                  ),
            appBar: CustomAppBar(title: 'Today\'s Meal'),
            body: (_breakfast == null || _lunch == null || _dinner == null)
                ? SpinKitCircle(color: primaryColorDark)
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
                                  final auth = AuthService();
                                  auth.logOut();
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
  final List<String> users;
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
              style: Theme.of(context).textTheme.body1,
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
              style: Theme.of(context).textTheme.body1,
            ),
            children: users.map((user) => Text(user)).toList(),
          ),
        ],
      ),
    );
  }
}
