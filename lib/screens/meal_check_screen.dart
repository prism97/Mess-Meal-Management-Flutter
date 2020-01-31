import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mess_meal/constants/colors.dart';
import 'package:mess_meal/widgets/daily_meal_card.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mess_meal/widgets/nav_drawer.dart';

class MealCheckScreen extends StatefulWidget {
  static const String id = 'meal_check_screen';

  @override
  _MealCheckScreenState createState() => _MealCheckScreenState();
}

class _MealCheckScreenState extends State<MealCheckScreen> {
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
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
      appBar: AppBar(
        backgroundColor: darkPurple,
        title: Text(
          'Check your daily meal',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
            // gradient: kBackgroundGradient,
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TableCalendar(
              calendarController: _calendarController,
              availableCalendarFormats: {
                CalendarFormat.week: '',
              },
              initialCalendarFormat: CalendarFormat.week,
              startingDayOfWeek: StartingDayOfWeek.saturday,
              weekendDays: [DateTime.thursday, DateTime.friday],
              headerStyle: HeaderStyle(
                centerHeaderTitle: true,
                decoration: BoxDecoration(
                  color: Colors.purple.shade300,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(20.0),
                    right: Radius.circular(20.0),
                  ),
                ),
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20.0,
                ),
                leftChevronIcon: Icon(
                  FontAwesomeIcons.chevronCircleLeft,
                  color: Colors.white,
                ),
                rightChevronIcon: Icon(
                  FontAwesomeIcons.chevronCircleRight,
                  color: Colors.white,
                ),
              ),
              calendarStyle: CalendarStyle(
                selectedColor: darkPurple,
                todayColor: lightBlue,
                weekdayStyle: TextStyle(
                  color: Colors.purple.shade900,
                ),
                weekendStyle: TextStyle(
                  color: Colors.blue.shade900,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Colors.purple.shade600,
                  fontWeight: FontWeight.w300,
                  fontSize: 15.0,
                ),
                weekendStyle: TextStyle(
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.w300,
                  fontSize: 15.0,
                ),
              ),
            ),
            DailyMealCard(),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(),
          );
        },
        // backgroundColor: Colors.purple.shade300,
        child: Icon(
          FontAwesomeIcons.cog,
        ),
      ),
    );
  }
}
