import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/widgets/custom_app_bar.dart';
import 'package:mess_meal/widgets/daily_meal_card.dart';
import 'package:mess_meal/widgets/default_settings_modal.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mess_meal/widgets/nav_drawer.dart';
import 'package:mess_meal/widgets/custom_calendar.dart';

class MealCheckScreen extends StatefulWidget {
  static const String id = 'meal_check_screen';

  @override
  _MealCheckScreenState createState() => _MealCheckScreenState();
}

class _MealCheckScreenState extends State<MealCheckScreen> {
  CalendarController _calendarController;
  Widget _dailyMealCard;

  void showMealCard(bool available, [DateTime date]) {
    setState(() {
      if (available) {
        _dailyMealCard = DailyMealCard(
          date: date,
        );
      } else {
        _dailyMealCard = Center(
          child: Text('Data not available'),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _calendarController = CalendarController();
    DateTime now = DateTime.now();
    _dailyMealCard = DailyMealCard(
      date: DateTime(now.year, now.month, now.day),
    );
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(
        currentRoute: MealCheckScreen.id,
      ),
      appBar: CustomAppBar(title: 'Check your daily meal'),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CustomCalendar(
                calendarController: _calendarController,
                showMealCard: showMealCard,
              ),
              _dailyMealCard,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => DefaultSettingsModal(),
          );
        },
        child: Icon(
          FontAwesomeIcons.cog,
        ),
      ),
    );
  }
}
