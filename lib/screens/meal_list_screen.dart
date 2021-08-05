import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/models/member.dart';
import 'package:mess_meal/providers/auth_provider.dart';
import 'package:mess_meal/services/firestore_database.dart';
import 'package:mess_meal/widgets/basic_white_button.dart';
import 'package:mess_meal/widgets/custom_app_bar.dart';
import 'package:mess_meal/widgets/guest_meal_list_card.dart';
import 'package:mess_meal/widgets/manager_list_card.dart';
import 'package:mess_meal/widgets/meal_list_card.dart';
import 'package:mess_meal/widgets/nav_drawer.dart';
import 'package:provider/provider.dart';

class MealListScreen extends StatefulWidget {
  static const String id = 'meal_list_screen';
  final isMessboy;
  static final _scaffoldKey = GlobalKey<ScaffoldState>();

  const MealListScreen({this.isMessboy = false});

  @override
  _MealListScreenState createState() => _MealListScreenState();
}

class _MealListScreenState extends State<MealListScreen> {
  List<Member> _breakfast, _lunch, _dinner;
  List<Map<String, dynamic>> _guestBreakfast, _guestLunch, _guestDinner;
  bool _loading = true;

  FirestoreDatabase db;
  Future<void> fetchMealData() async {
    final meals = await db.getMealSubscribers();

    _breakfast = meals['breakfast'];
    _lunch = meals['lunch'];
    _dinner = meals['dinner'];

    final guestMeals = await db.getGuestMealSubscribers();
    _guestBreakfast = guestMeals['breakfast'];
    _guestLunch = guestMeals['lunch'];
    _guestDinner = guestMeals['dinner'];
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
      key: MealListScreen._scaffoldKey,
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
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          '—— Member Meal ——',
                          style: Theme.of(context).textTheme.bodyText2,
                          textAlign: TextAlign.center,
                        ),
                      ),
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
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          '—— Guest Meal ——',
                          style: Theme.of(context).textTheme.bodyText2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GuestMealListCard(
                        entries: _guestBreakfast,
                        mealName: 'Guest Breakfast',
                        isMessboy: widget.isMessboy,
                      ),
                      GuestMealListCard(
                        entries: _guestLunch,
                        mealName: 'Guest Lunch',
                        isMessboy: widget.isMessboy,
                      ),
                      GuestMealListCard(
                        entries: _guestDinner,
                        mealName: 'Guest Dinner',
                        isMessboy: widget.isMessboy,
                      ),
                      widget.isMessboy
                          ? ManagerListCard(
                              start: 0,
                              end: 3,
                            )
                          : Container(),
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
