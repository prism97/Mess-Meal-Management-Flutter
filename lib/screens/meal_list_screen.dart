import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/constants/numbers.dart';
import 'package:mess_meal/services/auth.dart';
import 'package:mess_meal/services/database.dart';
import 'package:mess_meal/widgets/custom_app_bar.dart';
import 'package:mess_meal/widgets/loading.dart';
import 'package:mess_meal/widgets/nav_drawer.dart';

class MealListScreen extends StatefulWidget {
  static const String id = 'meal_list_screen';

  @override
  _MealListScreenState createState() => _MealListScreenState();
}

class _MealListScreenState extends State<MealListScreen> {
  List<String> _breakfast;
  List<String> _lunch;
  List<String> _dinner;
  bool loading = true;

  Future<void> fetchMealData() async {
    final String _uid = await AuthService().getCurrentUserId();
    final db = DatabaseService(uid: _uid);
    _breakfast = await db.mealTakers('breakfast');
    _lunch = await db.mealTakers('lunch');
    _dinner = await db.mealTakers('dinner'); // TODO: not loading
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
            drawer: NavDrawer(
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
